import SwiftUI

// MARK: - GameListView

/// A generic paginated game list shared by upcoming and completed tabs.
struct GameListView<Header: View>: View {
    let games: [Game]
    let teamId: Int
    let displayMode: GameCardDisplayMode
    let isLoading: Bool
    let hasMore: Bool
    let totalGames: Int
    let onLoadMore: () async -> Void
    @ViewBuilder let header: () -> Header

    var body: some View {
        LazyVStack(spacing: 12, pinnedViews: []) {
            header()

            ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                GameCardView(game: game, teamId: teamId, displayMode: displayMode)
                    .padding(.horizontal)
                    .onAppear {
                        if index == games.count - 1 && hasMore {
                            Task { await onLoadMore() }
                        }
                    }
            }

            LoadingFooter(showing: games.count, total: totalGames, isLoading: isLoading && !games.isEmpty)
                .padding(.bottom, 20)
        }
    }
}
