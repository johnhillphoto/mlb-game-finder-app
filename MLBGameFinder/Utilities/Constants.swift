import Foundation

enum Constants {
    static let apiBaseURL = "https://statsapi.mlb.com/api/v1"
    static let defaultTeamId = 147
    static let upcomingInitialPageSize = 6
    static let upcomingPageSize = 5
    static let completedPageSize = 20
    static let cacheTTL: TimeInterval = 300 // 5 minutes
}
