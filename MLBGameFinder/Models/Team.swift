import Foundation

// MARK: - Division

enum Division: String, Sendable, Codable, CaseIterable, Hashable {
    case alEast = "AL East"
    case alCentral = "AL Central"
    case alWest = "AL West"
    case nlEast = "NL East"
    case nlCentral = "NL Central"
    case nlWest = "NL West"
}

// MARK: - MlbTeam

struct MlbTeam: Identifiable, Sendable, Codable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
    let division: Division
    let primaryHex: String
    let primaryLightHex: String
    let primaryDarkHex: String
    let secondaryHex: String
}

// MARK: - TeamStore

@MainActor
final class TeamStore {
    static let shared = TeamStore()

    let teams: [MlbTeam]
    let teamsByDivision: [Division: [MlbTeam]]

    private init() {
        guard let url = Bundle.main.url(forResource: "MLBTeams", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([MlbTeam].self, from: data)
        else {
            teams = []
            teamsByDivision = [:]
            return
        }
        teams = decoded.sorted { $0.name < $1.name }
        var grouped: [Division: [MlbTeam]] = [:]
        for team in decoded {
            grouped[team.division, default: []].append(team)
        }
        for key in grouped.keys {
            grouped[key]?.sort { $0.name < $1.name }
        }
        teamsByDivision = grouped
    }

    func team(id: Int) -> MlbTeam? {
        teams.first { $0.id == id }
    }
}
