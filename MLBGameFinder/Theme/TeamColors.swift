import SwiftUI

// MARK: - TeamColors

/// Resolves a TeamTheme from a loaded MlbTeam's hex color strings.
extension TeamTheme {
    init(from team: MlbTeam) {
        self.init(
            primary: Color(hex: team.primaryHex),
            primaryLight: Color(hex: team.primaryLightHex),
            primaryDark: Color(hex: team.primaryDarkHex),
            secondary: Color(hex: team.secondaryHex)
        )
    }
}
