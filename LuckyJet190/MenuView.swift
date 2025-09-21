
import SwiftUI

import SwiftUI

struct MenuView: View {
    @ObservedObject var gameModel: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Game title
            VStack(spacing: 10) {
                Text("🚀 Lucky Jet")
                    .font(.custom("Digitalt", size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 10)
                
                Text("Space Arcade")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.cyan)
            }
            
            Spacer()
            
            // Start button
            Button(action: {
                gameModel.startGame()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Flight")
                }
                .font(.custom("Digitalt", size: 24))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
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
            
            // Statistics
            VStack(spacing: 15) {
                Text("📊 Statistics")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    StatRow(icon: "🏆", title: "Best Score", value: "\(gameModel.bestScore)")
                    StatRow(icon: "⏱️", title: "Longest Flight", value: String(format: "%.1fs", gameModel.longestFlight))
                    StatRow(icon: "🎯", title: "Total Jumps", value: "\(gameModel.totalJumps)")
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
            }
            
            Spacer()
            
            // Instructions
            VStack(spacing: 5) {
                Text("💡 How to play:")
                    .font(.custom("Digitalt", size: 16))
                    .foregroundColor(.yellow)
                
                Text("Press the 'Jump' button before the rocket explodes!")
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.custom("Digitalt", size: 20))
            
            Text(title)
                .font(.custom("Digitalt", size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.custom("Digitalt", size: 14))
                .foregroundColor(.cyan)
        }
    }
}
