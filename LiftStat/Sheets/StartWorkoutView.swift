//
//  StartWorkoutView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/9/26.
//

import SwiftData
import SwiftUI

struct StartWorkoutView: View {
    @Query var programs: [WorkoutProgram]

    var body: some View {
        if programs.isEmpty {
            VStack {
                Text("Freeform Workout").font(.title.bold())
                Text("No programs set yet, so this one will be ad-hoc").font(.subheadline)
                Divider().padding()
                Button {
                    //dismiss()
                } label: {
                    Label(
                        "Start Freeform Workout",
                        systemImage: "dumbbell.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.all, 10)
            }
        } else {
            TabView {
                ForEach(programs.sorted { $0.timestamp < $1.timestamp }) {
                    program in
                    VStack {
                        Text("\(program.name)").font(.title.bold())
                        Text("\(program.note)").font(.subheadline)
                        Divider().padding()
                        ForEach(program.getDaysSorted) {
                            programDay in
                            Button {
                                //dismiss()
                            } label: {
                                Label(
                                    "Start \(programDay.name) Day",
                                    systemImage: "dumbbell.fill"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .padding(.all, 10)
                        }
                    }
                }
            }.tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
}

#Preview("No Programs") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutProgram.self,
        configurations: config
    )

    return Color.clear.sheet(isPresented: .constant(true)) {
        StartWorkoutView()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }.modelContainer(container)
}

#Preview("Two Programs") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutProgram.self,
        configurations: config
    )

    let pplProgram = WorkoutProgram(
        name: "PPL",
        note: "My preview PPL"
    )
    let upperLower = WorkoutProgram(
        name: "Upper Lower",
        note: "Lazy upper lower split"
    )

    let day1 = WorkoutProgramDay(order: 0, name: "Push")
    let day2 = WorkoutProgramDay(order: 1, name: "Pull")
    let day3 = WorkoutProgramDay(order: 2, name: "Legs")
    let day4 = WorkoutProgramDay(order: 0, name: "Upper")
    let day5 = WorkoutProgramDay(order: 1, name: "Lower")

    day1.program = pplProgram
    day2.program = pplProgram
    day3.program = pplProgram

    day4.program = upperLower
    day5.program = upperLower

    container.mainContext.insert(pplProgram)
    container.mainContext.insert(upperLower)

    return Color.clear.sheet(isPresented: .constant(true)) {
        StartWorkoutView()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }.modelContainer(container)
}
