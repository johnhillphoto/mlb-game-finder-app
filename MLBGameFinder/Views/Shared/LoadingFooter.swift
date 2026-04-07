import SwiftUI

// MARK: - LoadingFooter

struct LoadingFooter: View {
    let showing: Int
    let total: Int
    let isLoading: Bool

    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accessibilityLabel("Loading more games")
            }
            Text("Showing \(showing) of \(total) games")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    LoadingFooter(showing: 6, total: 20, isLoading: true)
}
