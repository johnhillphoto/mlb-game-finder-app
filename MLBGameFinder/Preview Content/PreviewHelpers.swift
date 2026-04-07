import SwiftUI

// MARK: - Preview Helpers

extension Game {
    static func preview(
        id: Int = 1,
        gameDate: Date = Date().addingTimeInterval(86400),
        state: GameState = .preview,
        detailedState: String = "Scheduled",
        homeTeamId: Int = 147,
        homeTeamName: String = "New York Yankees",
        homeTeamAbbr: String = "NYY",
        awayTeamId: Int = 110,
        awayTeamName: String = "Baltimore Orioles",
        awayTeamAbbr: String = "BAL",
        homeScore: Int? = nil,
        awayScore: Int? = nil,
        homeWinner: Bool? = nil,
        awayWinner: Bool? = nil,
        venueName: String = "Yankee Stadium",
        broadcasts: [Broadcast] = [
            Broadcast(name: "YES", type: "TV", language: "en", isNational: false)
        ]
    ) -> Game {
        Game(
            id: id,
            gameDate: gameDate,
            status: GameStatus(abstractGameState: state, detailedState: detailedState),
            homeTeam: TeamScore(
                team: TeamInfo(id: homeTeamId, name: homeTeamName, abbreviation: homeTeamAbbr),
                score: homeScore,
                isWinner: homeWinner
            ),
            awayTeam: TeamScore(
                team: TeamInfo(id: awayTeamId, name: awayTeamName, abbreviation: awayTeamAbbr),
                score: awayScore,
                isWinner: awayWinner
            ),
            venue: Venue(name: venueName),
            broadcasts: broadcasts
        )
    }

    static let previewUpcoming = Game.preview(
        id: 1,
        gameDate: Date().addingTimeInterval(86400)
    )

    static let previewLive = Game.preview(
        id: 2,
        gameDate: Date(),
        state: .live,
        detailedState: "In Progress"
    )

    static let previewCompleted = Game.preview(
        id: 3,
        gameDate: Date().addingTimeInterval(-86400),
        state: .final_,
        detailedState: "Final",
        homeScore: 5,
        awayScore: 3,
        homeWinner: true,
        awayWinner: false
    )
}
