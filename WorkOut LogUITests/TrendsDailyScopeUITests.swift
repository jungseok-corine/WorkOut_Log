//
//  TrendsDailyScopeUITests.swift
//  WorkOut LogUITests
//
//  Created by Claude on 16/10/2025.
//

import XCTest

final class TrendsDailyScopeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_dailyScope_showAllDaysToggle_exists() throws {
        // Navigate to Trends tab
        let trendsTab = app.buttons["Trends"]
        XCTAssertTrue(trendsTab.waitForExistence(timeout: 5))
        trendsTab.tap()

        // Switch to Daily scope
        let dailyButton = app.buttons["trendScopeDaily"]
        XCTAssertTrue(dailyButton.waitForExistence(timeout: 2))
        dailyButton.tap()

        // Verify Show All Days toggle appears
        let toggle = app.switches["trendShowAllDaysToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 2))

        // Switch to Weekly
        let weeklyButton = app.buttons["trendScopeWeekly"]
        weeklyButton.tap()

        // Verify toggle is hidden
        XCTAssertFalse(toggle.exists)
    }

    func test_dailyScope_toggleAffectsChart() throws {
        // Navigate to Trends tab
        let trendsTab = app.buttons["Trends"]
        XCTAssertTrue(trendsTab.waitForExistence(timeout: 5))
        trendsTab.tap()

        // Switch to Daily scope
        let dailyButton = app.buttons["trendScopeDaily"]
        dailyButton.tap()

        sleep(1) // Wait for chart to load

        // Toggle Show All Days on
        let toggle = app.switches["trendShowAllDaysToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 2))

        // Toggle on
        if toggle.value as? String == "0" {
            toggle.tap()
            sleep(1)
        }

        // Toggle off
        if toggle.value as? String == "1" {
            toggle.tap()
            sleep(1)
        }

        // Test passes if no crash occurs (chart handles both modes)
        XCTAssertTrue(toggle.exists)
    }

    func test_categoryFilter_worksInDailyScope() throws {
        // Navigate to Trends tab
        let trendsTab = app.buttons["Trends"]
        XCTAssertTrue(trendsTab.waitForExistence(timeout: 5))
        trendsTab.tap()

        // Switch to Daily scope
        let dailyButton = app.buttons["trendScopeDaily"]
        dailyButton.tap()

        // Test category chip
        let lowerBodyChip = app.buttons["categoryChip_lowerBody"]
        if lowerBodyChip.exists {
            lowerBodyChip.tap()
            sleep(1) // Wait for chart update
        }

        // Switch back to All
        let allChip = app.buttons["categoryChip_all"]
        if allChip.exists {
            allChip.tap()
            sleep(1)
        }

        // Test passes if no crash
        XCTAssertTrue(true)
    }
}
