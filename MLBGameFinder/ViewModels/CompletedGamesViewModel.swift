import Foundation
import Observation

// MARK: - CompletedGamesViewModel

@Observable
@MainActor
final class CompletedGamesViewModel {
    private(set) var games: [Game] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var usingMockData = false
    private(set) var currentPage = 0
    private(set) var totalGames = 0

    private var allGames: [Game] = []
    private let repository: any GameRepository

    init(repository: any GameRepository = LiveGameRepository.shared) {
        self.repository = repository
    }

    var hasMore: Bool {
        games.count < totalGames
    }

    var showingCount: Int { games.count }

    func load(teamId: Int) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        usingMockData = false
        do {
            allGames = try await repository.fetchCompletedGames(teamId: teamId)
        } catch {
            allGames = (try? await MockGameRepository.shared.fetchCompletedGames(teamId: teamId)) ?? []
            usingMockData = true
            self.error = allGames.isEmpty ? error : nil
        }
        totalGames = allGames.count
        currentPage = 0
        games = []
        appendPage()
        isLoading = false
    }

    func loadNextPage() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        appendPage()
        isLoading = false
    }

    func refresh(teamId: Int) async {
        error = nil
        usingMockData = false
        do {
            try await repository.refresh(teamId: teamId)
            allGames = try await repository.fetchCompletedGames(teamId: teamId)
        } catch {
            allGames = (try? await MockGameRepository.shared.fetchCompletedGames(teamId: teamId)) ?? []
            usingMockData = true
            self.error = allGames.isEmpty ? error : nil
        }
        totalGames = allGames.count
        currentPage = 0
        games = []
        appendPage()
    }

    // MARK: - Private

    private func appendPage() {
        let start = games.count
        let end = min(start + Constants.completedPageSize, allGames.count)
        guard start < end else { return }
        games.append(contentsOf: allGames[start..<end])
        currentPage += 1
    }
}
