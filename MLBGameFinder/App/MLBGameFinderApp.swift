import SwiftUI

@main
struct MLBGameFinderApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(\.teamTheme, appState.currentTheme)
        }
    }
}
