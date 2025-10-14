import XCTest

final class SessionListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode", "1"]
        app.launch()
    }

    func test_createTodayButton_createsSession() throws {
        let createTodayButton = app.buttons["createTodayButton"]
        XCTAssertTrue(createTodayButton.exists, "Create Today button should exist")

        let initialSessionCount = app.tables.cells.count

        createTodayButton.tap()

        // Wait for the session to be created and UI to update
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "count > %d", initialSessionCount),
            object: app.tables.cells
        )
        wait(for: [expectation], timeout: 5.0)

        // Verify that a new session was created
        XCTAssertGreaterThan(app.tables.cells.count, initialSessionCount,
                           "A new session should be created after tapping Create Today button")
    }
}