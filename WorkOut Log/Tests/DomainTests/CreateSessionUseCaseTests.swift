//
//  CreateSessionUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

// Tests/DomainTests/CreateSessionUseCaseTests.swift
import XCTest
@testable import workout_log

final class CreateSessionUseCaseTests: XCTestCase {
    func test_create_session_persists() async throws {
        let repo = InMemorySessionRepository()
        let usecase = CreateSessionUseCase(repo: repo)
        let s = try await usecase(date: Date(), note: "leg day")
        let fetched = try await repo.fetch(by: s.id)
        XCTAssertEqual(fetched?.note, "leg day")
    }
}
