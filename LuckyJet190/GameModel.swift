
import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case gameOver
}

// MARK: - Game Model
class GameModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var score: Int = 0
    @Published var flightTime: Double = 0.0
    @Published var isFlying: Bool = false
    @Published var explosionTime: Double = 0.0
    @Published var jumpPressed: Bool = false
    
    // Game settings
    let maxFlightTime: Double = 10.0 // Максимальний час польоту
    let explosionThreshold: Double = 8.0 // Час до вибуху
    
    // Statistics
    @Published var totalJumps: Int = 0
    @Published var longestFlight: Double = 0.0
    @Published var bestScore: Int = 0
    
    private var gameTimer: Timer?
    
    init() {
        loadStatistics()
    }
    
    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        score = 0
        flightTime = 0.0
        isFlying = true
        jumpPressed = false
        explosionTime = Double.random(in: 5.0...maxFlightTime)
        
        startGameTimer()
    }
    
    func jump() {
        guard gameState == .playing && isFlying else { return }
        
        jumpPressed = true
        isFlying = false
        totalJumps += 1
        
        // Розрахунок очок на основі часу польоту
        let timeBonus = Int(flightTime * 10)
        let survivalBonus = flightTime > explosionThreshold ? 100 : 0
        score += timeBonus + survivalBonus
        
        if flightTime > longestFlight {
            longestFlight = flightTime
        }
        
        if score > bestScore {
            bestScore = score
        }
        
        saveStatistics()
        endGame()
    }
    
    func endGame() {
        gameState = .gameOver
        stopGameTimer()
    }
    
    func resetGame() {
        gameState = .menu
        score = 0
        flightTime = 0.0
        isFlying = false
        jumpPressed = false
        explosionTime = 0.0
    }
    
    // MARK: - Timer Management
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateGame() {
        guard gameState == .playing else { return }
        
        flightTime += 0.1
        
        // Перевірка на вибух
        if flightTime >= explosionTime && isFlying {
            isFlying = false
            endGame()
        }
        
        // Максимальний час польоту
        if flightTime >= maxFlightTime && isFlying {
            isFlying = false
            endGame()
        }
    }
    
    // MARK: - Statistics
    private func saveStatistics() {
        UserDefaults.standard.set(totalJumps, forKey: "totalJumps")
        UserDefaults.standard.set(longestFlight, forKey: "longestFlight")
        UserDefaults.standard.set(bestScore, forKey: "bestScore")
    }
    
    private func loadStatistics() {
        totalJumps = UserDefaults.standard.integer(forKey: "totalJumps")
        longestFlight = UserDefaults.standard.double(forKey: "longestFlight")
        bestScore = UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    func resetStatistics() {
        totalJumps = 0
        longestFlight = 0.0
        bestScore = 0
        saveStatistics()
    }
}
