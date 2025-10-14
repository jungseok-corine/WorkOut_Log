//
//  BodyMetricUseCaseTests.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import XCTest
@testable import workout_log

final class BodyMetricUseCaseTests: XCTestCase {
    var mockRepo: MockBodyMetricRepository!
    var createUseCase: CreateBodyMetricUseCase!
    var fetchRangeUseCase: FetchBodyMetricsRangeUseCase!

    override func setUpWithError() throws {
        mockRepo = MockBodyMetricRepository()
        createUseCase = CreateBodyMetricUseCase(repo: mockRepo)
        fetchRangeUseCase = FetchBodyMetricsRangeUseCase(repo: mockRepo)
    }

    func test_createBodyMetric_withAllFields() async throws {
        // When
        let metric = try await createUseCase(
            date: Date(),
            bodyWeight: 75.0,
            bodyFatPercent: 15.0,
            muscleMass: 55.0
        )

        // Then
        XCTAssertEqual(metric.bodyWeight, 75.0)
        XCTAssertEqual(metric.bodyFatPercent, 15.0)
        XCTAssertEqual(metric.muscleMass, 55.0)
        XCTAssertFalse(metric.id.isEmpty)
        XCTAssertEqual(mockRepo.createdMetrics.count, 1)
    }

    func test_createBodyMetric_withOnlyRequiredFields() async throws {
        // When
        let metric = try await createUseCase(date: Date(), bodyWeight: 80.0)

        // Then
        XCTAssertEqual(metric.bodyWeight, 80.0)
        XCTAssertNil(metric.bodyFatPercent)
        XCTAssertNil(metric.muscleMass)
        XCTAssertFalse(metric.id.isEmpty)
    }

    func test_fetchBodyMetricsRange_returnsMetricsInRange() async throws {
        // Given
        let now = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        mockRepo.mockMetrics = [
            BodyMetric(id: "1", date: yesterday, bodyWeight: 75.0),
            BodyMetric(id: "2", date: now, bodyWeight: 76.0),
            BodyMetric(id: "3", date: tomorrow, bodyWeight: 77.0)
        ]

        // When
        let metrics = try await fetchRangeUseCase(start: yesterday, end: now)

        // Then
        XCTAssertEqual(metrics.count, 2) // yesterday and now, not tomorrow
        XCTAssertTrue(metrics.contains { $0.id == "1" })
        XCTAssertTrue(metrics.contains { $0.id == "2" })
        XCTAssertFalse(metrics.contains { $0.id == "3" })
    }

    func test_lastWeek_returnsMetricsFromLastWeek() async throws {
        // Given
        let now = Date()
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!

        mockRepo.mockMetrics = [
            BodyMetric(id: "1", date: weekAgo, bodyWeight: 75.0),
            BodyMetric(id: "2", date: now, bodyWeight: 76.0)
        ]

        // When
        let metrics = try await fetchRangeUseCase.lastWeek()

        // Then
        XCTAssertEqual(mockRepo.lastFetchStart?.timeIntervalSince1970, weekAgo.timeIntervalSince1970, accuracy: 60)
        XCTAssertEqual(mockRepo.lastFetchEnd?.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 60)
    }

    func test_lastMonth_returnsMetricsFromLastMonth() async throws {
        // Given
        let now = Date()
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!

        mockRepo.mockMetrics = [
            BodyMetric(id: "1", date: monthAgo, bodyWeight: 75.0),
            BodyMetric(id: "2", date: now, bodyWeight: 76.0)
        ]

        // When
        let metrics = try await fetchRangeUseCase.lastMonth()

        // Then
        XCTAssertEqual(mockRepo.lastFetchStart?.timeIntervalSince1970, monthAgo.timeIntervalSince1970, accuracy: 60)
        XCTAssertEqual(mockRepo.lastFetchEnd?.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 60)
    }

    func test_lastThreeMonths_returnsMetricsFromLastThreeMonths() async throws {
        // When
        _ = try await fetchRangeUseCase.lastThreeMonths()

        // Then
        let now = Date()
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!

        XCTAssertEqual(mockRepo.lastFetchStart?.timeIntervalSince1970, threeMonthsAgo.timeIntervalSince1970, accuracy: 60)
        XCTAssertEqual(mockRepo.lastFetchEnd?.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 60)
    }
}

// MARK: - Mock Body Metric Repository

class MockBodyMetricRepository: BodyMetricRepository {
    var createdMetrics: [BodyMetric] = []
    var mockMetrics: [BodyMetric] = []
    var lastFetchStart: Date?
    var lastFetchEnd: Date?

    func create(_ metric: BodyMetric) async throws {
        createdMetrics.append(metric)
    }

    func update(_ metric: BodyMetric) async throws {
        if let index = mockMetrics.firstIndex(where: { $0.id == metric.id }) {
            mockMetrics[index] = metric
        }
    }

    func delete(id: String) async throws {
        mockMetrics.removeAll { $0.id == id }
    }

    func fetch(by id: String) async throws -> BodyMetric? {
        return mockMetrics.first { $0.id == id }
    }

    func fetchRange(start: Date, end: Date) async throws -> [BodyMetric] {
        lastFetchStart = start
        lastFetchEnd = end
        return mockMetrics.filter { $0.date >= start && $0.date < end }
    }

    func latest() async throws -> BodyMetric? {
        return mockMetrics.max { $0.date < $1.date }
    }
}