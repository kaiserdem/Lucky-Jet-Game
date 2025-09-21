//
//  LuckyJet190UITests.swift
//  LuckyJet190UITests
//
//  Created by Yaroslav Golinskiy on 21/09/2025.
//

import XCTest

final class LuckyJet190UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Налаштування перед кожним тестом
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Очищення після кожного тесту
        app = nil
    }
    
    // MARK: - Menu Screen Tests
    
    func testMenuScreenElements() throws {
        // Перевіряємо наявність елементів головного меню
        XCTAssertTrue(app.buttons["Почати гру"].exists)
        XCTAssertTrue(app.buttons["Статистика"].exists)
        XCTAssertTrue(app.buttons["Налаштування"].exists)
    }
    
    func testStartGameFromMenu() throws {
        // Тестуємо початок гри з меню
        let startButton = app.buttons["Почати гру"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        
        // Перевіряємо що перейшли до ігрового екрану
        XCTAssertTrue(app.staticTexts["Очки: 0"].exists)
        XCTAssertTrue(app.staticTexts["Час: 0.0с"].exists)
        XCTAssertTrue(app.buttons["СТРИБНУТИ!"].exists)
    }
    
    // MARK: - Game Screen Tests
    
    func testGameScreenElements() throws {
        // Переходимо до ігрового екрану
        app.buttons["Почати гру"].tap()
        
        // Перевіряємо наявність всіх елементів
        XCTAssertTrue(app.staticTexts["Очки: 0"].exists)
        XCTAssertTrue(app.staticTexts["Час: 0.0с"].exists)
        XCTAssertTrue(app.buttons["СТРИБНУТИ!"].exists)
        XCTAssertTrue(app.staticTexts["⚠️"].exists)
        XCTAssertTrue(app.staticTexts["Небезпека"].exists)
    }
    
    func testJumpButtonInteraction() throws {
        // Переходимо до ігрового екрану
        app.buttons["Почати гру"].tap()
        
        let jumpButton = app.buttons["СТРИБНУТИ!"]
        XCTAssertTrue(jumpButton.exists)
        XCTAssertTrue(jumpButton.isEnabled)
        
        // Натискаємо кнопку стрибка
        jumpButton.tap()
        
        // Перевіряємо що перейшли до екрану завершення гри
        XCTAssertTrue(app.staticTexts["Гра закінчена!"].exists)
    }
    
    func testGameTimerUpdates() throws {
        // Переходимо до ігрового екрану
        app.buttons["Почати гру"].tap()
        
        // Чекаємо поки час оновиться
        let timeLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Час:'")).firstMatch
        XCTAssertTrue(timeLabel.exists)
        
        // Чекаємо 1 секунду
        sleep(1)
        
        // Перевіряємо що час змінився
        let updatedTimeLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Час:'")).firstMatch
        XCTAssertNotEqual(timeLabel.label, updatedTimeLabel.label)
    }
    
    func testScoreUpdatesAfterJump() throws {
        // Переходимо до ігрового екрану
        app.buttons["Почати гру"].tap()
        
        // Чекаємо трохи часу для накопичення очок
        sleep(2)
        
        // Натискаємо стрибок
        app.buttons["СТРИБНУТИ!"].tap()
        
        // Перевіряємо що очки з'явилися
        let scoreLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Очки:'")).firstMatch
        XCTAssertTrue(scoreLabel.exists)
        
        // Перевіряємо що очки більше 0
        let scoreText = scoreLabel.label
        let scoreValue = scoreText.components(separatedBy: " ").last ?? "0"
        XCTAssertGreaterThan(Int(scoreValue) ?? 0, 0)
    }
    
    // MARK: - Game Over Screen Tests
    
    func testGameOverScreenElements() throws {
        // Переходимо до ігрового екрану і завершуємо гру
        app.buttons["Почати гру"].tap()
        app.buttons["СТРИБНУТИ!"].tap()
        
        // Перевіряємо елементи екрану завершення гри
        XCTAssertTrue(app.staticTexts["Гра закінчена!"].exists)
        XCTAssertTrue(app.buttons["Грати знову"].exists)
        XCTAssertTrue(app.buttons["Головне меню"].exists)
    }
    
    func testPlayAgainFromGameOver() throws {
        // Переходимо до ігрового екрану і завершуємо гру
        app.buttons["Почати гру"].tap()
        app.buttons["СТРИБНУТИ!"].tap()
        
        // Натискаємо "Грати знову"
        app.buttons["Грати знову"].tap()
        
        // Перевіряємо що повернулися до ігрового екрану
        XCTAssertTrue(app.staticTexts["Очки: 0"].exists)
        XCTAssertTrue(app.staticTexts["Час: 0.0с"].exists)
    }
    
    func testReturnToMenuFromGameOver() throws {
        // Переходимо до ігрового екрану і завершуємо гру
        app.buttons["Почати гру"].tap()
        app.buttons["СТРИБНУТИ!"].tap()
        
        // Натискаємо "Головне меню"
        app.buttons["Головне меню"].tap()
        
        // Перевіряємо що повернулися до головного меню
        XCTAssertTrue(app.buttons["Почати гру"].exists)
        XCTAssertTrue(app.buttons["Статистика"].exists)
    }
    
    // MARK: - Statistics Screen Tests
    
    func testStatisticsScreen() throws {
        // Переходимо до статистики
        app.buttons["Статистика"].tap()
        
        // Перевіряємо елементи екрану статистики
        XCTAssertTrue(app.staticTexts["Статистика"].exists)
        XCTAssertTrue(app.staticTexts["Загальна кількість стрибків:"].exists)
        XCTAssertTrue(app.staticTexts["Найдовший політ:"].exists)
        XCTAssertTrue(app.staticTexts["Найкращий результат:"].exists)
        XCTAssertTrue(app.buttons["Скинути статистику"].exists)
        XCTAssertTrue(app.buttons["Назад"].exists)
    }
    
    func testResetStatistics() throws {
        // Переходимо до статистики
        app.buttons["Статистика"].tap()
        
        // Натискаємо скинути статистику
        app.buttons["Скинути статистику"].tap()
        
        // Підтверджуємо дію (якщо є алерт)
        if app.alerts.count > 0 {
            app.alerts.buttons["Скинути"].tap()
        }
        
        // Перевіряємо що статистика скинулася
        XCTAssertTrue(app.staticTexts["0"].exists)
    }
    
    // MARK: - Settings Screen Tests
    
    func testSettingsScreen() throws {
        // Переходимо до налаштувань
        app.buttons["Налаштування"].tap()
        
        // Перевіряємо елементи екрану налаштувань
        XCTAssertTrue(app.staticTexts["Налаштування"].exists)
        XCTAssertTrue(app.buttons["Назад"].exists)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationFlow() throws {
        // Тестуємо повний цикл навігації
        
        // 1. Головне меню
        XCTAssertTrue(app.buttons["Почати гру"].exists)
        
        // 2. Початок гри
        app.buttons["Почати гру"].tap()
        XCTAssertTrue(app.staticTexts["Очки: 0"].exists)
        
        // 3. Завершення гри
        app.buttons["СТРИБНУТИ!"].tap()
        XCTAssertTrue(app.staticTexts["Гра закінчена!"].exists)
        
        // 4. Повернення до меню
        app.buttons["Головне меню"].tap()
        XCTAssertTrue(app.buttons["Почати гру"].exists)
        
        // 5. Перегляд статистики
        app.buttons["Статистика"].tap()
        XCTAssertTrue(app.staticTexts["Статистика"].exists)
        
        // 6. Повернення до меню
        app.buttons["Назад"].tap()
        XCTAssertTrue(app.buttons["Почати гру"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Перевіряємо accessibility labels для основних елементів
        
        let startButton = app.buttons["Почати гру"]
        XCTAssertTrue(startButton.exists)
        XCTAssertFalse(startButton.label.isEmpty)
        
        app.buttons["Почати гру"].tap()
        
        let jumpButton = app.buttons["СТРИБНУТИ!"]
        XCTAssertTrue(jumpButton.exists)
        XCTAssertFalse(jumpButton.label.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // Тестуємо швидкість запуску додатку
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
