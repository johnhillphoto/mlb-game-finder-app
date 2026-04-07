import SwiftUI

// MARK: - CompletedGamesView

struct CompletedGamesView: View {
    @State private var viewModel = CompletedGamesViewModel()
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
                    .accessibilityLabel("Loading completed games")
            } else if viewModel.games.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Completed Games",
                    systemImage: "checkmark.circle",
                    description: Text("No completed games found for the selected team.")
                )
                .padding(.top, 60)
            } else {
                GameListView(
                    games: viewModel.games,
                    teamId: appState.selectedTeamId,
                    displayMode: .completed,
                    isLoading: viewModel.isLoading,
                    hasMore: viewModel.hasMore,
                    totalGames: viewModel.totalGames,
                    onLoadMore: { await viewModel.loadNextPage() }
                ) {
                    EmptyView()
                }
                .padding(.top, 12)
            }
        }
        .refreshable {
            await viewModel.refresh(teamId: appState.selectedTeamId)
        }
        .task(id: appState.selectedTeamId) {
            await viewModel.load(teamId: appState.selectedTeamId)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CompletedGamesView()
            .environment(AppState())
    }
}
