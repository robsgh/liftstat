import SwiftUI

extension Color {
    /// Neon pink — PRs, celebrations, chart series 2
    static let neonPink = Color(red: 233/255, green: 30/255, blue: 140/255)

    /// Electric cyan — completed sets, positive diffs, chart series 3
    static let electricCyan = Color(red: 6/255, green: 182/255, blue: 212/255)
}

extension ShapeStyle where Self == Color {
    static var neonPink: Color { .neonPink }
    static var electricCyan: Color { .electricCyan }
}

extension View {
    func cardBackground() -> some View {
        self.background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor.opacity(0.15), lineWidth: 1)
                )
        }
    }
}
