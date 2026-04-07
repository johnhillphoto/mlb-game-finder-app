import Foundation
import Observation

// MARK: - AppState

@Observable
@MainActor
final class AppState {
    /// Stored property – changes are observed by `@Observable`, persisted to UserDefaults.
    var selectedTeamId: Int {
        didSet {
            UserDefaults.standard.set(selectedTeamId, forKey: "selectedTeamId")
        }
    }

    init() {
        let stored = UserDefaults.standard.integer(forKey: "selectedTeamId")
        selectedTeamId = stored == 0 ? Constants.defaultTeamId : stored
    }

    var selectedTeam: MlbTeam? {
        TeamStore.shared.team(id: selectedTeamId)
    }

    var currentTheme: TeamTheme {
        if let team = selectedTeam {
            return TeamTheme(from: team)
        }
        return .default
    }
}
