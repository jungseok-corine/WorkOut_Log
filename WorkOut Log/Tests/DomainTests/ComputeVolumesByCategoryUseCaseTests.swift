//
//  ComputeVolumesByCategoryUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class ComputeVolumesByCategoryUseCaseTests: XCTestCase {
    var mockSessionRepo: MockSessionRepository!
    var mockExerciseRepo: MockExerciseRepository!
    var useCase: ComputeVolumesByCategoryUseCase!

    override func setUpWithError() throws {
        mockSessionRepo = MockSessionRepository()
        mockExerciseRepo = MockExerciseRepository()
        useCase = ComputeVolumesByCategoryUseCase(
            sessionRepo: mockSessionRepo,
            exerciseRepo: mockExerciseRepo
        )
    }

    func test_computeVolumesByCategory_groupsByCategory() async throws {
        // Given
        let session1 = WorkoutSession(id: "s1", date: Date(), note: nil)
        let session2 = WorkoutSession(id: "s2", date: Date(), note: nil)

        let chestExercise = Exercise(id: "e1", name: "Bench Press", main: .upperBody)
        let legExercise = Exercise(id: "e2", name: "Squat", main: .lowerBody)

        let sets = [
            SetRecord(id: "set1", sessionID: "s1", exerciseID: "e1", weight: 80, reps: 10, order: 0), // 800
            SetRecord(id: "set2", sessionID: "s1", exerciseID: "e1", weight: 85, reps: 8, order: 1),  // 680
            SetRecord(id: "set3", sessionID: "s2", exerciseID: "e2", weight: 100, reps: 5, order: 0)  // 500
        ]

        // Setup mocks
        mockSessionRepo.mockSessions = [session1, session2]
        mockSessionRepo.mockSets = [
            "s1": [sets[0], sets[1]],
            "s2": [sets[2]]
        ]
        mockExerciseRepo.mockAllResults = [chestExercise, legExercise]

        // When
        let start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let end = Date()
        let volumes = try await useCase(start: start, end: end)

        // Then
        XCTAssertEqual(volumes.count, 2)

        let upperVolume = volumes.first { $0.category == .upperBody }
        let lowerVolume = volumes.first { $0.category == .lowerBody }

        XCTAssertEqual(upperVolume?.totalVolume, 1480) // 800 + 680
        XCTAssertEqual(lowerVolume?.totalVolume, 500)

        // Should be sorted by volume (highest first)
        XCTAssertEqual(volumes[0].totalVolume, 1480)
        XCTAssertEqual(volumes[1].totalVolume, 500)
    }

    func test_currentWeekRange_usesISOWeek() {
        // When
        let range = useCase.currentWeekRange()

        // Then
        let calendar = Calendar(identifier: .iso8601)
        let expectedStart = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        let expectedEnd = calendar.date(byAdding: .day, value: 7, to: expectedStart)!

        XCTAssertEqual(range.start.timeIntervalSince1970, expectedStart.timeIntervalSince1970, accuracy: 60)
        XCTAssertEqual(range.end.timeIntervalSince1970, expectedEnd.timeIntervalSince1970, accuracy: 60)
    }

    func test_currentMonthRange_usesCalendarMonth() {
        // When
        let range = useCase.currentMonthRange()

        // Then
        let calendar = Calendar.current
        let expectedStart = calendar.dateInterval(of: .month, for: Date())!.start
        let expectedEnd = calendar.date(byAdding: .month, value: 1, to: expectedStart)!

        XCTAssertEqual(range.start.timeIntervalSince1970, expectedStart.timeIntervalSince1970, accuracy: 60)
        XCTAssertEqual(range.end.timeIntervalSince1970, expectedEnd.timeIntervalSince1970, accuracy: 60)
    }
}

// MARK: - Mock Session Repository

class MockSessionRepository: SessionRepository {
    var mockSessions: [WorkoutSession] = []
    var mockSets: [String: [SetRecord]] = [:]

    func create(session: WorkoutSession) async throws {
        mockSessions.append(session)
    }

    func update(session: WorkoutSession) async throws {
        if let index = mockSessions.firstIndex(where: { $0.id == session.id }) {
            mockSessions[index] = session
        }
    }

    func delete(sessionID: String) async throws {
        mockSessions.removeAll { $0.id == sessionID }
        mockSets.removeValue(forKey: sessionID)
    }

    func fetch(by id: String) async throws -> WorkoutSession? {
        return mockSessions.first { $0.id == id }
    }

    func fetchAll() async throws -> [WorkoutSession] {
        return mockSessions.sorted { $0.date > $1.date || ($0.date == $1.date && $0.id < $1.id) }
    }

    func fetchRange(start: Date, end: Date) async throws -> [WorkoutSession] {
        return mockSessions.filter { $0.date >= start && $0.date < end }
    }

    func latest() async throws -> WorkoutSession? {
        return mockSessions.max { $0.date < $1.date }
    }

    func add(set: SetRecord) async throws {
        mockSets[set.sessionID, default: []].append(set)
    }

    func update(set: SetRecord) async throws {
        if var sets = mockSets[set.sessionID],
           let index = sets.firstIndex(where: { $0.id == set.id }) {
            sets[index] = set
            mockSets[set.sessionID] = sets
        }
    }

    func deleteSet(id: String) async throws {
        for sessionID in mockSets.keys {
            mockSets[sessionID]?.removeAll { $0.id == id }
        }
    }

    func fetchSets(sessionID: String) async throws -> [SetRecord] {
        return mockSets[sessionID, default: []].sorted { $0.order < $1.order }
    }
}