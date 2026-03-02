import SwiftUI

struct PRCelebrationView: View {
    let exerciseName: String

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("New PR!")
                        .font(.headline.bold())
                    Text(exerciseName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 32)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    PRCelebrationView(exerciseName: "Barbell Squat")
}
