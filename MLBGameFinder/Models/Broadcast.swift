import Foundation

struct Broadcast: Identifiable, Sendable, Codable, Hashable {
    let name: String
    let type: String
    let language: String
    let isNational: Bool

    // Synthesize a stable ID from name+type
    var id: String { "\(name)-\(type)" }
}
