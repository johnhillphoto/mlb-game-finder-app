import SwiftUI

// MARK: - ResultBadge

struct ResultBadge: View {
    let isWin: Bool

    var body: some View {
        Text(isWin ? "W" : "L")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(isWin ? .green : .red, in: Circle())
            .accessibilityLabel(isWin ? "Win" : "Loss")
    }
}

#Preview {
    HStack {
        ResultBadge(isWin: true)
        ResultBadge(isWin: false)
    }
    .padding()
}
