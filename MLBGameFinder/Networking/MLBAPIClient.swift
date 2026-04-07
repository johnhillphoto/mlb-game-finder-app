import Foundation

// MARK: - MLBAPIClient Protocol

protocol MLBAPIClientProtocol: Sendable {
    func fetchSchedule(teamId: Int, startDate: String, endDate: String) async throws -> [Game]
}

// MARK: - Live Implementation

final class MLBAPIClient: MLBAPIClientProtocol, Sendable {
    static let shared = MLBAPIClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchSchedule(teamId: Int, startDate: String, endDate: String) async throws -> [Game] {
        guard let url = MLBEndpoint.schedule(
            teamId: teamId,
            startDate: startDate,
            endDate: endDate
        ).url else {
            throw APIError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }

        let decoded: ScheduleResponse
        do {
            decoded = try JSONDecoder().decode(ScheduleResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }

        return decoded.dates
            .flatMap { $0.games }
            .compactMap { $0.toDomain() }
    }
}
