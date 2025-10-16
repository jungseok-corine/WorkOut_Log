//
//  SessionDetailGroupingUITests.swift
//  WorkOut LogUITests
//
//  Created by Claude on 16/10/2025.
//

import XCTest

final class SessionDetailGroupingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_groupedSections_addMultipleExercises() throws {
        // Given: Launch app and create a new session
        let createButton = app.buttons["createTodayButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        createButton.tap()

        // Navigate to session detail
        let firstSession = app.buttons.matching(identifier: "sessionRow_").firstMatch
        XCTAssertTrue(firstSession.waitForExistence(timeout: 5))
        firstSession.tap()

        // AC1: Select Squat and add 2 sets → Squat section appears with #1, #2
        let selectExerciseButton = app.buttons["openExercisePicker"]
        XCTAssertTrue(selectExerciseButton.exists)
        selectExerciseButton.tap()

        // Create Squat exercise
        let createNewButton = app.buttons["createExerciseButton"]
        XCTAssertTrue(createNewButton.waitForExistence(timeout: 2))
        createNewButton.tap()

        let nameField = app.textFields["exerciseNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Squat")

        let saveButton = app.buttons["saveExerciseButton"]
        saveButton.tap()

        // Verify current exercise label
        let selectedLabel = app.otherElements["selectedExerciseLabel"]
        XCTAssertTrue(selectedLabel.waitForExistence(timeout: 2))

        // Add first set
        let weightField = app.textFields.element(boundBy: 0)
        let repsField = app.textFields.element(boundBy: 1)
        let addSetButton = app.buttons["addSetButton"]

        weightField.tap()
        weightField.typeText("100")
        repsField.tap()
        repsField.typeText("10")
        addSetButton.tap()

        // Wait for set to appear
        sleep(1)

        // Add second set
        weightField.tap()
        weightField.typeText("100")
        repsField.tap()
        repsField.typeText("10")
        addSetButton.tap()

        sleep(1)

        // Verify Squat section exists
        let squatSection = app.otherElements.matching(NSPredicate(format: "label CONTAINS 'Squat'")).firstMatch
        XCTAssertTrue(squatSection.exists)

        // AC2: Switch to Bench Press and add 1 set
        selectExerciseButton.tap()
        createNewButton.waitForExistence(timeout: 2)
        createNewButton.tap()

        nameField.tap()
        nameField.typeText("Bench Press")

        // Select upperBody category
        let categoryPicker = app.pickers["mainCategoryPicker"]
        if categoryPicker.exists {
            categoryPicker.tap()
            app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "Upper Body")
        }

        saveButton.tap()

        // Add set for Bench Press
        sleep(1)
        weightField.tap()
        weightField.typeText("80")
        repsField.tap()
        repsField.typeText("8")
        addSetButton.tap()

        sleep(1)

        // AC3: Verify two sections exist
        let benchSection = app.otherElements.matching(NSPredicate(format: "label CONTAINS 'Bench Press'")).firstMatch
        XCTAssertTrue(benchSection.exists)

        // AC4: Current exercise label shows Bench Press
        XCTAssertTrue(selectedLabel.exists)
        XCTAssertTrue(app.staticTexts["Current: Bench Press"].exists)
    }

    func test_deleteSet_sectionDisappearsWhenEmpty() throws {
        // Given: A session with one exercise and one set
        let createButton = app.buttons["createTodayButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        createButton.tap()

        let firstSession = app.buttons.matching(identifier: "sessionRow_").firstMatch
        XCTAssertTrue(firstSession.waitForExistence(timeout: 5))
        firstSession.tap()

        // Select and create exercise
        let selectExerciseButton = app.buttons["openExercisePicker"]
        selectExerciseButton.tap()

        let createNewButton = app.buttons["createExerciseButton"]
        createNewButton.waitForExistence(timeout: 2)
        createNewButton.tap()

        let nameField = app.textFields["exerciseNameField"]
        nameField.tap()
        nameField.typeText("Test Exercise")

        let saveButton = app.buttons["saveExerciseButton"]
        saveButton.tap()

        // Add one set
        let weightField = app.textFields.element(boundBy: 0)
        let repsField = app.textFields.element(boundBy: 1)
        let addSetButton = app.buttons["addSetButton"]

        weightField.tap()
        weightField.typeText("50")
        repsField.tap()
        repsField.typeText("5")
        addSetButton.tap()

        sleep(1)

        // When: Swipe to delete the set
        let setRow = app.buttons.matching(identifier: "setRow_").firstMatch
        XCTAssertTrue(setRow.waitForExistence(timeout: 2))
        setRow.swipeLeft()

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        sleep(1)

        // Then: Section disappears (empty state shows)
        let emptyMessage = app.staticTexts["No sets yet. Add your first set below!"]
        XCTAssertTrue(emptyMessage.exists)
    }
}
