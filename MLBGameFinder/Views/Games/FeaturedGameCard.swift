import SwiftUI

// MARK: - FeaturedGameCard

/// A visually distinct card for the "Next Game" or first upcoming game.
struct FeaturedGameCard: View {
    let game: Game
    let teamId: Int
    @Environment(\.teamTheme) private var theme

    private var isHome: Bool { game.isHome(teamId: teamId) }
    private var opponent: TeamInfo { game.opponent(teamId: teamId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header label
            HStack {
                Label("Next Game", systemImage: "baseball")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.secondary)
                Spacer()
                if game.status.abstractGameState == .live {
                    LiveBadge()
                }
            }

            // Opponent + time
            VStack(alignment: .leading, spacing: 4) {
                Text("vs \(opponent.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(DateFormatting.fullDateTime(game.gameDate))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Divider().background(.white.opacity(0.3))

            // Bottom row
            HStack(spacing: 12) {
                LocationBadge(isHome: isHome)
                VenueLabel(venueName: game.venue.name)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                BroadcastPills(broadcasts: game.broadcasts)
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [theme.primaryDark, theme.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        "Next game: \(isHome ? "Home" : "Away") vs \(opponent.name), \(DateFormatting.fullDateTime(game.gameDate)), \(game.venue.name)"
    }
}
