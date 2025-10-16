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
                        AxisMarks(values: vm.trendData.map { $0.date }) { value in
                            if let date = value.as(Date.self),
                               let point = vm.trendData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                AxisValueLabel(point.periodLabel)
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
