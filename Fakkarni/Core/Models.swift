import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case arabic = "ar"
    case english = "en"

    /// Algerian Arabic keeps Latin digits; English is plain "en".
    var locale: Locale { Locale(identifier: self == .arabic ? "ar_DZ" : "en") }
    var layoutDirection: LayoutDirection { self == .arabic ? .rightToLeft : .leftToRight }
}

struct CycleConfig: Equatable {
    /// Start of the day of the first reminder.
    var anchorDate: Date
    /// Minutes after midnight (local time).
    var reminderMinutes: Int
    var periodDays: Int = 3
}

struct DontForgetConfig: Equatable {
    var enabled: Bool = true
    var repeatMinutes: Int = 15
    var snoozeMinutes: Int = 15

    static let repeatOptions = [5, 10, 15, 30, 60]
    static let snoozeOptions = [5, 15, 30, 60]
}

struct NextReminder {
    let dueAt: Date
    let previousDueAt: Date
}

enum DeveloperInfo {
    static let name = "BRANECI ABDELMOUNIM"
    static let contactURL = URL(string: "https://eadbewuf.portfely.com")!
}
