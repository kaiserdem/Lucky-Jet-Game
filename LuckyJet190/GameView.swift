
import SwiftUI

struct GameView: View {
    @ObservedObject var gameModel: GameModel
    @State private var rocketOffset: CGFloat = 0
    @State private var explosionScale: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Astronaut on rocket
                AstronautRocketView(
                    isFlying: gameModel.isFlying,
                    jumpPressed: gameModel.jumpPressed,
                    flightTime: gameModel.flightTime,
                    explosionTime: gameModel.explosionTime
                )
                
                // UI елементи
                VStack {
                    // Верхня панель з інформацією
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Score: \(gameModel.score)")
                                .font(.custom("Digitalt", size: 18))
                                .foregroundColor(.white)
                            
                            Text("Time: \(String(format: "%.1f", gameModel.flightTime))s")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.cyan)
                        }
                        
                        Spacer()
                        
                        // Індикатор небезпеки
                        DangerIndicator(
                            flightTime: gameModel.flightTime,
                            explosionTime: gameModel.explosionTime
                        )
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .padding()
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Кнопка стрибка
                    JumpButton(
                        isEnabled: gameModel.isFlying,
                        onJump: {
                            gameModel.jump()
                        }
                    )
                    .padding(.bottom, 50)
                }
                
                // Ефект вибуху
                if !gameModel.isFlying && !gameModel.jumpPressed {
                    ExplosionEffect()
                        .scaleEffect(explosionScale)
                        .opacity(explosionScale > 0 ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5)) {
                                explosionScale = 1.0
                            }
                        }
                }
            }
        }
    }
}

struct AstronautRocketView: View {
    let isFlying: Bool
    let jumpPressed: Bool
    let flightTime: Double
    let explosionTime: Double
    
    @State private var rocketY: CGFloat = 0
    @State private var rocketRotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ракета
                VStack(spacing: 0) {
                    // Космонавт
                    Text("👨‍🚀")
                        .font(.custom("Digitalt", size: 40))
                        .rotationEffect(.degrees(rocketRotation))
                    
                    // Ракета
                    Text("🚀")
                        .font(.custom("Digitalt", size: 60))
                        .rotationEffect(.degrees(rocketRotation))
                }
                .position(
                    x: geometry.size.width * 0.5,
                    y: geometry.size.height * 0.3 + rocketY
                )
                .onAppear {
                    startRocketAnimation()
                }
                .onChange(of: jumpPressed) { jumped in
                    if jumped {
                        performJumpAnimation()
                    }
                }
                .onChange(of: isFlying) { flying in
                    if !flying && !jumpPressed {
                        performExplosionAnimation()
                    }
                }
            }
        }
    }
    
    private func startRocketAnimation() {
        // Анімація підйому ракети
        withAnimation(.easeInOut(duration: 0.5)) {
            rocketY = -50
        }
        
        // Постійне тремтіння ракети
        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
            rocketRotation = 2
        }
    }
    
    private func performJumpAnimation() {
        // Анімація стрибка
        withAnimation(.easeOut(duration: 1.0)) {
            rocketY = -200
            rocketRotation = 360
        }
    }
    
    private func performExplosionAnimation() {
        // Анімація вибуху
        withAnimation(.easeIn(duration: 0.3)) {
            rocketY = 100
            rocketRotation = 180
        }
    }
}

struct DangerIndicator: View {
    let flightTime: Double
    let explosionTime: Double
    
    private var dangerLevel: Double {
        let timeToExplosion = explosionTime - flightTime
        return max(0, min(1, (explosionTime - timeToExplosion) / explosionTime))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("⚠️")
                .font(.custom("Digitalt", size: 20))
                .opacity(dangerLevel > 0.7 ? 1 : 0.5)
            
            Text("Danger")
                .font(.custom("Digitalt", size: 12))
                .foregroundColor(dangerLevel > 0.7 ? .red : .yellow)
        }
        .padding(8)
        .background(
            Circle()
                .fill(Color.red.opacity(dangerLevel * 0.3))
        )
        .scaleEffect(1 + dangerLevel * 0.2)
        .animation(.easeInOut(duration: 0.3), value: dangerLevel)
    }
}

struct JumpButton: View {
    let isEnabled: Bool
    let onJump: () -> Void
    
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onJump) {
            VStack(spacing: 8) {
                Text("🦘")
                    .font(.custom("Digitalt", size: 30))
                
                Text("JUMP!")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isEnabled ? [.green, .blue] : [.gray, .gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(25)
            .shadow(color: isEnabled ? .green : .gray, radius: 10)
            .scaleEffect(buttonScale)
        }
        .disabled(!isEnabled)
        .onAppear {
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    buttonScale = 1.1
                }
            }
        }
        .onChange(of: isEnabled) { enabled in
            if enabled {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    buttonScale = 1.1
                }
            } else {
                buttonScale = 1.0
            }
        }
    }
}

struct ExplosionEffect: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createExplosion()
        }
    }
    
    private func createExplosion() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: -50...50),
                    y: CGFloat.random(in: -50...50)
                ),
                color: [Color.red, Color.orange, Color.yellow].randomElement() ?? .red,
                size: CGFloat.random(in: 5...15),
                opacity: Double.random(in: 0.5...1.0)
            )
        }
        
        // Анімація частинок
        withAnimation(.easeOut(duration: 1.0)) {
            for i in particles.indices {
                particles[i].position.x += CGFloat.random(in: -100...100)
                particles[i].position.y += CGFloat.random(in: -100...100)
                particles[i].opacity = 0
            }
        }
    }
}

struct Particle {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}
