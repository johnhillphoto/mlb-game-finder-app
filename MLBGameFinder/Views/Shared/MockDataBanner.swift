import SwiftUI

// MARK: - MockDataBanner

struct MockDataBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.yellow)
            Text("Using sample data — MLB API unavailable")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .accessibilityLabel("Notice: displaying sample data because the MLB API is unavailable")
    }
}

#Preview {
    MockDataBanner()
        .padding()
}
