//
//  DashboardView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/8/26.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @State private var showStartWorkoutSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                overviewStatsCard
            }
        }.safeAreaInset(edge: .bottom) {
            Button {
                $showStartWorkoutSheet.wrappedValue.toggle()
            } label: {
                Label("Start Workout", systemImage: "dumbbell.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.all, 10)
        }.sheet(isPresented: $showStartWorkoutSheet) {
            StartWorkoutView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var overviewStatsCard: some View {
        let exercises = ["Bench Press", "Squats", "Deadlifts"]
        return VStack {
            Text("Recent PRs").font(.title2.bold())
            LazyHStack {
                ForEach(exercises, id: \.self) { exercise in
                    StatCardView(title: "\(exercise)", metric: "100 lbs")
                }
            }.cardBackground()
        }
    }

}

#Preview("Without Program") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutProgram.self,
        configurations: config
    )

    return DashboardView().modelContainer(container)
}

#Preview("With Program") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutProgram.self,
        configurations: config
    )

    let pplProgram = WorkoutProgram(
        name: "PPL",
        note: "My preview PPL"
    )

    let day1 = WorkoutProgramDay(order: 0, name: "Push")
    let day2 = WorkoutProgramDay(order: 1, name: "Pull")
    let day3 = WorkoutProgramDay(order: 2, name: "Legs")

    day1.program = pplProgram
    day2.program = pplProgram
    day3.program = pplProgram

    container.mainContext.insert(pplProgram)

    return DashboardView().modelContainer(container)
}
