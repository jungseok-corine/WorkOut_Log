//
//  DateAxisLabelBuilder.swift
//  WorkOut Log
//
//  Created by Claude on 18/10/2025.
//

import SwiftUI

/// Helper to build custom axis labels for Trends charts
struct DateAxisLabelBuilder {
    /// Creates a two-line label for Daily trend view:
    /// Top line: abbreviated month (e.g., "Oct")
    /// Bottom line: day of month (e.g., "9")
    @ViewBuilder
    static func dailyTwoLine(date: Date) -> some View {
        VStack(spacing: 0) {
            // Top: month (short, secondary color)
            Text(date, format: .dateTime.month(.abbreviated))
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Bottom: day (emphasized)
            Text(date, format: .dateTime.day())
                .font(.caption2)
        }
        // Accessibility: combine into single label for VoiceOver
        .accessibilityLabel(
            Text(date, format: .dateTime.month(.wide).day())
        )
    }
}
