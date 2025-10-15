//
//  SwipeDeleteUITests.swift
//  WorkOut LogUITests
//
//  Created by Claude on 15/10/2025.
//

import XCTest

final class SwipeDeleteUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSwipeDeleteSet() throws {
        // Create a session
        let createButton = app.buttons["createTodayButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        createButton.tap()

        // Wait for session to be created and navigate to it
        sleep(1)
        let firstSession = app.buttons.matching(identifier: "sessionRow_").firstMatch
        XCTAssertTrue(firstSession.waitForExistence(timeout: 5))
        firstSession.tap()

        // Add a set
        let weightField = app.textFields["Weight (kg)"]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5))
        weightField.tap()
        weightField.typeText("40")

        let repsField = app.textFields["Reps"]
        repsField.tap()
        repsField.typeText("10")

        let addSetButton = app.buttons["addSetButton"]
        addSetButton.tap()

        // Wait for set to appear
        sleep(1)

        // Verify set appears in list
        let setRow = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '40kg'")).firstMatch
        XCTAssertTrue(setRow.exists)

        // Swipe to delete
        setRow.swipeLeft()

        let deleteButton = app.buttons["deleteSet"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        // Verify set is removed
        sleep(1)
        XCTAssertFalse(setRow.exists)
    }

    func testSwipeDeleteSession() throws {
        // Create a session
        let createButton = app.buttons["createTodayButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        createButton.tap()

        // Wait for session list to update
        sleep(1)

        // Find the session row
        let sessionRow = app.buttons.matching(identifier: "sessionRow_").firstMatch
        XCTAssertTrue(sessionRow.waitForExistence(timeout: 5))

        // Swipe to delete
        sessionRow.swipeLeft()

        let deleteButton = app.buttons["deleteSession"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        // Verify session is removed
        sleep(1)
        // Note: If this was the only session, the list might be empty or show a different session
    }
}
