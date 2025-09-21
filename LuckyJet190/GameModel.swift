
import Foundation
import SwiftUI
import Combine

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    let unlockedDate: Date?
    
    init(id: String, title: String, description: String, icon: String, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = nil
    }
}

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
    
    // Additional statistics for achievements
    @Published var totalGames: Int = 0
    @Published var totalSuccessfulJumps: Int = 0
    @Published var totalExplosions: Int = 0
    @Published var perfectTimingCount: Int = 0
    @Published var lastSecondJumps: Int = 0
    @Published var earlyJumps: Int = 0
    @Published var lateJumps: Int = 0
    @Published var consecutiveExplosions: Int = 0
    @Published var consecutivePerfectTiming: Int = 0
    
    // Achievements
    @Published var achievements: [Achievement] = []
    @Published var unlockedAchievements: Set<String> = []
    
    private var gameTimer: Timer?
    private var consecutiveJumps: Int = 0
    private var lastJumpTime: Double = 0.0
    private var lastJumpWasPerfect: Bool = false
    
    init() {
        loadStatistics()
        initializeAchievements()
    }
    
    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        score = 0
        flightTime = 0.0
        isFlying = true
        jumpPressed = false
        explosionTime = Double.random(in: 5.0...maxFlightTime)
        
        totalGames += 1
        saveStatistics()
        
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
        
        // Check jump-related achievements
        let isSuccess = flightTime < explosionTime
        checkJumpAchievements(flightTime: flightTime, explosionTime: explosionTime, isSuccess: isSuccess)
        checkAchievements()
        
        saveStatistics()
        endGame()
    }
    
    func endGame() {
        gameState = .gameOver
        stopGameTimer()
        
        // Track explosions
        if !jumpPressed {
            totalExplosions += 1
            consecutiveExplosions += 1
            consecutiveJumps = 0
            consecutivePerfectTiming = 0
        } else {
            consecutiveExplosions = 0
        }
        
        saveStatistics()
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
        UserDefaults.standard.set(totalGames, forKey: "totalGames")
        UserDefaults.standard.set(totalSuccessfulJumps, forKey: "totalSuccessfulJumps")
        UserDefaults.standard.set(totalExplosions, forKey: "totalExplosions")
        UserDefaults.standard.set(perfectTimingCount, forKey: "perfectTimingCount")
        UserDefaults.standard.set(lastSecondJumps, forKey: "lastSecondJumps")
        UserDefaults.standard.set(earlyJumps, forKey: "earlyJumps")
        UserDefaults.standard.set(lateJumps, forKey: "lateJumps")
        UserDefaults.standard.set(consecutiveExplosions, forKey: "consecutiveExplosions")
        UserDefaults.standard.set(consecutivePerfectTiming, forKey: "consecutivePerfectTiming")
    }
    
    private func loadStatistics() {
        totalJumps = UserDefaults.standard.integer(forKey: "totalJumps")
        longestFlight = UserDefaults.standard.double(forKey: "longestFlight")
        bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        totalGames = UserDefaults.standard.integer(forKey: "totalGames")
        totalSuccessfulJumps = UserDefaults.standard.integer(forKey: "totalSuccessfulJumps")
        totalExplosions = UserDefaults.standard.integer(forKey: "totalExplosions")
        perfectTimingCount = UserDefaults.standard.integer(forKey: "perfectTimingCount")
        lastSecondJumps = UserDefaults.standard.integer(forKey: "lastSecondJumps")
        earlyJumps = UserDefaults.standard.integer(forKey: "earlyJumps")
        lateJumps = UserDefaults.standard.integer(forKey: "lateJumps")
        consecutiveExplosions = UserDefaults.standard.integer(forKey: "consecutiveExplosions")
        consecutivePerfectTiming = UserDefaults.standard.integer(forKey: "consecutivePerfectTiming")
    }
    
    func resetStatistics() {
        totalJumps = 0
        longestFlight = 0.0
        bestScore = 0
        totalGames = 0
        totalSuccessfulJumps = 0
        totalExplosions = 0
        perfectTimingCount = 0
        lastSecondJumps = 0
        earlyJumps = 0
        lateJumps = 0
        consecutiveExplosions = 0
        consecutivePerfectTiming = 0
        saveStatistics()
    }
    
    // MARK: - Achievements
    private func initializeAchievements() {
        achievements = [
            // Basic Achievements
            Achievement(id: "first_jump", title: "First Jump", description: "Make your first jump", icon: "🚀"),
            Achievement(id: "first_success", title: "First Success", description: "Successfully complete your first jump", icon: "✨"),
            Achievement(id: "first_explosion", title: "First Explosion", description: "Experience your first explosion", icon: "💥"),
            
            // Timing Achievements
            Achievement(id: "quick_reflex", title: "Quick Reflex", description: "Jump in the last second before explosion", icon: "⚡"),
            Achievement(id: "perfect_timing", title: "Perfect Timing", description: "Jump at the perfect moment (within 0.5s of explosion)", icon: "🎯"),
            Achievement(id: "speed_demon", title: "Speed Demon", description: "Jump within 1 second of takeoff", icon: "💨"),
            Achievement(id: "patience", title: "Patience", description: "Wait more than 7 seconds before jumping", icon: "⏰"),
            Achievement(id: "last_moment", title: "Last Moment", description: "Jump within 0.2 seconds of explosion", icon: "⏱️"),
            Achievement(id: "early_bird", title: "Early Bird", description: "Jump within 2 seconds of takeoff", icon: "🐦"),
            
            // Flight Time Achievements
            Achievement(id: "astronaut", title: "Astronaut", description: "Fly for more than 8 seconds", icon: "👨‍🚀"),
            Achievement(id: "space_explorer", title: "Space Explorer", description: "Fly for more than 9 seconds", icon: "🛸"),
            Achievement(id: "cosmic_traveler", title: "Cosmic Traveler", description: "Fly for more than 9.5 seconds", icon: "🌌"),
            Achievement(id: "time_master", title: "Time Master", description: "Fly for exactly 10 seconds", icon: "⏰"),
            Achievement(id: "short_flight", title: "Short Flight", description: "Fly for less than 3 seconds", icon: "🪶"),
            
            // Score Achievements
            Achievement(id: "score_100", title: "Century", description: "Score 100 points in a single game", icon: "💯"),
            Achievement(id: "score_500", title: "Half Thousand", description: "Score 500 points in a single game", icon: "🎯"),
            Achievement(id: "score_1000", title: "Thousand", description: "Score 1000 points in a single game", icon: "🏆"),
            Achievement(id: "high_scorer", title: "High Scorer", description: "Score more than 2000 points in a single game", icon: "⭐"),
            
            // Streak Achievements
            Achievement(id: "streak_3", title: "Triple", description: "Make 3 successful jumps in a row", icon: "🔥"),
            Achievement(id: "streak_5", title: "Hot Streak", description: "Make 5 successful jumps in a row", icon: "🔥"),
            Achievement(id: "streak_10", title: "Unstoppable", description: "Make 10 successful jumps in a row", icon: "🚀"),
            Achievement(id: "streak_20", title: "Legendary", description: "Make 20 successful jumps in a row", icon: "👑"),
            
            // Total Statistics Achievements
            Achievement(id: "survivor", title: "Survivor", description: "Make 10 successful jumps total", icon: "🏆"),
            Achievement(id: "veteran", title: "Veteran", description: "Make 50 successful jumps total", icon: "🎖️"),
            Achievement(id: "master", title: "Master", description: "Make 100 successful jumps total", icon: "🏅"),
            Achievement(id: "grandmaster", title: "Grandmaster", description: "Make 500 successful jumps total", icon: "👑"),
            
            // Special Achievements
            Achievement(id: "lucky_one", title: "Lucky One", description: "Survive 5 explosions in a row", icon: "🍀"),
            Achievement(id: "risk_taker", title: "Risk Taker", description: "Jump 10 times in the last 0.5 seconds", icon: "🎲"),
            Achievement(id: "conservative", title: "Conservative", description: "Jump 10 times after 8 seconds", icon: "🛡️"),
            Achievement(id: "perfectionist", title: "Perfectionist", description: "Get perfect timing 5 times in a row", icon: "💎"),
            
            // Milestone Achievements
            Achievement(id: "milestone_100", title: "Century Club", description: "Play 100 games total", icon: "💯"),
            Achievement(id: "milestone_500", title: "Half Thousand Club", description: "Play 500 games total", icon: "🎯"),
            Achievement(id: "milestone_1000", title: "Thousand Club", description: "Play 1000 games total", icon: "🏆")
        ]
        loadAchievements()
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "unlockedAchievements"),
           let unlocked = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedAchievements = unlocked
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: "unlockedAchievements")
        }
    }
    
    private func checkAchievements() {
        // Basic Achievements
        if totalJumps >= 1 && !unlockedAchievements.contains("first_jump") {
            unlockAchievement("first_jump")
        }
        
        if totalSuccessfulJumps >= 1 && !unlockedAchievements.contains("first_success") {
            unlockAchievement("first_success")
        }
        
        if totalExplosions >= 1 && !unlockedAchievements.contains("first_explosion") {
            unlockAchievement("first_explosion")
        }
        
        // Flight Time Achievements
        if longestFlight >= 8.0 && !unlockedAchievements.contains("astronaut") {
            unlockAchievement("astronaut")
        }
        
        if longestFlight >= 9.0 && !unlockedAchievements.contains("space_explorer") {
            unlockAchievement("space_explorer")
        }
        
        if longestFlight >= 9.5 && !unlockedAchievements.contains("cosmic_traveler") {
            unlockAchievement("cosmic_traveler")
        }
        
        if longestFlight >= 10.0 && !unlockedAchievements.contains("time_master") {
            unlockAchievement("time_master")
        }
        
        if longestFlight <= 3.0 && longestFlight > 0 && !unlockedAchievements.contains("short_flight") {
            unlockAchievement("short_flight")
        }
        
        // Score Achievements
        if bestScore >= 100 && !unlockedAchievements.contains("score_100") {
            unlockAchievement("score_100")
        }
        
        if bestScore >= 500 && !unlockedAchievements.contains("score_500") {
            unlockAchievement("score_500")
        }
        
        if bestScore >= 1000 && !unlockedAchievements.contains("score_1000") {
            unlockAchievement("score_1000")
        }
        
        if bestScore >= 2000 && !unlockedAchievements.contains("high_scorer") {
            unlockAchievement("high_scorer")
        }
        
        // Total Statistics Achievements
        if totalSuccessfulJumps >= 10 && !unlockedAchievements.contains("survivor") {
            unlockAchievement("survivor")
        }
        
        if totalSuccessfulJumps >= 50 && !unlockedAchievements.contains("veteran") {
            unlockAchievement("veteran")
        }
        
        if totalSuccessfulJumps >= 100 && !unlockedAchievements.contains("master") {
            unlockAchievement("master")
        }
        
        if totalSuccessfulJumps >= 500 && !unlockedAchievements.contains("grandmaster") {
            unlockAchievement("grandmaster")
        }
        
        // Special Achievements
        if consecutiveExplosions >= 5 && !unlockedAchievements.contains("lucky_one") {
            unlockAchievement("lucky_one")
        }
        
        if lastSecondJumps >= 10 && !unlockedAchievements.contains("risk_taker") {
            unlockAchievement("risk_taker")
        }
        
        if lateJumps >= 10 && !unlockedAchievements.contains("conservative") {
            unlockAchievement("conservative")
        }
        
        if consecutivePerfectTiming >= 5 && !unlockedAchievements.contains("perfectionist") {
            unlockAchievement("perfectionist")
        }
        
        // Milestone Achievements
        if totalGames >= 100 && !unlockedAchievements.contains("milestone_100") {
            unlockAchievement("milestone_100")
        }
        
        if totalGames >= 500 && !unlockedAchievements.contains("milestone_500") {
            unlockAchievement("milestone_500")
        }
        
        if totalGames >= 1000 && !unlockedAchievements.contains("milestone_1000") {
            unlockAchievement("milestone_1000")
        }
    }
    
    private func unlockAchievement(_ id: String) {
        unlockedAchievements.insert(id)
        saveAchievements()
        
        // Find and update the achievement
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index] = Achievement(
                id: achievements[index].id,
                title: achievements[index].title,
                description: achievements[index].description,
                icon: achievements[index].icon,
                isUnlocked: true
            )
        }
    }
    
    func checkJumpAchievements(flightTime: Double, explosionTime: Double, isSuccess: Bool) {
        // Update statistics
        if isSuccess {
            totalSuccessfulJumps += 1
        }
        
        // Timing Achievements
        if flightTime >= explosionTime - 1.0 && !unlockedAchievements.contains("quick_reflex") {
            unlockAchievement("quick_reflex")
            lastSecondJumps += 1
        }
        
        if abs(flightTime - explosionTime) <= 0.5 && !unlockedAchievements.contains("perfect_timing") {
            unlockAchievement("perfect_timing")
            perfectTimingCount += 1
            consecutivePerfectTiming += 1
            lastJumpWasPerfect = true
        } else {
            consecutivePerfectTiming = 0
            lastJumpWasPerfect = false
        }
        
        if flightTime <= 1.0 && !unlockedAchievements.contains("speed_demon") {
            unlockAchievement("speed_demon")
            earlyJumps += 1
        }
        
        if flightTime >= 7.0 && !unlockedAchievements.contains("patience") {
            unlockAchievement("patience")
            lateJumps += 1
        }
        
        if flightTime >= explosionTime - 0.2 && !unlockedAchievements.contains("last_moment") {
            unlockAchievement("last_moment")
        }
        
        if flightTime <= 2.0 && !unlockedAchievements.contains("early_bird") {
            unlockAchievement("early_bird")
        }
        
        // Streak Achievements
        if isSuccess {
            consecutiveJumps += 1
            if consecutiveJumps >= 3 && !unlockedAchievements.contains("streak_3") {
                unlockAchievement("streak_3")
            }
            if consecutiveJumps >= 5 && !unlockedAchievements.contains("streak_5") {
                unlockAchievement("streak_5")
            }
            if consecutiveJumps >= 10 && !unlockedAchievements.contains("streak_10") {
                unlockAchievement("streak_10")
            }
            if consecutiveJumps >= 20 && !unlockedAchievements.contains("streak_20") {
                unlockAchievement("streak_20")
            }
        } else {
            consecutiveJumps = 0
        }
        
        lastJumpTime = flightTime
    }
}
