//
//  StartWorkoutView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/9/26.
//

import SwiftUI

struct StartWorkoutView: View {
    var body: some View {
        TabView {
            VStack {
                Text("Placeholder 1").font(.title.bold())
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
            VStack {
                Text("Placeholder 2").font(.title.bold())
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
        }.tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        StartWorkoutView()
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
    }
}
