import SwiftUI

// MARK: - VenueLabel

struct VenueLabel: View {
    let venueName: String

    var body: some View {
        Label(venueName, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Venue: \(venueName)")
    }
}

#Preview {
    VenueLabel(venueName: "Yankee Stadium")
        .padding()
}
