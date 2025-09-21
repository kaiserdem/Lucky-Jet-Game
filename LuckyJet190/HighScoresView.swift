import SwiftUI

struct HighScoresView: View {
    @ObservedObject var gameModel: GameModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom("Digitalt", size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("🏆 High Scores")
                        .font(.custom("Digitalt", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .yellow, radius: 5)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding()
                
                // Summary info
                VStack(spacing: 10) {
                    Text("Top Performers")
                        .font(.custom("Digitalt", size: 20))
                        .foregroundColor(.cyan)
                    
                    let totalScores = gameModel.highScores.count
                    let bestScore = gameModel.highScores.first?.score ?? 0
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(totalScores)")
                                .font(.custom("Digitalt", size: 18))
                                .foregroundColor(.yellow)
                            Text("Records")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(bestScore)")
                                .font(.custom("Digitalt", size: 18))
                                .foregroundColor(.green)
                            Text("Best Score")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            let avgScore = totalScores > 0 ? gameModel.highScores.reduce(0) { $0 + $1.score } / totalScores : 0
                            Text("\(avgScore)")
                                .font(.custom("Digitalt", size: 18))
                                .foregroundColor(.blue)
                            Text("Average")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // High scores list
                if gameModel.highScores.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Text("🎯")
                            .font(.custom("Digitalt", size: 64))
                        
                        Text("No High Scores Yet")
                            .font(.custom("Digitalt", size: 24))
                            .foregroundColor(.white)
                        
                        Text("Play the game and achieve great scores to appear here!")
                            .font(.custom("Digitalt", size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(gameModel.highScores.enumerated()), id: \.element.id) { index, score in
                                HighScoreRow(
                                    rank: index + 1,
                                    score: score,
                                    isTopThree: index < 3
                                )
                            }
                            .padding(.vertical, 5)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct HighScoreRow: View {
    let rank: Int
    let score: HighScore
    let isTopThree: Bool
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .white
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            VStack {
                Text(rankIcon)
                    .font(.custom("Digitalt", size: isTopThree ? 28 : 20))
                    .foregroundColor(rankColor)
                
                if !isTopThree {
                    Text("#\(rank)")
                        .font(.custom("Digitalt", size: 12))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 50)
            
            // Player info
            VStack(alignment: .leading, spacing: 5) {
                Text(score.playerName)
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(.white)
                    .fontWeight(isTopThree ? .bold : .medium)
                
                Text(score.levelTitle)
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(.cyan)
                
                Text(formatDate(score.date))
                    .font(.custom("Digitalt", size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Score info
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(score.score)")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(rankColor)
                    .fontWeight(isTopThree ? .bold : .medium)
                
                Text(String(format: "%.1fs", score.flightTime))
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(.green)
                
                Text("Flight Time")
                    .font(.custom("Digitalt", size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isTopThree ? rankColor.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isTopThree ? rankColor.opacity(0.5) : Color.white.opacity(0.2), lineWidth: isTopThree ? 2 : 1)
                )
        )
        .scaleEffect(isTopThree ? 1.02 : 1.0)
        .shadow(color: isTopThree ? rankColor.opacity(0.3) : Color.clear, radius: isTopThree ? 5 : 0)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    HighScoresView(gameModel: GameModel())
}
