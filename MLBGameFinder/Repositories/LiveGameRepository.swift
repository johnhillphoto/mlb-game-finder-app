import Foundation

// MARK: - Cache Entry

private struct CacheEntry: Sendable {
    let games: [Game]
    let timestamp: Date

    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < Constants.cacheTTL
    }
}

// MARK: - Cache Key

private struct CacheKey: Hashable, Sendable {
    let teamId: Int
    let filter: GameFilter
}

private enum GameFilter: Hashable, Sendable {
    case upcoming
    case completed
    case all
}

// MARK: - LiveGameRepository

actor LiveGameRepository: GameRepository {
    nonisolated static let shared = LiveGameRepository()

    private let apiClient: any MLBAPIClientProtocol
    private var cache: [CacheKey: CacheEntry] = [:]

    init(apiClient: any MLBAPIClientProtocol = MLBAPIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - Public API

    func fetchUpcomingGames(teamId: Int) async throws -> [Game] {
        let key = CacheKey(teamId: teamId, filter: .upcoming)
        if let entry = cache[key], entry.isValid {
            return entry.games
        }
        let all = try await fetchAll(teamId: teamId)
        let now = Date()
        let upcoming = all
            .filter { $0.status.abstractGameState != .final_ }
            .filter { $0.gameDate >= now.startOfDay }
            .sorted { $0.gameDate < $1.gameDate }
        cache[key] = CacheEntry(games: upcoming, timestamp: Date())
        return upcoming
    }

    func fetchCompletedGames(teamId: Int) async throws -> [Game] {
        let key = CacheKey(teamId: teamId, filter: .completed)
        if let entry = cache[key], entry.isValid {
            return entry.games
        }
        let all = try await fetchAll(teamId: teamId)
        let completed = all
            .filter { $0.status.abstractGameState == .final_ }
            .sorted { $0.gameDate > $1.gameDate }
        cache[key] = CacheEntry(games: completed, timestamp: Date())
        return completed
    }

    func refresh(teamId: Int) async throws {
        // Invalidate all cache entries for this team
        cache = cache.filter { $0.key.teamId != teamId }
        // Pre-warm the cache
        _ = try await fetchAll(teamId: teamId)
    }

    // MARK: - Private

    private func fetchAll(teamId: Int) async throws -> [Game] {
        let key = CacheKey(teamId: teamId, filter: .all)
        if let entry = cache[key], entry.isValid {
            return entry.games
        }
        let calendar = Calendar.current
        let now = Date()
        // Fetch full season: April 1 – October 31 of current year
        let year = calendar.component(.year, from: now)
        let startDate = "\(year)-04-01"
        let endDate = "\(year)-10-31"

        let games = try await apiClient.fetchSchedule(
            teamId: teamId,
            startDate: startDate,
            endDate: endDate
        )
        cache[key] = CacheEntry(games: games, timestamp: Date())
        return games
    }
}

// MARK: - Date Helper

private extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
