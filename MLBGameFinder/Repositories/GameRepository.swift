import Foundation

// MARK: - GameRepository Protocol

protocol GameRepository: Sendable {
    func fetchUpcomingGames(teamId: Int) async throws -> [Game]
    func fetchCompletedGames(teamId: Int) async throws -> [Game]
    func refresh(teamId: Int) async throws
}
