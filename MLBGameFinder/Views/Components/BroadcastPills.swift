import SwiftUI

// MARK: - BroadcastPills

struct BroadcastPills: View {
    let broadcasts: [Broadcast]

    private var englishBroadcasts: [Broadcast] {
        // Deduplicate by name
        var seen = Set<String>()
        return broadcasts.filter { broadcast in
            guard broadcast.language == "en" else { return false }
            return seen.insert(broadcast.name).inserted
        }
    }

    var body: some View {
        if englishBroadcasts.isEmpty {
            Text("TBD")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1), in: Capsule())
                .accessibilityLabel("Broadcast: TBD")
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(englishBroadcasts) { broadcast in
                        Text(broadcast.name)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1), in: Capsule())
                            .accessibilityLabel("Broadcast: \(broadcast.name)")
                    }
                }
            }
        }
    }
}

#Preview {
    BroadcastPills(broadcasts: [
        Broadcast(name: "YES", type: "TV", language: "en", isNational: false),
        Broadcast(name: "ESPN", type: "TV", language: "en", isNational: true)
    ])
    .padding()
}
