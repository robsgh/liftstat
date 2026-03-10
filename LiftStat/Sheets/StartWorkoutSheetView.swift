//
//  StartWorkoutSheetView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/9/26.
//

import SwiftUI

struct StartWorkoutSheetView: View {
    var body: some View {
        VStack {
            Text("Placeholder").font(.title.bold())
            Button {
                //dismiss()
            } label: {
                Label("Start Workout", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.all, 10)
        }
    }
}

#Preview {
    
}
