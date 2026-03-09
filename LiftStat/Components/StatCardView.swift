//
//  StatCardView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/8/26.
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let metric: String

    var body: some View {
        VStack {
            Text(self.metric).font(.largeTitle.bold())
            Text(self.title).font(.title3).fontWeight(.light)
        }.padding(.all, 10).cardBackground()
    }
}

#Preview {
    StatCardView(title: "Squat", metric: "100 lbs")
}
