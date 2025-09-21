//
//  LuckyJet190Tests.swift
//  LuckyJet190Tests
//
//  Created by Yaroslav Golinskiy on 21/09/2025.
//

import XCTest
@testable import LuckyJet190

final class LuckyJet190Tests: XCTestCase {
    
    var gameModel: GameModel!
    
    override func setUpWithError() throws {
        // Налаштування перед кожним тестом
        gameModel = GameModel()
    }
    
    override func tearDownWithError() throws {
        // Очищення після кожного тесту
        gameModel = nil
    }
    
    // MARK: - Game State Tests
    
    func testInitialGameState() throws {
        // Перевіряємо початковий стан гри
        XCTAssertEqual(gameModel.gameState, .menu)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.flightTime, 0.0)
        XCTAssertFalse(gameModel.isFlying)
        XCTAssertFalse(gameModel.jumpPressed)
    }
    
    func testStartGame() throws {
        // Тестуємо початок гри
        gameModel.startGame()
        
        XCTAssertEqual(gameModel.gameState, .playing)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.flightTime, 0.0)
        XCTAssertTrue(gameModel.isFlying)
        XCTAssertFalse(gameModel.jumpPressed)
        XCTAssertGreaterThan(gameModel.explosionTime, 0)
        XCTAssertLessThanOrEqual(gameModel.explosionTime, gameModel.maxFlightTime)
    }
    
    func testJump() throws {
        // Тестуємо стрибок
        gameModel.startGame()
        
        // Симулюємо час польоту
        gameModel.flightTime = 3.0
        
        gameModel.jump()
        
        XCTAssertEqual(gameModel.gameState, .gameOver)
        XCTAssertTrue(gameModel.jumpPressed)
        XCTAssertFalse(gameModel.isFlying)
        XCTAssertGreaterThan(gameModel.score, 0)
    }
    
    func testJumpWhenNotFlying() throws {
        // Тестуємо стрибок коли не летить
        gameModel.jump()
        
        XCTAssertEqual(gameModel.gameState, .menu)
        XCTAssertEqual(gameModel.score, 0)
    }
    
    func testJumpWhenNotPlaying() throws {
        // Тестуємо стрибок коли гра не активна
        gameModel.gameState = .gameOver
        gameModel.jump()
        
        XCTAssertEqual(gameModel.gameState, .gameOver)
        XCTAssertEqual(gameModel.score, 0)
    }
    
    // MARK: - Score Calculation Tests
    
    func testScoreCalculation() throws {
        gameModel.startGame()
        gameModel.flightTime = 5.0
        gameModel.explosionTime = 6.0 // Встановлюємо час вибуху після стрибка
        
        gameModel.jump()
        
        // Нова формула: pow(5.0, 1.5) * 20 = 223 (час) + 200 (виживання) + ~50 (точність) = ~473
        XCTAssertGreaterThan(gameModel.score, 400)
        XCTAssertLessThan(gameModel.score, 500)
    }
    
    func testScoreCalculationWithSurvivalBonus() throws {
        gameModel.startGame()
        gameModel.flightTime = 9.0
        gameModel.explosionTime = 10.0 // Встановлюємо час вибуху після стрибка
        
        gameModel.jump()
        
        // Нова формула: pow(9.0, 1.5) * 20 = 540 (час) + 200 (виживання) + ~50 (точність) = ~790
        XCTAssertGreaterThan(gameModel.score, 700)
        XCTAssertLessThan(gameModel.score, 900)
    }
    
    // MARK: - Statistics Tests
    
    func testStatisticsUpdate() throws {
        let initialJumps = gameModel.totalJumps
        let initialLongestFlight = gameModel.longestFlight
        let initialBestScore = gameModel.bestScore
        
        gameModel.startGame()
        gameModel.flightTime = 6.0
        gameModel.jump()
        
        XCTAssertEqual(gameModel.totalJumps, initialJumps + 1)
        XCTAssertEqual(gameModel.longestFlight, 6.0)
        XCTAssertGreaterThan(gameModel.bestScore, initialBestScore)
    }
    
    func testResetStatistics() throws {
        // Спочатку встановлюємо деякі статистики
        gameModel.totalJumps = 10
        gameModel.longestFlight = 5.0
        gameModel.bestScore = 100
        
        gameModel.resetStatistics()
        
        XCTAssertEqual(gameModel.totalJumps, 0)
        XCTAssertEqual(gameModel.longestFlight, 0.0)
        XCTAssertEqual(gameModel.bestScore, 0)
    }
    
    // MARK: - Game Timer Tests
    
    func testGameTimerStarts() throws {
        gameModel.startGame()
        
        // Даємо час таймеру спрацювати
        let expectation = XCTestExpectation(description: "Timer updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertGreaterThan(gameModel.flightTime, 0)
    }
    
    func testGameTimerStops() throws {
        gameModel.startGame()
        
        // Даємо час таймеру спрацювати
        let expectation = XCTestExpectation(description: "Timer starts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        let initialFlightTime = gameModel.flightTime
        gameModel.endGame()
        
        // Даємо час переконатися що таймер зупинився
        let expectation2 = XCTestExpectation(description: "Timer stops")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        XCTAssertEqual(gameModel.flightTime, initialFlightTime)
    }
    
    // MARK: - Explosion Tests
    
    func testExplosionAfterTime() throws {
        gameModel.startGame()
        gameModel.explosionTime = 0.5 // Дуже швидкий вибух для тесту
        
        let expectation = XCTestExpectation(description: "Explosion occurs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(gameModel.gameState, .gameOver)
        XCTAssertFalse(gameModel.isFlying)
    }
    
    func testMaxFlightTime() throws {
        gameModel.startGame()
        gameModel.explosionTime = gameModel.maxFlightTime + 1 // Вибух пізніше ніж максимум
        
        let expectation = XCTestExpectation(description: "Max flight time reached")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { // Трохи більше ніж maxFlightTime
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(gameModel.gameState, .gameOver)
        XCTAssertFalse(gameModel.isFlying)
    }
    
    // MARK: - Reset Game Tests
    
    func testResetGame() throws {
        gameModel.startGame()
        gameModel.flightTime = 5.0
        gameModel.score = 100
        gameModel.jump()
        
        gameModel.resetGame()
        
        XCTAssertEqual(gameModel.gameState, .menu)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.flightTime, 0.0)
        XCTAssertFalse(gameModel.isFlying)
        XCTAssertFalse(gameModel.jumpPressed)
        XCTAssertEqual(gameModel.explosionTime, 0.0)
    }
}
