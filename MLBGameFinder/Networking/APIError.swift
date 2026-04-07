import Foundation

// MARK: - APIError

enum APIError: LocalizedError, Sendable {
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code):
            return "Server returned status code \(code)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
