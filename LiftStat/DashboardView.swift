//
//  DashboardView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/8/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var isSheet: Bool = true
    var body: some View {
        ScrollView {
            VStack {
                overviewStatsCard
            }
        }.sheet(isPresented: $isSheet) {
            StartWorkoutSheetView()
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
