
import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = GameModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpaceBackground()
                
                switch gameModel.gameState {
                case .menu:
                    MenuView()
                case .levelSelection:
                    LevelSelectionView()
                case .playing:
                    GameView()
                case .falling:
                    GameView()
                case .exploding:
                    GameView()
                case .gameOver:
                    GameOverView()
                }
            }
        }
        .ignoresSafeArea()
        .environmentObject(gameModel)
    }
}

#Preview {
    ContentView()
}
