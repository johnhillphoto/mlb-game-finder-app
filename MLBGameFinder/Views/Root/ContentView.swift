import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showTeamSelector = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Upcoming tab
            NavigationStack {
                UpcomingGamesView()
                    .toolbar { teamSelectorButton }
            }
            .tabItem {
                Label("Upcoming", systemImage: "calendar")
            }
            .tag(0)

            // Completed tab
            NavigationStack {
                CompletedGamesView()
                    .toolbar { teamSelectorButton }
            }
            .tabItem {
                Label("Results", systemImage: "checkmark.circle")
            }
            .tag(1)
        }
        .tint(appState.currentTheme.primary)
        .sheet(isPresented: $showTeamSelector) {
            TeamSelectorView()
        }
    }

    @ToolbarContentBuilder
    private var teamSelectorButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showTeamSelector = true
            } label: {
                HStack(spacing: 4) {
                    Text(appState.selectedTeam?.abbreviation ?? "MLB")
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .accessibilityLabel("Select team: \(appState.selectedTeam?.name ?? "MLB")")
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
