import SwiftUI
import Charts

struct ExerciseHistoryView: View {
    let exercise: Exercise

    enum ChartMetric: String, CaseIterable {
        case maxWeight = "Max Weight"
        case e1RM = "e1RM"
    }

    @State private var chartMetric: ChartMetric = .maxWeight

    private struct Session: Identifiable {
        let id: UUID
        let date: Date
        let completedSets: [LoggedSet]

        var maxWeight: Double {
            completedSets.map { $0.weight }.max() ?? 0
        }

        var e1RM: Double {
            completedSets.compactMap { set -> Double? in
                guard set.weight > 0, set.reps > 0 else { return nil }
                return PRDetectionService.estimatedOneRepMax(weight: set.weight, reps: set.reps)
            }.max() ?? 0
        }

        var chartValue: Double { 0 } // placeholder; actual value injected at callsite
    }

    private var sessions: [Session] {
        let relevantWEs = (exercise.workoutExercises ?? [])
            .filter { $0.workout?.isActive == false }
            .sorted { ($0.workout?.startDate ?? .distantPast) > ($1.workout?.startDate ?? .distantPast) }

        return relevantWEs.compactMap { we -> Session? in
            guard let date = we.workout?.startDate else { return nil }
            let completed = we.sortedSets.filter { $0.isCompleted }
            guard !completed.isEmpty else { return nil }
            return Session(id: UUID(), date: date, completedSets: completed)
        }
    }

    private var allTimeBest: PersonalRecord? {
        (exercise.personalRecords ?? [])
            .sorted { $0.estimatedOneRepMax > $1.estimatedOneRepMax }
            .first
    }

    var body: some View {
        let sessionList = sessions
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // All-time PR header
                if let best = allTimeBest {
                    HStack {
                        Label("All-Time PR", systemImage: "star.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text("\(best.weight.displayWeight) × \(best.reps)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("e1RM: \(best.estimatedOneRepMax.displayWeight)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                }

                // Chart
                if !sessionList.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Metric", selection: $chartMetric) {
                            ForEach(ChartMetric.allCases, id: \.self) { metric in
                                Text(metric.rawValue).tag(metric)
                            }
                        }
                        .pickerStyle(.segmented)

                        Chart {
                            ForEach(sessionList) { session in
                                let value = chartMetric == .maxWeight ? session.maxWeight.displayWeightValue : session.e1RM.displayWeightValue
                                if sessionList.count > 1 {
                                    LineMark(
                                        x: .value("Date", session.date),
                                        y: .value(chartMetric.rawValue, value)
                                    )
                                    .foregroundStyle(.blue)
                                }
                                PointMark(
                                    x: .value("Date", session.date),
                                    y: .value(chartMetric.rawValue, value)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                        .chartYAxisLabel(Double.weightUnit)
                        .frame(height: 200)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                }

                // Session list
                if !sessionList.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sessions")
                            .font(.headline)

                        ForEach(sessionList) { session in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.date, style: .date)
                                    .font(.subheadline.bold())
                                ForEach(session.completedSets) { set in
                                    Text("\(set.weight.displayWeight) × \(set.reps)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log sets for \(exercise.name) to see progress here.")
                    )
                }
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
