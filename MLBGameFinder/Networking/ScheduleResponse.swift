import Foundation

// MARK: - Raw API Response Types (Decodable)

struct ScheduleResponse: Decodable, Sendable {
    let dates: [DateEntry]
}

struct DateEntry: Decodable, Sendable {
    let date: String
    let games: [RawGame]
}

struct RawGame: Decodable, Sendable {
    let gamePk: Int
    let gameDate: String
    let status: RawGameStatus
    let teams: RawGameTeams
    let venue: RawVenue
    let broadcasts: [RawBroadcast]?

    enum CodingKeys: String, CodingKey {
        case gamePk, gameDate, status, teams, venue, broadcasts
    }
}

struct RawGameStatus: Decodable, Sendable {
    let abstractGameState: String
    let detailedState: String
}

struct RawGameTeams: Decodable, Sendable {
    let home: RawTeamEntry
    let away: RawTeamEntry
}

struct RawTeamEntry: Decodable, Sendable {
    let team: RawTeamInfo
    let score: Int?
    let isWinner: Bool?
}

struct RawTeamInfo: Decodable, Sendable {
    let id: Int
    let name: String
    let abbreviation: String?
}

struct RawVenue: Decodable, Sendable {
    let name: String?
}

struct RawBroadcast: Decodable, Sendable {
    let name: String
    let type: String?
    let language: String?
    let isNational: Bool?
}

// MARK: - Domain Mapping

extension RawGame {
    func toDomain() -> Game? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: gameDate)
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: gameDate)
        }
        guard let resolvedDate = date else { return nil }

        let state = GameState(rawValue: status.abstractGameState) ?? .preview

        let home = TeamScore(
            team: TeamInfo(id: teams.home.team.id,
                           name: teams.home.team.name,
                           abbreviation: teams.home.team.abbreviation ?? ""),
            score: teams.home.score,
            isWinner: teams.home.isWinner
        )
        let away = TeamScore(
            team: TeamInfo(id: teams.away.team.id,
                           name: teams.away.team.name,
                           abbreviation: teams.away.team.abbreviation ?? ""),
            score: teams.away.score,
            isWinner: teams.away.isWinner
        )

        let broadcastList: [Broadcast] = (broadcasts ?? [])
            .filter { ($0.language ?? "en") == "en" }
            .map {
                Broadcast(
                    name: $0.name,
                    type: $0.type ?? "TV",
                    language: $0.language ?? "en",
                    isNational: $0.isNational ?? false
                )
            }

        return Game(
            id: gamePk,
            gameDate: resolvedDate,
            status: GameStatus(abstractGameState: state, detailedState: status.detailedState),
            homeTeam: home,
            awayTeam: away,
            venue: Venue(name: venue.name ?? "TBD"),
            broadcasts: broadcastList
        )
    }
}
