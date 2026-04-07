import SwiftUI

// MARK: - DisplayMode

enum GameCardDisplayMode {
    case upcoming
    case completed
}

// MARK: - GameCardView

struct GameCardView: View {
    let game: Game
    let teamId: Int
    let displayMode: GameCardDisplayMode
    @Environment(\.teamTheme) private var theme

    private var isHome: Bool { game.isHome(teamId: teamId) }
    private var opponent: TeamInfo { game.opponent(teamId: teamId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top row: badges
            HStack(spacing: 8) {
                if game.status.abstractGameState == .live {
                    LiveBadge()
                }
                LocationBadge(isHome: isHome)
                if displayMode == .completed, let win = game.isWinner(teamId: teamId) {
                    ResultBadge(isWin: win)
                }
                Spacer()
                Text(DateFormatting.relativeDate(game.gameDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Matchup row
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("vs \(opponent.name)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(opponent.abbreviation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if displayMode == .completed,
                   let myScore = game.score(teamId: teamId),
                   let oppScore = game.opponentScore(teamId: teamId) {
                    scoreView(myScore: myScore, oppScore: oppScore)
                } else if displayMode == .upcoming {
                    Text(DateFormatting.gameTime(game.gameDate))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.primary)
                }
            }

            // Bottom row: venue + broadcasts
            HStack(spacing: 12) {
                VenueLabel(venueName: game.venue.name)
                Spacer()
                BroadcastPills(broadcasts: game.broadcasts)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    @ViewBuilder
    private func scoreView(myScore: Int, oppScore: Int) -> some View {
        HStack(spacing: 4) {
            Text("\(myScore)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(theme.primary)
            Text("-")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("\(oppScore)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append(isHome ? "Home game vs \(opponent.name)" : "Away game at \(opponent.name)")
        switch displayMode {
        case .upcoming:
            parts.append("on \(DateFormatting.fullDateTime(game.gameDate))")
        case .completed:
            if let win = game.isWinner(teamId: teamId) {
                parts.append(win ? "Won" : "Lost")
            }
            if let my = game.score(teamId: teamId), let opp = game.opponentScore(teamId: teamId) {
                parts.append("\(my) to \(opp)")
            }
        }
        parts.append("at \(game.venue.name)")
        return parts.joined(separator: ", ")
    }
}
