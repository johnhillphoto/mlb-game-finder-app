import SwiftUI

// MARK: - LocationBadge

struct LocationBadge: View {
    let isHome: Bool
    @Environment(\.teamTheme) private var theme

    var body: some View {
        Text(isHome ? "HOME" : "AWAY")
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(isHome ? theme.primary : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isHome
                    ? theme.primary.opacity(0.12)
                    : Color.secondary.opacity(0.12),
                in: Capsule()
            )
            .accessibilityLabel(isHome ? "Home game" : "Away game")
    }
}

#Preview {
    VStack {
        LocationBadge(isHome: true)
        LocationBadge(isHome: false)
    }
    .padding()
}
