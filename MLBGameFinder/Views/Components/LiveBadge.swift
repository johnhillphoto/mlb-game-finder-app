import SwiftUI

// MARK: - LiveBadge

struct LiveBadge: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: pulse
                )
            Text("LIVE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.red.opacity(0.12), in: Capsule())
        .accessibilityLabel("Live game in progress")
        .onAppear { pulse = true }
    }
}

#Preview {
    LiveBadge()
        .padding()
}
