import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject var gameModel: GameModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.8)]),
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
                    
                    Text("🎮 Levels")
                        .font(.custom("Digitalt", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 5)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding()
                
                VStack(spacing: 10) {
                    Text("Progress")
                        .font(.custom("Digitalt", size: 20))
                        .foregroundColor(.cyan)
                    
                    let unlockedCount = gameModel.levels.filter { $0.isUnlocked }.count
                    let totalCount = gameModel.levels.count
                    
                    Text("\(unlockedCount) / \(totalCount)")
                        .font(.custom("Digitalt", size: 18))
                        .foregroundColor(.white)
                    
                    ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    HStack(spacing: 15) {
                        VStack {
                            Text("\(gameModel.levels.filter { $0.isUnlocked && $0.difficulty == .easy }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.green)
                            Text("Easy")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.levels.filter { $0.isUnlocked && $0.difficulty == .medium }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.yellow)
                            Text("Medium")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.levels.filter { $0.isUnlocked && $0.difficulty == .hard }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.orange)
                            Text("Hard")
                                .font(.custom("Digitalt", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameModel.levels.filter { $0.isUnlocked && ($0.difficulty == .expert || $0.difficulty == .master) }.count)")
                                .font(.custom("Digitalt", size: 16))
                                .foregroundColor(.purple)
                            Text("Expert+")
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
                        ForEach(gameModel.levels) { level in
                            LevelRow(level: level)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct LevelRow: View {
    let level: Level
    @EnvironmentObject var gameModel: GameModel
    
    var body: some View {
        HStack(spacing: 15) {
            Text(level.icon)
                .font(.custom("Digitalt", size: 32))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(level.isUnlocked ? level.difficulty.color.opacity(0.3) : Color.gray.opacity(0.3))
                )
                .overlay(
                    Circle()
                        .stroke(level.isUnlocked ? level.difficulty.color : Color.gray, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(level.title)
                    .font(.custom("Digitalt", size: 18))
                    .foregroundColor(level.isUnlocked ? .white : .gray)
                
                Text(level.description)
                    .font(.custom("Digitalt", size: 14))
                    .foregroundColor(level.isUnlocked ? .cyan : .gray)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(level.difficulty.rawValue)
                        .font(.custom("Digitalt", size: 12))
                        .foregroundColor(level.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(level.difficulty.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("Score: \(level.requiredScore)")
                        .font(.custom("Digitalt", size: 12))
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            if level.isUnlocked {
                Button(action: {
                    gameModel.startLevel(level)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.custom("Digitalt", size: 24))
                        .foregroundColor(.green)
                }
            } else {
                Image(systemName: "lock.circle.fill")
                    .font(.custom("Digitalt", size: 24))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(level.isUnlocked ? level.difficulty.color.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(level.isUnlocked ? level.difficulty.color.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    LevelSelectionView()
        .environmentObject(GameModel())
}
