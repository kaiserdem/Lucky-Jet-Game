
import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameModel: GameModel
    @State private var rocketOffset: CGFloat = 0
    @State private var explosionScale: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let rocketPosition = CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
            
            ZStack {
                if gameModel.gameState != .exploding {
                    AstronautRocketView(
                        isFlying: gameModel.isFlying,
                        jumpPressed: gameModel.jumpPressed,
                        flightTime: gameModel.flightTime,
                        explosionTime: gameModel.explosionTime,
                        gameState: gameModel.gameState,
                        animationProgress: gameModel.animationProgress
                    )
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            if let currentLevel = gameModel.currentLevel {
                                HStack {
                                    Text(currentLevel.icon)
                                        .font(.custom("Digitalt", size: 20))
                                    Text("Level \(currentLevel.title)")
                                        .font(.custom("Digitalt", size: 16))
                                        .foregroundColor(currentLevel.difficulty.color)
                                }
                            }
                            
                            Text("Score: \(gameModel.score)")
                                .font(.custom("Digitalt", size: 18))
                                .foregroundColor(.white)
                            
                            Text("Time: \(String(format: "%.1f", gameModel.flightTime))s")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.cyan)
                        }
                        
                        Spacer()
                        
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
                    
                    if gameModel.gameState == .playing && gameModel.isFlying {
                        JumpButton(
                            isEnabled: gameModel.isFlying,
                            onJump: {
                                print("🦘 JUMP BUTTON PRESSED - isEnabled: \(gameModel.isFlying)")
                                gameModel.jump()
                            }
                        )
                        .padding(.bottom, 50)
                    }
                    
                    if gameModel.gameState == .playing && !gameModel.isFlying && !gameModel.jumpPressed {
                        let _ = print("🔥 ДЕТОНАЦІЯ БЛОК: gameState=\(gameModel.gameState), isFlying=\(gameModel.isFlying), jumpPressed=\(gameModel.jumpPressed)")
                        VStack(spacing: 20) {
                            Text("💥 DETONATION! 💥")
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.red)
                                .shadow(color: .orange, radius: 10)
                                .scaleEffect(explosionScale)
                                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: explosionScale)
                                .onAppear {
                                    explosionScale = 1.2
                                }
                            
                            Text("Time's up!")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                                .opacity(explosionScale > 1.0 ? 0.7 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: explosionScale)
                        }
                        .padding(.bottom, 50)
                    }
                }
                
                if gameModel.gameState == .exploding {
                    ExplosionEffect(rocketPosition: rocketPosition)
                        .position(rocketPosition)
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
    let gameState: GameState
    let animationProgress: Double
    
    @EnvironmentObject var gameModel: GameModel
    
    private var pilotScreenPosition: CGFloat {
        UIScreen.main.bounds.height * 0.3 + gameModel.pilotY
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text("🚀")
                    .font(.custom("Digitalt", size: 60))
                    .rotationEffect(.degrees(gameModel.rocketRotation))
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                    .zIndex(1)
                
                Text("👨‍🚀")
                    .font(.custom("Digitalt", size: 40))
                    .rotationEffect(.degrees(gameModel.pilotRotation))
                    .position(x: geometry.size.width * 0.5, y: pilotScreenPosition - 25)
                    .zIndex(2)
            }
           
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
            print("🦘 JumpButton appeared - isEnabled: \(isEnabled)")
            if isEnabled {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    buttonScale = 1.1
                }
            }
        }
        .onChange(of: isEnabled) { enabled in
            print("🦘 JumpButton enabled changed to: \(enabled)")
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
    let rocketPosition: CGPoint
    
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
        particles = (0..<1920).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: rocketPosition.x - 10...rocketPosition.x + 10),
                    y: CGFloat.random(in: rocketPosition.y - 10...rocketPosition.y + 10)
                )
                ,
                color: Color.red,
                size: CGFloat.random(in: 6...15),
                opacity: Double.random(in: 0.8...1.0)
            )
        }
        
        withAnimation(.linear(duration: 4.5)) {
            for i in particles.indices {
                let angle = Double(i) * (2 * Double.pi / Double(particles.count))
                let distance: CGFloat = CGFloat.random(in: 50...3750)
                
                let newX = cos(angle) * distance
                let newY = sin(angle) * distance
                
                particles[i].position.x = newX + rocketPosition.x
                particles[i].position.y = newY + rocketPosition.y - 300
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
