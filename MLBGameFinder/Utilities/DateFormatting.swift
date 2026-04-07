import Foundation

// MARK: - Date Formatting Helpers

enum DateFormatting {

    private static let gameTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    private static let gameDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d · h:mm a"
        return f
    }()

    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// e.g. "7:05 PM"
    static func gameTime(_ date: Date) -> String {
        gameTimeFormatter.string(from: date)
    }

    /// e.g. "Thu, Apr 7, 2026"
    static func gameDate(_ date: Date) -> String {
        gameDateFormatter.string(from: date)
    }

    /// e.g. "Thu, Apr 7 · 7:05 PM"
    static func fullDateTime(_ date: Date) -> String {
        fullDateFormatter.string(from: date)
    }

    /// e.g. "2026-04-07"
    static func apiDate(_ date: Date) -> String {
        apiDateFormatter.string(from: date)
    }

    /// Returns "Today", "Tomorrow", or the formatted date
    static func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        return gameDate(date)
    }
}
