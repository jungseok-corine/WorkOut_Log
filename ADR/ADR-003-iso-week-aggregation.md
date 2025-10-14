# ADR-003: ISO Week Calendar for Volume Aggregation

**Status**: Accepted
**Date**: 2025-10-14
**Decision Makers**: iOS Development Team

## Context

WorkOut Log's Week 2 analytics features require consistent weekly and monthly volume aggregation. The app needs to group workout data by time periods that align with user expectations and provide meaningful progress tracking. Different calendar systems (Gregorian weeks, ISO weeks, fiscal periods) have different implications for data consistency and user experience.

## Decision

We will use **ISO 8601 week calendar system** for all weekly volume aggregations and analytics features.

## Rationale

### Why ISO Weeks

1. **Consistent Week Definition**
   - Week always starts on Monday (ISO 8601 standard)
   - Each week has exactly 7 days
   - Week 1 contains January 4th of the year
   - No partial weeks at year boundaries

2. **International Standard**
   - Widely adopted across fitness and analytics applications
   - Consistent across different locales and regions
   - Aligns with business and scientific reporting standards

3. **Data Integrity**
   - Fixed 52-53 week year structure
   - Predictable week boundaries for aggregation queries
   - No ambiguity in week start/end dates

4. **User Experience Benefits**
   - Monday start aligns with common workout week planning
   - Consistent "week over week" comparisons
   - No confusion around weekend workout categorization

## Implementation

### Core Implementation
```swift
extension ComputeVolumesByCategoryUseCase {
    func currentWeekRange() -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .iso8601)
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekInterval.start)!
        return (start: weekInterval.start, end: weekEnd)
    }

    func weekRange(weeksAgo: Int) -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .iso8601)
        let targetDate = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: Date())!
        return currentWeekRange(for: targetDate)
    }
}
```

### Analytics Queries
```swift
// Weekly volume comparison
let thisWeek = try await computeVolumesByCategory.currentWeek()
let lastWeek = try await computeVolumesByCategory.weekRange(weeksAgo: 1)

// Month-over-month using ISO week boundaries
let currentMonth = try await computeVolumesByCategory.currentMonthRange()
let lastMonth = try await computeVolumesByCategory.monthRange(monthsAgo: 1)
```

### Date Range Calculation
```swift
// ISO Week boundaries are always Monday 00:00 to next Monday 00:00
// Example: Week containing 2025-10-14 (Tuesday)
// Start: 2025-10-13 00:00 (Monday)
// End:   2025-10-20 00:00 (next Monday)

let calendar = Calendar(identifier: .iso8601)
let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())!
// weekInterval.start = Monday 00:00
// weekInterval.end = next Monday 00:00 (7 days later)
```

## Alternatives Considered

### Gregorian Calendar (Sunday Start)
**Pros**: Default iOS calendar system, familiar to US users
**Cons**: Week boundaries split typical workout routines, Sunday start feels unnatural for fitness tracking
**Example**: Week 2025-10-13 to 2025-10-19 would be Sunday-Saturday
**Verdict**: Rejected - poor UX for fitness context

### Custom Week (Configurable Start Day)
**Pros**: User preference accommodation, flexible scheduling
**Cons**: Complex implementation, data aggregation complications, comparison difficulties between users
**Implementation Complexity**: High - requires user preference storage and complex date calculations
**Verdict**: Rejected - unnecessary complexity for marginal benefit

### Fiscal Week (Business Calendar)
**Pros**: Aligns with some corporate fitness programs
**Cons**: Varies by organization, not standardized, irrelevant for personal fitness tracking
**Use Cases**: Very limited to enterprise fitness apps
**Verdict**: Rejected - not applicable to personal workout tracking

### Rolling 7-Day Periods
**Pros**: Always includes exactly 7 recent days, smooth data transitions
**Cons**: No fixed boundaries for week-over-week comparisons, difficult to communicate progress
**Example**: "Last 7 days" vs "This week" - different meaning and UX
**Verdict**: Deferred - consider as supplementary feature, not primary aggregation

## Trade-offs

### Accepted Trade-offs
1. **Regional Variation**: US users may expect Sunday-start weeks
2. **Learning Curve**: Some users need to adapt to Monday-start week concept
3. **Year Boundary Complexity**: ISO weeks can span calendar years (e.g., Week 1 may include late December)

### Mitigations
1. **Clear Labeling**: UI shows "Week of Oct 13" (Monday date) for clarity
2. **Contextual Help**: Tooltip explaining Monday-start week system
3. **Visual Indicators**: Calendar views highlight current ISO week boundaries

### Benefits Gained
1. **Consistency**: Same week definition across all features and analytics
2. **Standards Compliance**: Aligns with international fitness and business standards
3. **Data Quality**: Clean aggregation boundaries with no edge cases
4. **User Clarity**: "This week" always means the same 7-day period

## Impact on Features

### Week 2 Analytics
- **Volume Charts**: Weekly aggregation by muscle group categories
- **Progress Tracking**: Week-over-week volume and PR comparisons
- **Recent Activity**: "This week's workouts" list with consistent boundaries

### Future Features (Week 3+)
- **Weekly Goals**: Set and track weekly volume targets
- **Streak Tracking**: Consecutive weeks with workouts
- **Export Reports**: Weekly summaries for sharing or backup

## Implementation Examples

### Volume Aggregation Query
```swift
// Get current ISO week volume by category
let weekRange = computeVolumesByCategory.currentWeekRange()
let weeklyVolumes = try await computeVolumesByCategory(
    start: weekRange.start,
    end: weekRange.end
)

// Result: [CategoryVolume] with consistent Monday-Sunday data
// Example: Week of Oct 13, 2025 (Mon) to Oct 20, 2025 (Mon)
```

### UI Display
```swift
struct WeeklyStatsView: View {
    var body: some View {
        VStack {
            Text("Week of \(weekStart.formatted(.dateTime.weekday().month().day()))")
                .font(.headline)
            // Shows: "Week of Monday, Oct 13"

            List(categoryVolumes) { volume in
                HStack {
                    Text(volume.category.name)
                    Spacer()
                    Text("\(volume.totalVolume, format: .number) kg")
                }
            }
        }
    }
}
```

### Testing Consistency
```swift
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
```

## Success Metrics

### Data Consistency
- **Aggregation Accuracy**: 100% of weekly queries use consistent ISO boundaries
- **Edge Case Handling**: Proper year-boundary week handling (Week 1, Week 53)
- **Performance**: Weekly range calculations under 10ms

### User Experience
- **Clarity**: User research shows 90%+ understanding of "current week" concept
- **Adoption**: Weekly analytics features used by 70%+ of active users
- **Satisfaction**: Positive feedback on consistent week-over-week comparisons

## Technical Implementation

### Calendar Configuration
```swift
// Singleton calendar instance for consistency
extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}

// Usage throughout the app
let weekInterval = Calendar.iso8601.dateInterval(of: .weekOfYear, for: date)
```

### SwiftData Query Integration
```swift
// Fetch sessions within ISO week boundaries
let predicate = #Predicate<WorkoutSessionModel> { session in
    session.date >= weekStart && session.date < weekEnd
}
```

---

**Last Updated**: 2025-10-14
**Next Review**: Week 2 analytics implementation completion