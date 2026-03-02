import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WorkoutTabView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }

            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
