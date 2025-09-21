
import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var gameModel: GameModel
    @State private var showCelebration = false
    @State private var showHighScorePopup = false
    @State private var hasSavedScore = false
    
    private var isSuccess: Bool {
        gameModel.jumpPressed && gameModel.flightTime < gameModel.explosionTime
    }
    
    private var isTop10Score: Bool {
        gameModel.isTop10Score(gameModel.score)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Game result
            VStack(spacing: 15) {
                Text(isSuccess ? "🎉 Saved!" : "💥 Exploded!")
                    .font(.custom("Digitalt", size: 36))
                    .foregroundColor(isSuccess ? .green : .red)
                    .scaleEffect(showCelebration ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showCelebration)
                
                Text(isSuccess ? "Astronaut saved!" : "Rocket exploded!")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .onAppear {
                showCelebration = true
            }
            
            // Game statistics
            VStack(spacing: 20) {
                Text("📊 Game Result")
                    .font(.custom("Digitalt", size: 24))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    // Level info
                    if let currentLevel = gameModel.currentLevel {
                        ResultRow(
                            icon: currentLevel.icon,
                            title: "Level",
                            value: "Level \(currentLevel.title)",
                            color: currentLevel.difficulty.color
                        )
                    }
                    
                    ResultRow(
                        icon: "⭐",
                        title: "Score",
                        value: "\(gameModel.score)",
                        color: .yellow
                    )
                    
                    ResultRow(
                        icon: "⏱️",
                        title: "Flight Time",
                        value: String(format: "%.1fs", gameModel.flightTime),
                        color: .cyan
                    )
                    
                    ResultRow(
                        icon: "🎯",
                        title: "Result",
                        value: isSuccess ? "Success!" : "Exploded",
                        color: isSuccess ? .green : .red
                    )
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                // Top 10 Score Button - показується тільки коли виграв і ще не зберіг
                if isSuccess && isTop10Score && !hasSavedScore {
                    Button(action: {
                        showHighScorePopup = true
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Save Top 10 Score!")
                        }
                        .font(.custom("Digitalt", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .yellow, radius: 10)
                    }
                    .scaleEffect(showCelebration ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showCelebration)
                }
                
                Button(action: {
                    gameModel.startGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue, radius: 10)
                }
                
                Button(action: {
                    gameModel.resetGame()
                }) {
                    HStack {
                        Image(systemName: "house")
                        Text("Main Menu")
                    }
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(20)
                }
            }
            
            Spacer()
        }
        .padding()
        .overlay(
            // High Score Popup
            Group {
                if showHighScorePopup {
                    HighScorePopupView(
                        isPresented: $showHighScorePopup,
                        onScoreSaved: {
                            hasSavedScore = true
                        }
                    )
                }
            }
        )
    }
}

struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.custom("Digitalt", size: 24))
            
            Text(title)
                .font(.custom("Digitalt", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.custom("Digitalt", size: 16))
                .foregroundColor(color)
        }
    }
}
