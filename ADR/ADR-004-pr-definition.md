# ADR-004: Personal Record Definition and Calculation Method

**Status**: Accepted
**Date**: 2025-10-14
**Decision Makers**: iOS Development Team

## Context

WorkOut Log's Week 2 features include Personal Record (PR) tracking for strength progression analysis. The app needs a consistent definition of what constitutes a "personal record" and how to compare different weight/rep combinations for the same exercise. Multiple approaches exist for defining and calculating PRs, each with different implications for user motivation and accuracy.

## Decision

We will define **Personal Records (PRs) as maximum weight lifted** for any given exercise, with **Epley Formula estimation for 1RM comparisons** when determining new PRs across different rep ranges.

## Primary PR Definition

### Maximum Weight Approach
A Personal Record is the **highest weight successfully lifted** for a given exercise, regardless of repetition count.

```swift
public struct PersonalRecord: Sendable, Equatable {
    public let exerciseID: String
    public let maxWeight: Double        // Primary PR metric
    public let repsAtMaxWeight: Int     // Context for the max weight
    public let estimatedOneRM: Double   // Epley formula calculation
    public let achievedDate: Date       // When the PR was set
}
```

### Rationale for Max Weight Priority
1. **Simplicity**: Clear, unambiguous metric that users understand immediately
2. **Motivation**: Visible progress even when working in different rep ranges
3. **Practicality**: Aligns with common gym culture and strength training goals
4. **Data Integrity**: Objective measurement without complex calculations

## 1RM Estimation for PR Comparison

### Epley Formula Implementation
When determining if a new set qualifies as a PR, we use the Epley formula to compare estimated 1RM values:

```
Estimated 1RM = Weight × (1 + Reps ÷ 30)
```

### Implementation
```swift
extension ComputePRUseCase {
    func isNewPR(exerciseID: String, weight: Double, reps: Int) async throws -> Bool {
        guard let currentPR = try await self(exerciseID: exerciseID) else {
            return true // First time doing this exercise
        }

        // Check if higher weight (primary criterion)
        if weight > currentPR.maxWeight {
            return true
        }

        // If same or lower weight, check estimated 1RM
        let newEstimated1RM = weight * (1 + Double(reps) / 30.0)
        return newEstimated1RM > currentPR.estimatedOneRM
    }

    private func calculate1RM(weight: Double, reps: Int) -> Double {
        return weight * (1 + Double(reps) / 30.0)
    }
}
```

### PR Detection Logic
1. **New Weight PR**: Any weight higher than previous maximum
2. **New 1RM PR**: Higher estimated 1RM using Epley formula
3. **First Exercise**: Any first successful set counts as initial PR

## Alternatives Considered

### Volume-Based PR (Weight × Reps)
**Pros**: Rewards high-volume work, simple calculation
**Cons**: Misleading comparisons (100kg×1 vs 50kg×10), doesn't reflect strength gains
**Example**: 80kg × 10 reps = 800 volume vs 120kg × 5 reps = 600 volume
**Verdict**: Rejected - volume and strength are different metrics

### Multiple PR Categories
**Pros**: Comprehensive tracking (1RM, 3RM, 5RM, 10RM PRs), appeals to powerlifters
**Cons**: Complex UI, overwhelming for casual users, data fragmentation
**Implementation Complexity**: High - requires separate tracking for each rep range
**Verdict**: Rejected - over-engineering for general fitness app

### User-Configurable PR Definition
**Pros**: Accommodates different training philosophies and user preferences
**Cons**: Complex implementation, inconsistent data across users, poor UX
**Data Implications**: Difficult aggregation and comparison features
**Verdict**: Rejected - complexity outweighs flexibility benefits

### Wilks Score or Relative Strength
**Pros**: Accounts for bodyweight differences, competitive powerlifting alignment
**Cons**: Requires body weight tracking, complex calculation, not intuitive for casual users
**Prerequisites**: Body weight data for every PR calculation
**Verdict**: Deferred - consider for advanced analytics features

### Time-Based PRs (Recent vs All-Time)
**Pros**: Shows recent progress, motivating for comeback scenarios
**Cons**: Confusing definitions, requires time period selection, data complexity
**UX Impact**: "What's my PR?" becomes ambiguous question
**Verdict**: Deferred - consider as filtered view, not primary definition

## Epley Formula Justification

### Why Epley Over Alternatives

1. **Accuracy**: Research-validated for 1RM estimation in 1-10 rep range
2. **Simplicity**: Linear formula easy to compute and understand
3. **Conservative**: Tends to underestimate rather than overestimate
4. **Industry Standard**: Widely used in fitness apps and strength training

### Alternative Formulas Considered

**Brzycki Formula**: `1RM = Weight ÷ (1.0278 - 0.0278 × Reps)`
- More complex calculation
- Similar accuracy to Epley
- Less commonly recognized

**Lombardi Formula**: `1RM = Weight × Reps^0.10`
- Requires exponential calculation
- Good for higher rep ranges
- Computationally more expensive

### Epley Formula Validation
```swift
func test_epleyFormula_accuracy() {
    let testCases: [(weight: Double, reps: Int, expected1RM: Double)] = [
        (100, 1, 103.33),    // 100 * (1 + 1/30) = 103.33
        (90, 5, 105.0),      // 90 * (1 + 5/30) = 105.0
        (80, 10, 106.67),    // 80 * (1 + 10/30) = 106.67
        (70, 15, 105.0)      // 70 * (1 + 15/30) = 105.0
    ]

    for testCase in testCases {
        let calculated = testCase.weight * (1 + Double(testCase.reps) / 30.0)
        XCTAssertEqual(calculated, testCase.expected1RM, accuracy: 0.01)
    }
}
```

## Trade-offs

### Accepted Trade-offs
1. **Rep Range Bias**: Favors strength over endurance achievements
2. **Formula Limitations**: Epley accuracy decreases above 15 reps
3. **Context Loss**: Max weight PR doesn't show full training context

### Mitigations
1. **Rep Context**: Store and display reps achieved at max weight
2. **Multiple Views**: Show both max weight and recent PRs
3. **Progressive Indicators**: Highlight improvement trends beyond just PRs

### Benefits Gained
1. **Clarity**: Unambiguous "strongest I've ever been" metric
2. **Motivation**: Clear goals and progress indicators
3. **Comparison**: Fair evaluation across different rep ranges
4. **Simplicity**: Easy to understand and communicate

## UI Implementation

### PR Display
```swift
struct PRIndicatorView: View {
    let pr: PersonalRecord

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("💪 PR: \(pr.maxWeight, format: .number) kg")
                    .font(.headline)
                Spacer()
                Text("×\(pr.repsAtMaxWeight)")
                    .foregroundStyle(.secondary)
            }

            Text("Est. 1RM: \(pr.estimatedOneRM, format: .number) kg")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Set on \(pr.achievedDate.formatted(.dateTime.month().day()))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
```

### New PR Celebration
```swift
struct NewPRCelebrationView: View {
    let exercise: String
    let newWeight: Double
    let oldWeight: Double

    var body: some View {
        VStack {
            Text("🎉 NEW PR!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(exercise)
                .font(.title2)

            HStack {
                Text("\(oldWeight, format: .number) kg")
                    .strikethrough()
                    .foregroundStyle(.secondary)
                Text("→")
                Text("\(newWeight, format: .number) kg")
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            .font(.title)
        }
        .accessibilityLabel("New personal record: \(exercise), \(newWeight) kilograms")
    }
}
```

## Data Model Integration

### Repository Methods
```swift
extension SessionRepository {
    func findPR(exerciseID: String) async throws -> PersonalRecord? {
        // Find all sets for the exercise
        let sets = try await fetchAllSets(exerciseID: exerciseID)

        guard !sets.isEmpty else { return nil }

        // Find max weight set
        let maxWeightSet = sets.max { $0.weight < $1.weight }!

        // Calculate Epley 1RM for max weight set
        let estimatedOneRM = maxWeightSet.weight * (1 + Double(maxWeightSet.reps) / 30.0)

        return PersonalRecord(
            exerciseID: exerciseID,
            maxWeight: maxWeightSet.weight,
            repsAtMaxWeight: maxWeightSet.reps,
            estimatedOneRM: estimatedOneRM,
            achievedDate: maxWeightSet.session.date
        )
    }
}
```

### Analytics Integration
```swift
// Weekly PR summary
let thisWeekPRs = try await computePRsByCategory.newPRsInRange(
    start: weekRange.start,
    end: weekRange.end
)

// Month-over-month PR comparison
let monthlyPRProgress = try await computePRsByCategory.prProgressInRange(
    start: monthRange.start,
    end: monthRange.end
)
```

## Success Metrics

### User Engagement
- **PR Celebrations**: Track frequency of new PR achievements
- **Feature Usage**: Percentage of users who view PR screens
- **Motivation Impact**: Session frequency after PR achievements

### Data Quality
- **Calculation Accuracy**: Epley formula computation correctness
- **Performance**: PR queries under 100ms for exercise history
- **Consistency**: Zero discrepancies in PR calculations

## Implementation Status

**Week 1**: ✅ Foundation Complete
- Basic SetRecord tracking with weight/reps
- Domain entities supporting PR calculation

**Week 2**: 🚧 In Progress
- ComputePRUseCase implementation
- PR detection logic
- UI components for PR display

**Week 3**: 📋 Planned Features
- PR trends and analytics
- Historical PR progression charts
- Advanced PR categories (optional)

---

**Last Updated**: 2025-10-14
**Next Review**: End of Week 2 PR feature implementation