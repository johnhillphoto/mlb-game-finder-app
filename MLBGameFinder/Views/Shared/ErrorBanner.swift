import SwiftUI

// MARK: - ErrorBanner

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Dismiss error")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.red, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

#Preview {
    ErrorBanner(message: "Unable to load games. Check your connection.") {}
        .padding()
}
