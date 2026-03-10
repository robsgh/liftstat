//
//  DashboardView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/8/26.
//

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
                    Label("Start Workout", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.all, 10)
        }.sheet(isPresented: $showStartWorkoutSheet) {
            StartWorkoutView()
                .presentationDetents([.fraction(0.25)])
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

#Preview {
    DashboardView()
}
