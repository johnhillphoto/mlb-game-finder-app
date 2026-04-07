import Foundation

// MARK: - GameState

enum GameState: String, Sendable, Codable {
    case preview = "Preview"
    case live = "Live"
    case final_ = "Final"
}

// MARK: - GameStatus

struct GameStatus: Sendable, Codable {
    let abstractGameState: GameState
    let detailedState: String
}

// MARK: - TeamInfo

struct TeamInfo: Identifiable, Sendable, Codable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
}

// MARK: - TeamScore

struct TeamScore: Sendable, Codable {
    let team: TeamInfo
    let score: Int?
    let isWinner: Bool?
}

// MARK: - Game

struct Game: Identifiable, Sendable, Codable {
    let id: Int          // gamePk
    let gameDate: Date
    let status: GameStatus
    let homeTeam: TeamScore
    let awayTeam: TeamScore
    let venue: Venue
    let broadcasts: [Broadcast]

    func isHome(teamId: Int) -> Bool {
        homeTeam.team.id == teamId
    }

    func opponent(teamId: Int) -> TeamInfo {
        isHome(teamId: teamId) ? awayTeam.team : homeTeam.team
    }

    func isWinner(teamId: Int) -> Bool? {
        if isHome(teamId: teamId) {
            return homeTeam.isWinner
        } else {
            return awayTeam.isWinner
        }
    }

    func score(teamId: Int) -> Int? {
        isHome(teamId: teamId) ? homeTeam.score : awayTeam.score
    }

    func opponentScore(teamId: Int) -> Int? {
        isHome(teamId: teamId) ? awayTeam.score : homeTeam.score
    }
}
