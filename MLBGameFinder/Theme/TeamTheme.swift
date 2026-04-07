import SwiftUI

// MARK: - TeamTheme

struct TeamTheme: Sendable {
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color
    let secondary: Color

    static let `default` = TeamTheme(
        primary: Color(hex: "#003087"),
        primaryLight: Color(hex: "#1a4a9e"),
        primaryDark: Color(hex: "#001f5b"),
        secondary: Color(hex: "#c4a962")
    )
}

// MARK: - EnvironmentKey

private struct TeamThemeKey: EnvironmentKey {
    static let defaultValue = TeamTheme.default
}

extension EnvironmentValues {
    var teamTheme: TeamTheme {
        get { self[TeamThemeKey.self] }
        set { self[TeamThemeKey.self] = newValue }
    }
}
