
import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = GameModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фон космосу
                SpaceBackground()
                
                switch gameModel.gameState {
                case .menu:
                    MenuView(gameModel: gameModel)
                case .playing:
                    GameView(gameModel: gameModel)
                case .gameOver:
                    GameOverView(gameModel: gameModel)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
