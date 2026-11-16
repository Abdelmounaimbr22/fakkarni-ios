import Foundation
import SwiftUI

/// Everything is stored on the device in UserDefaults. No account, no server.
@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    @Published var language: AppLanguage { didSet { defaults.set(language.rawValue, forKey: Key.language) } }
    @Published var onboardingDone: Bool { didSet { defaults.set(onboardingDone, forKey: Key.onboardingDone) } }
    @Published var cycle: CycleConfig? { didSet { saveCycle() } }
    @Published var dontForget: DontForgetConfig { didSet { saveDontForget() } }

    private enum Key {
        static let language = "language"
        static let onboardingDone = "onboardingDone"
        static let anchor = "anchorDate"
        static let minutes = "reminderMinutes"
        static let period = "periodDays"
        static let dfEnabled = "dfEnabled"
        static let dfRepeat = "dfRepeat"
        static let dfSnooze = "dfSnooze"
    }

    private init() {
        let d = UserDefaults.standard
        language = AppLanguage(rawValue: d.string(forKey: Key.language) ?? "") ?? .arabic
        onboardingDone = d.bool(forKey: Key.onboardingDone)
        if let anchor = d.object(forKey: Key.anchor) as? Date, d.object(forKey: Key.minutes) != nil {
            let period = d.integer(forKey: Key.period)
            cycle = CycleConfig(anchorDate: anchor, reminderMinutes: d.integer(forKey: Key.minutes), periodDays: period > 0 ? period : 3)
        } else {
            cycle = nil
        }
        var df = DontForgetConfig()
        if d.object(forKey: Key.dfEnabled) != nil {
            df.enabled = d.bool(forKey: Key.dfEnabled)
            df.repeatMinutes = d.integer(forKey: Key.dfRepeat)
            df.snoozeMinutes = d.integer(forKey: Key.dfSnooze)
            if df.repeatMinutes <= 0 { df.repeatMinutes = 15 }
            if df.snoozeMinutes <= 0 { df.snoozeMinutes = 15 }
        }
        dontForget = df
    }

    private func saveCycle() {
        if let cycle {
            defaults.set(cycle.anchorDate, forKey: Key.anchor)
            defaults.set(cycle.reminderMinutes, forKey: Key.minutes)
            defaults.set(cycle.periodDays, forKey: Key.period)
        } else {
            defaults.removeObject(forKey: Key.anchor)
            defaults.removeObject(forKey: Key.minutes)
        }
    }

    private func saveDontForget() {
        defaults.set(dontForget.enabled, forKey: Key.dfEnabled)
        defaults.set(dontForget.repeatMinutes, forKey: Key.dfRepeat)
        defaults.set(dontForget.snoozeMinutes, forKey: Key.dfSnooze)
    }

    func t(_ key: K) -> String { Strings.text(key, language) }
}
