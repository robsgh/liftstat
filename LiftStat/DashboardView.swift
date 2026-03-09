//
//  DashboardView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/8/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack {
                overviewStatsCard
            }
        }
    }

    private var overviewStatsCard: some View {
        let exercises = ["Bench Press", "Squats", "Deadlifts"]
        return VStack {
            Text("Recent PRs").font(.title.bold())
            LazyHStack {
                ForEach(exercises, id: \.self) { exercise in
                    StatCardView(title: "\(exercise)", metric: "100 lbs")
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
