import SwiftUI
import SwiftData
import Charts

struct StrengthTrendChartView: View {
    let prs: [PersonalRecord]

    private struct DataPoint: Identifiable {
        let id = UUID()
        let exerciseName: String
        let date: Date
        let e1RM: Double
    }

    private var dataPoints: [DataPoint] {
        let topExercises = DashboardStatsService.topExercisesByPRCount(prs: prs, limit: 3)
        return topExercises.flatMap { exercise in
            DashboardStatsService.e1RMTimeline(for: exercise, prs: prs, days: 90)
                .map { DataPoint(exerciseName: exercise.name, date: $0.date, e1RM: $0.e1RM) }
        }
    }

    var body: some View {
        let points = dataPoints
        let topExercises = DashboardStatsService.topExercisesByPRCount(prs: prs, limit: 3)
        let names = topExercises.map { $0.name }
        let colors: [Color] = [.accentColor, .neonPink, .electricCyan]

        VStack(alignment: .leading, spacing: 12) {
            Label("Strength Trends", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            if points.isEmpty {
                Text("Log more workouts to see trends")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                Chart {
                    ForEach(points) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1RM.displayWeightValue)
                        )
                        .foregroundStyle(by: .value("Exercise", point.exerciseName))

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1RM.displayWeightValue)
                        )
                        .foregroundStyle(by: .value("Exercise", point.exerciseName))
                    }
                }
                .chartForegroundStyleScale(
                    domain: names,
                    range: Array(colors.prefix(names.count))
                )
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxisLabel(Double.weightUnit)
                .frame(height: 200)
            }
        }
        .padding()
        .cardBackground()
    }
}

#Preview {
    let container = PreviewHelper.makeContainer()
    return StrengthTrendChartView(
        prs: try! container.mainContext.fetch(FetchDescriptor<PersonalRecord>())
    )
    .padding()
    .modelContainer(container)
}
