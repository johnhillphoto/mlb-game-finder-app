import Foundation

// MARK: - MockGameRepository

final class MockGameRepository: GameRepository, Sendable {
    nonisolated static let shared = MockGameRepository()

    private let games: [Game]

    init() {
        guard let url = Bundle.main.url(forResource: "MockSchedule", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            games = []
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: string) { return date }
            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(string)"
            )
        }
        guard let response = try? decoder.decode(ScheduleResponse.self, from: data) else {
            games = []
            return
        }
        games = response.dates
            .flatMap { $0.games }
            .compactMap { $0.toDomain() }
    }

    func fetchUpcomingGames(teamId: Int) async throws -> [Game] {
        let now = Date()
        return games
            .filter { $0.status.abstractGameState != .final_ }
            .filter { $0.gameDate >= Calendar.current.startOfDay(for: now) }
            .sorted { $0.gameDate < $1.gameDate }
    }

    func fetchCompletedGames(teamId: Int) async throws -> [Game] {
        games
            .filter { $0.status.abstractGameState == .final_ }
            .sorted { $0.gameDate > $1.gameDate }
    }

    func refresh(teamId: Int) async throws {
        // No-op for mock – data is static
    }
}
