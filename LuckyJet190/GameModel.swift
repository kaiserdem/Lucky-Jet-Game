
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

// MARK: - High Score
struct HighScore: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let flightTime: Double
    let levelTitle: String
    let date: Date
    
    init(playerName: String, score: Int, flightTime: Double, levelTitle: String) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.flightTime = flightTime
        self.levelTitle = levelTitle
        self.date = Date()
    }
}

// MARK: - Level
struct Level: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    let difficulty: LevelDifficulty
    let requiredScore: Int
    let explosionTimeRange: ClosedRange<Double>
    let maxFlightTime: Double
    
    init(id: String, title: String, description: String, icon: String, difficulty: LevelDifficulty, requiredScore: Int, explosionTimeRange: ClosedRange<Double>, maxFlightTime: Double, isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.difficulty = difficulty
        self.requiredScore = requiredScore
        self.explosionTimeRange = explosionTimeRange
        self.maxFlightTime = maxFlightTime
        self.isUnlocked = isUnlocked
    }
}

enum LevelDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    case master = "Master"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        case .master: return .purple
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case levelSelection
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
    
    // Levels
    @Published var levels: [Level] = []
    @Published var currentLevel: Level?
    @Published var unlockedLevels: Set<String> = []
    
    // High Scores
    @Published var highScores: [HighScore] = []
    
    private var gameTimer: Timer?
    private var consecutiveJumps: Int = 0
    private var lastJumpTime: Double = 0.0
    private var lastJumpWasPerfect: Bool = false
    
    init() {
        loadStatistics()
        initializeAchievements()
        initializeLevels()
        loadHighScores()
    }
    
    // MARK: - Game Control
    func startGame() {
        // Знаходимо максимальний доступний рівень
        if let maxLevel = getMaxUnlockedLevel() {
            startLevel(maxLevel)
        } else {
            // Якщо немає розблокованих рівнів, запускаємо базову гру
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
    }
    
    // MARK: - Level Management
    func getMaxUnlockedLevel() -> Level? {
        return levels.filter { $0.isUnlocked }.max { level1, level2 in
            // Порівнюємо за складністю та потім за requiredScore
            let difficultyOrder: [LevelDifficulty] = [.easy, .medium, .hard, .expert, .master]
            let level1Index = difficultyOrder.firstIndex(of: level1.difficulty) ?? 0
            let level2Index = difficultyOrder.firstIndex(of: level2.difficulty) ?? 0
            
            if level1Index != level2Index {
                return level1Index < level2Index
            }
            
            return level1.requiredScore < level2.requiredScore
        }
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
    
    func goToLevelSelection() {
        gameState = .levelSelection
    }
    
    func startLevel(_ level: Level) {
        currentLevel = level
        gameState = .playing
        score = 0
        flightTime = 0.0
        isFlying = true
        jumpPressed = false
        
        // Використовуємо налаштування рівня
        explosionTime = Double.random(in: level.explosionTimeRange)
        
        totalGames += 1
        saveStatistics()
        
        startGameTimer()
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
        UserDefaults.standard.synchronize()
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
            print("📂 Loaded achievements: \(unlockedAchievements)")
            
            // Update achievement states based on loaded data
            for i in 0..<achievements.count {
                if unlockedAchievements.contains(achievements[i].id) {
                    achievements[i] = Achievement(
                        id: achievements[i].id,
                        title: achievements[i].title,
                        description: achievements[i].description,
                        icon: achievements[i].icon,
                        isUnlocked: true
                    )
                }
            }
        } else {
            print("📂 No saved achievements found, starting fresh")
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: "unlockedAchievements")
            UserDefaults.standard.synchronize()
            print("💾 Saved achievements: \(unlockedAchievements)")
        } else {
            print("❌ Failed to save achievements")
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
        
        // Check level unlocks
        checkLevelUnlocks()
    }
    
    private func unlockAchievement(_ id: String) {
        unlockedAchievements.insert(id)
        saveAchievements()
        
        print("🎉 Unlocked achievement: \(id)")
        
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
    
    // MARK: - Levels
    private func initializeLevels() {
        levels = [
            // Easy Levels
            Level(id: "easy_1", title: "Easy 1", description: "Learn the basics of space flight", icon: "🚀", difficulty: .easy, requiredScore: 0, explosionTimeRange: 5.0...8.0, maxFlightTime: 10.0, isUnlocked: true),
            Level(id: "easy_2", title: "Easy 2", description: "Master the timing", icon: "👨‍🚀", difficulty: .easy, requiredScore: 100, explosionTimeRange: 4.0...7.0, maxFlightTime: 9.5),
            Level(id: "easy_3", title: "Easy 3", description: "Build your confidence", icon: "🛸", difficulty: .easy, requiredScore: 200, explosionTimeRange: 3.0...6.0, maxFlightTime: 9.0),
            
            // Medium Levels
            Level(id: "medium_1", title: "Medium 1", description: "Navigate through challenges", icon: "✈️", difficulty: .medium, requiredScore: 300, explosionTimeRange: 2.0...5.0, maxFlightTime: 8.5),
            Level(id: "medium_2", title: "Medium 2", description: "Master the cosmos", icon: "🌌", difficulty: .medium, requiredScore: 500, explosionTimeRange: 1.5...4.0, maxFlightTime: 8.0),
            Level(id: "medium_3", title: "Medium 3", description: "Explore the stars", icon: "⭐", difficulty: .medium, requiredScore: 700, explosionTimeRange: 1.0...3.5, maxFlightTime: 7.5),
            Level(id: "medium_4", title: "Medium 4", description: "Advanced space navigation", icon: "🛰️", difficulty: .medium, requiredScore: 900, explosionTimeRange: 0.8...3.0, maxFlightTime: 7.0),
            
            // Hard Levels
            Level(id: "hard_1", title: "Hard 1", description: "Prove your skills", icon: "🎯", difficulty: .hard, requiredScore: 1000, explosionTimeRange: 0.5...3.0, maxFlightTime: 7.0),
            Level(id: "hard_2", title: "Hard 2", description: "Battle the elements", icon: "⚔️", difficulty: .hard, requiredScore: 1500, explosionTimeRange: 0.3...2.5, maxFlightTime: 6.5),
            Level(id: "hard_3", title: "Hard 3", description: "Protect the galaxy", icon: "🛡️", difficulty: .hard, requiredScore: 2000, explosionTimeRange: 0.2...2.0, maxFlightTime: 6.0),
            Level(id: "hard_4", title: "Hard 4", description: "Elite space combat", icon: "⚡", difficulty: .hard, requiredScore: 2500, explosionTimeRange: 0.1...1.5, maxFlightTime: 5.5),
            Level(id: "hard_5", title: "Hard 5", description: "Master space warfare", icon: "🔥", difficulty: .hard, requiredScore: 3000, explosionTimeRange: 0.05...1.0, maxFlightTime: 5.0),
            
            // Expert Levels
            Level(id: "expert_1", title: "Expert 1", description: "Become a legend", icon: "👑", difficulty: .expert, requiredScore: 3500, explosionTimeRange: 0.02...0.8, maxFlightTime: 4.5),
            Level(id: "expert_2", title: "Expert 2", description: "Master the universe", icon: "🌟", difficulty: .expert, requiredScore: 4000, explosionTimeRange: 0.01...0.5, maxFlightTime: 4.0),
            Level(id: "expert_3", title: "Expert 3", description: "Save the universe", icon: "🦸‍♂️", difficulty: .expert, requiredScore: 4500, explosionTimeRange: 0.005...0.3, maxFlightTime: 3.5),
            Level(id: "expert_4", title: "Expert 4", description: "Transcend reality", icon: "🔮", difficulty: .expert, requiredScore: 5000, explosionTimeRange: 0.001...0.2, maxFlightTime: 3.0),
            
            // Master Levels
            Level(id: "master_1", title: "Master 1", description: "Rule the cosmos", icon: "👽", difficulty: .master, requiredScore: 5500, explosionTimeRange: 0.0005...0.1, maxFlightTime: 2.5),
            Level(id: "master_2", title: "Master 2", description: "Create new worlds", icon: "🌍", difficulty: .master, requiredScore: 6000, explosionTimeRange: 0.0001...0.05, maxFlightTime: 2.0),
            Level(id: "master_3", title: "Master 3", description: "Control time itself", icon: "⏰", difficulty: .master, requiredScore: 6500, explosionTimeRange: 0.00001...0.02, maxFlightTime: 1.5),
            Level(id: "master_4", title: "Master 4", description: "Become omnipotent", icon: "♾️", difficulty: .master, requiredScore: 7000, explosionTimeRange: 0.000001...0.01, maxFlightTime: 1.0)
        ]
        loadLevels()
    }
    
    private func loadLevels() {
        if let data = UserDefaults.standard.data(forKey: "unlockedLevels"),
           let unlocked = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedLevels = unlocked
            print("📂 Loaded levels: \(unlockedLevels)")
            
            // Update level states based on loaded data
            for i in 0..<levels.count {
                if unlockedLevels.contains(levels[i].id) {
                    levels[i] = Level(
                        id: levels[i].id,
                        title: levels[i].title,
                        description: levels[i].description,
                        icon: levels[i].icon,
                        difficulty: levels[i].difficulty,
                        requiredScore: levels[i].requiredScore,
                        explosionTimeRange: levels[i].explosionTimeRange,
                        maxFlightTime: levels[i].maxFlightTime,
                        isUnlocked: true
                    )
                }
            }
        } else {
            print("📂 No saved levels found, starting fresh")
            // Перший рівень завжди розблокований
            if !levels.isEmpty {
                unlockLevel("easy_1")
            }
        }
    }
    
    private func saveLevels() {
        if let data = try? JSONEncoder().encode(unlockedLevels) {
            UserDefaults.standard.set(data, forKey: "unlockedLevels")
            UserDefaults.standard.synchronize()
            print("💾 Saved levels: \(unlockedLevels)")
        } else {
            print("❌ Failed to save levels")
        }
    }
    
    private func unlockLevel(_ id: String) {
        unlockedLevels.insert(id)
        saveLevels()
        
        print("🎉 Unlocked level: \(id)")
        
        // Find and update the level
        if let index = levels.firstIndex(where: { $0.id == id }) {
            levels[index] = Level(
                id: levels[index].id,
                title: levels[index].title,
                description: levels[index].description,
                icon: levels[index].icon,
                difficulty: levels[index].difficulty,
                requiredScore: levels[index].requiredScore,
                explosionTimeRange: levels[index].explosionTimeRange,
                maxFlightTime: levels[index].maxFlightTime,
                isUnlocked: true
            )
        }
    }
    
    func checkLevelUnlocks() {
        for level in levels {
            if !unlockedLevels.contains(level.id) && bestScore >= level.requiredScore {
                unlockLevel(level.id)
            }
        }
    }
    
    // MARK: - High Scores Management
    private func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: "highScores"),
           let scores = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = scores.sorted { $0.score > $1.score }
            print("📂 Loaded high scores: \(highScores.count)")
        } else {
            print("📂 No saved high scores found, starting fresh")
            highScores = []
        }
    }
    
    private func saveHighScores() {
        if let data = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(data, forKey: "highScores")
            UserDefaults.standard.synchronize()
            print("💾 Saved high scores: \(highScores.count)")
        } else {
            print("❌ Failed to save high scores")
        }
    }
    
    func isTop10Score(_ score: Int) -> Bool {
        if highScores.count < 10 {
            return true
        }
        return score > highScores.last?.score ?? 0
    }
    
    func addHighScore(playerName: String, score: Int, flightTime: Double, levelTitle: String) {
        let newHighScore = HighScore(
            playerName: playerName,
            score: score,
            flightTime: flightTime,
            levelTitle: levelTitle
        )
        
        highScores.append(newHighScore)
        highScores.sort { $0.score > $1.score }
        
        // Зберігаємо тільки топ-10
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        saveHighScores()
        print("🏆 Added new high score: \(playerName) - \(score)")
    }
    
    func getCurrentGameHighScore() -> HighScore? {
        guard let currentLevel = currentLevel else { return nil }
        return HighScore(
            playerName: "",
            score: score,
            flightTime: flightTime,
            levelTitle: currentLevel.title
        )
    }
}
