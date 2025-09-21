import SwiftUI

struct AchievementView: View {
    @EnvironmentObject var gameModel: GameModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom("Digitalt", size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("🏆 Achievements")
                        .font(.custom("Digitalt", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .yellow, radius: 5)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding()
                
                VStack(spacing: 10) {
                    Text("Progress")
                        .font(.custom("Digitalt", size: 20))
                        .foregroundColor(.cyan)
                    
                    let unlockedCount = gameModel.achievements.filter { $0.isUnlocked }.count
                    let totalCount = gameModel.achievements.count
                    
                    Text("\(unlockedCount) / \(totalCount)")
                        .font(.custom("Digitalt", size: 18))
                        .foregroundColor(.white)
                    
                    ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    HStack(spacing: 15) {
                        VStack {
                            Text("\(gameModel.achievements.filter { $0.isUnlocked && $0.id.contains("first") || $0.id.contains("basic") }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.green)
                            Text("Basic")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.achievements.filter { $0.isUnlocked && $0.id.contains("timing") || $0.id.contains("reflex") || $0.id.contains("patience") }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.blue)
                            Text("Timing")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.achievements.filter { $0.isUnlocked && $0.id.contains("streak") || $0.id.contains("score") }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.orange)
                            Text("Streaks")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.achievements.filter { $0.isUnlocked && $0.id.contains("milestone") || $0.id.contains("master") }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.purple)
                            Text("Mastery")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(gameModel.achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Text(achievement.icon)
                .font(.custom("Digitalt", size: 32))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(achievement.isUnlocked ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                )
                .overlay(
                    Circle()
                        .stroke(achievement.isUnlocked ? Color.green : Color.gray, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                
                Text(achievement.description)
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(achievement.isUnlocked ? .cyan : .gray)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.circle.fill")
                    .font(.custom("Digitalt", size: 20))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(achievement.isUnlocked ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(achievement.isUnlocked ? Color.green.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AchievementView()
        .environmentObject(GameModel())
}
