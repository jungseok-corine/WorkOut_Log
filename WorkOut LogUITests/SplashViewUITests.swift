//
//  SplashViewUITests.swift
//  WorkOut LogUITests
//
//  Created by Claude on 16/10/2025.
//

import XCTest

final class SplashViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func test_splashView_appearsOnLaunch() throws {
        app.launch()

        // Verify splash elements exist
        let quoteText = app.staticTexts["splashQuoteText"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 2))

        let quoteAuthor = app.staticTexts["splashQuoteAuthor"]
        XCTAssertTrue(quoteAuthor.exists)

        // Verify splash has content
        XCTAssertFalse(quoteText.label.isEmpty)
        XCTAssertFalse(quoteAuthor.label.isEmpty)
    }

    func test_splashView_dismissesOnTap() throws {
        app.launch()

        // Wait for splash to appear
        let quoteText = app.staticTexts["splashQuoteText"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 2))

        // Tap to dismiss
        app.tap()

        // Wait for splash to disappear (should happen within 1 second after tap)
        let disappeared = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: disappeared, object: quoteText)
        let result = XCTWaiter.wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(result, .completed)
    }

    func test_splashView_autoDismisses() throws {
        app.launch()

        // Wait for splash to appear
        let quoteText = app.staticTexts["splashQuoteText"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 2))

        // Wait for auto-dismiss (should happen within 3-4 seconds)
        let disappeared = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: disappeared, object: quoteText)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
    }
}
