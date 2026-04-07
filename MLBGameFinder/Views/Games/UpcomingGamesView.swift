import SwiftUI

// MARK: - UpcomingGamesView

struct UpcomingGamesView: View {
    @State private var viewModel = UpcomingGamesViewModel()
    @Environment(\.teamTheme) private var theme
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            if let error = viewModel.error {
                ErrorBanner(message: error.localizedDescription)
                    .padding(.top)
            }

            if viewModel.usingMockData {
                MockDataBanner()
                    .padding(.top, viewModel.error == nil ? 8 : 4)
            }

            if viewModel.isLoading && viewModel.games.isEmpty {
                ProgressView("Loading games…")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .accessibilityLabel("Loading upcoming games")
            } else if viewModel.games.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Upcoming Games",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("There are no scheduled games for the selected team.")
                )
                .padding(.top, 60)
            } else {
                GameListView(
                    games: viewModel.games,
                    teamId: appState.selectedTeamId,
                    displayMode: .upcoming,
                    isLoading: viewModel.isLoading,
                    hasMore: viewModel.hasMore,
                    totalGames: viewModel.totalGames,
                    onLoadMore: { await viewModel.loadNextPage() }
                ) {
                    if let first = viewModel.games.first {
                        FeaturedGameCard(game: first, teamId: appState.selectedTeamId)
                            .padding(.horizontal)
                            .padding(.top, 12)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refresh(teamId: appState.selectedTeamId)
        }
        .task(id: appState.selectedTeamId) {
            await viewModel.load(teamId: appState.selectedTeamId)
        }
        .navigationTitle("Upcoming")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        UpcomingGamesView()
            .environment(AppState())
    }
}
