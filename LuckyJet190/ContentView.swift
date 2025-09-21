
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
                    GameView()  // Показуємо GameView під час анімації падіння
                case .exploding:
                    GameView()  // Показуємо GameView під час анімації вибуху
                case .gameOver:
                    GameOverView()
                }
            }
        }
        .ignoresSafeArea()
        .environmentObject(gameModel)  // Додаємо gameModel до environment
    }
}

#Preview {
    ContentView()
}
