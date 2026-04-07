import Foundation
import Observation

// MARK: - TeamSelectionViewModel

@Observable
@MainActor
final class TeamSelectionViewModel {
    private(set) var teamsByDivision: [Division: [MlbTeam]] = [:]
    private(set) var divisionOrder: [Division] = [
        .alEast, .alCentral, .alWest,
        .nlEast, .nlCentral, .nlWest
    ]
    var searchText: String = ""

    private var appState: AppState

    init(appState: AppState) {
        self.appState = appState
        teamsByDivision = TeamStore.shared.teamsByDivision
    }

    var selectedTeamId: Int {
        appState.selectedTeamId
    }

    var filteredTeamsByDivision: [Division: [MlbTeam]] {
        if searchText.isEmpty { return teamsByDivision }
        var result: [Division: [MlbTeam]] = [:]
        let lower = searchText.lowercased()
        for (division, teams) in teamsByDivision {
            let filtered = teams.filter {
                $0.name.lowercased().contains(lower) ||
                $0.abbreviation.lowercased().contains(lower)
            }
            if !filtered.isEmpty {
                result[division] = filtered
            }
        }
        return result
    }

    func selectTeam(_ team: MlbTeam) {
        appState.selectedTeamId = team.id
    }
}
