import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }

            LogTabView()
                .tabItem {
                    Label("Log", systemImage: "clock.arrow.circlepath")
                }

            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
