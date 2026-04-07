import Foundation

// MARK: - MLBEndpoint

enum MLBEndpoint {
    case schedule(teamId: Int, startDate: String, endDate: String)

    var url: URL? {
        var components = URLComponents(string: Constants.apiBaseURL)
        switch self {
        case .schedule(let teamId, let startDate, let endDate):
            components?.path += "/schedule"
            components?.queryItems = [
                URLQueryItem(name: "sportId", value: "1"),
                URLQueryItem(name: "teamId", value: "\(teamId)"),
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate),
                URLQueryItem(name: "gameType", value: "R,F,D,L,W"),
                URLQueryItem(name: "hydrate", value: "broadcasts(all),linescore,team")
            ]
        }
        return components?.url
    }
}
