//
//  StartWorkoutView.swift
//  LiftStat
//
//  Created by Rob Schmidt on 3/9/26.
//

import SwiftData
import SwiftUI

struct StartWorkoutSheet: View {
    @Query(sort: \WorkoutProgram.timestamp) var programs: [WorkoutProgram]
    @State private var selection: Int = 0

    var body: some View {
        let freeformNote =
            if programs.isEmpty {
                Text(
                    "You haven't created any programs yet, but you can still workout with a freeform workout!"
                )
            } else {
                Text("Who needs a program anyway?")
            }
        TabView(selection: $selection) {
            // MARK: Default Freeform Workout Option
            VStack {
                Text("Freeform Workout").font(.title.bold())
                freeformNote.font(
                    .subheadline
                ).padding(.horizontal, 40)
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
            .tag(0)
            
            // MARK: Programs and Exercises
            ForEach(
                Array(programs.enumerated()),
                id: \.element.persistentModelID
            ) { index, program in
                VStack {
                    Text("\(program.name)").font(.title.bold())
                    Text("\(program.note)").font(.subheadline)
                    Divider().padding()
                    ForEach(program.getDaysSorted) { programDay in
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
                .tag(index + 1)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .onAppear {
            selection = programs.isEmpty ? 0 : 1
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
        StartWorkoutSheet()
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
        StartWorkoutSheet()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }.modelContainer(container)
}
