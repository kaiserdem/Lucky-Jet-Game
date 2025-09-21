import SwiftUI

struct HighScorePopupView: View {
    @EnvironmentObject var gameModel: GameModel
    @Binding var isPresented: Bool
    @State private var playerName: String = ""
    @State private var showError: Bool = false
    let onScoreSaved: (() -> Void)?
    
    private var currentScore: Int {
        gameModel.score
    }
    
    private var currentLevelTitle: String {
        gameModel.currentLevel?.title ?? "Unknown Level"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer(minLength: 50)
                        
                        HighScoreHeaderView()
                        
                        ScoreInfoView(
                            currentScore: currentScore,
                            currentLevelTitle: currentLevelTitle,
                            flightTime: gameModel.flightTime
                        )
                        
                        NameInputView(
                            playerName: $playerName,
                            showError: $showError,
                            onSave: saveHighScore
                        )
                        
                        ActionButtonsView(
                            playerName: playerName,
                            onCancel: {
                                isPresented = false
                            },
                            onSave: saveHighScore
                        )
                        
                        AchievementUnlockedView()
                        
                        StatisticsView(
                            totalGames: gameModel.totalGames,
                            bestScore: gameModel.bestScore
                        )
                        
                        Spacer(minLength: 50)
                    }
                    .padding(30)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.9), Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.yellow, lineWidth: 3)
                    )
                    .shadow(color: .yellow, radius: 20)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 70)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                }
            }
        }
    }
    
    private func saveHighScore() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            showError = true
            return
        }
        
        showError = false
        
        gameModel.addHighScore(
            playerName: trimmedName,
            score: currentScore,
            flightTime: gameModel.flightTime,
            levelTitle: currentLevelTitle
        )
        
        onScoreSaved?()
        
        isPresented = false
    }
}

#Preview {
    HighScorePopupView(
        isPresented: .constant(true),
        onScoreSaved: nil
    )
    .environmentObject(GameModel())
}
