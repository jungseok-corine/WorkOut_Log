//
//  TrendsView.swift
//  WorkOut Log
//
//  Created by Claude on 15/10/2025.
//

import SwiftUI
import Charts

struct TrendsView: View {
    @State var vm: TrendsViewModel
    
    private let sundayStartCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // Sunday
        return c
    }()
    
    /// Accessibility label for the chart based on current scope
    private var accessibilityChartLabel: String {
        switch vm.scope {
        case .daily:
            return "Daily training volume trend"
        case .weekly:
            return "Weekly training volume trend"
        case .monthly:
            return "Monthly training volume trend"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Scope selector
                Picker("Scope", selection: $vm.scope) {
                    Text("Daily").tag(TrendScope.daily)
                        .accessibilityIdentifier("trendScopeDaily")
                    Text("Weekly").tag(TrendScope.weekly)
                        .accessibilityIdentifier("trendScopeWeekly")
                    Text("Monthly").tag(TrendScope.monthly)
                        .accessibilityIdentifier("trendScopeMonthly")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: vm.scope) { _, _ in
                    vm.scopeChanged()
                }
                
                // Show All Days toggle (only for Daily scope)
                if vm.scope == .daily {
                    Toggle("Show All Days", isOn: $vm.showAllDays)
                        .padding(.horizontal)
                        .accessibilityIdentifier("trendShowAllDaysToggle")
                        .onChange(of: vm.showAllDays) { _, _ in
                            vm.showAllDaysToggled()
                        }
                }
                
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All categories
                        Button {
                            vm.selectedCategory = nil
                            vm.categoryFilterChanged()
                        } label: {
                            Text("All")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(vm.selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(vm.selectedCategory == nil ? .white : .primary)
                                .cornerRadius(16)
                        }
                        .accessibilityIdentifier("categoryChip_all")
                        
                        ForEach(ExerciseCategoryMain.allCases, id: \.self) { category in
                            Button {
                                vm.selectedCategory = category
                                vm.categoryFilterChanged()
                            } label: {
                                Text(category.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(vm.selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(vm.selectedCategory == category ? .white : .primary)
                                    .cornerRadius(16)
                            }
                            .accessibilityIdentifier("categoryChip_\(category.rawValue)")
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Chart
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.trendData.isEmpty {
                    Text("No data available")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart(vm.trendData) { point in
                        LineMark(
                            x: .value("Period", point.date),
                            y: .value("Volume", point.volume)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Period", point.date),
                            y: .value("Volume", point.volume)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartXAxis {
                        switch vm.scope {
                        case .daily:
                            // Custom two-line labels for Daily: month / day
                            // Use stride to reduce label density when count is high
                            let strideCount = (vm.trendData.count > 8) ? 2 : 1
                            AxisMarks(values: .stride(by: .day, count: strideCount)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(content: {
                                    if let date = value.as(Date.self) {
                                        // Build accessibility label as explicit String
                                        let a11yLabel: String = date.formatted(.dateTime.month(.wide).day())
                                        VStack(spacing: 0) {
                                            // Top: month (short, secondary color)
                                            Text(date, format: .dateTime.month(.abbreviated))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            // Bottom: day (emphasized)
                                            Text(date, format: .dateTime.day())
                                                .font(.caption2)
                                                .bold()
                                        }
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(a11yLabel) // String overload only
                                    }
                                })
                            }
                        case .weekly:
                            // Custom two-line labels for Weekly: month / day range (Sun–Sat)
                            AxisMarks(values: vm.trendData.map { $0.date }) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(content: {
                                    if let weekStart = value.as(Date.self) {
                                        // Sunday-start calendar for week calculations
                                        let weekEnd = sundayStartCalendar.date(byAdding: .day, value: 6, to: weekStart)!
                                        let startDay = sundayStartCalendar.component(.day, from: weekStart)
                                        let endDay   = sundayStartCalendar.component(.day, from: weekEnd)
                                        // Accessibility label must be String or Text (not a closure)
                                        let a11yLabel: String =
                                        "\(weekStart.formatted(.dateTime.month(.wide).day())) to \(weekEnd.formatted(.dateTime.month(.wide).day()))"
                                        VStack(spacing: 0) {
                                            // Top: month of week start
                                            Text(weekStart, format: .dateTime.month(.abbreviated))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            // Bottom: day range (e.g., "6–12")
                                            Text("\(startDay)–\(endDay)")
                                                .font(.caption2)
                                                .bold()
                                        }
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(a11yLabel) // String overload only
                                    }
                                })
                            }
                        case .monthly:
                            // Standard single-line labels for Monthly
                            AxisMarks(values: vm.trendData.map { $0.date }) { value in
                                if let date = value.as(Date.self),
                                   let point = vm.trendData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                    AxisValueLabel(point.periodLabel)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let volume = value.as(Double.self) {
                                    Text("\(Int(volume))")
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    .accessibilityLabel(accessibilityChartLabel)
                }
                
                Spacer()
            }
            .navigationTitle("Trends")
            .task {
                vm.onAppear()
            }
        }
    }
}
