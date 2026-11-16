import Foundation

/// Pure scheduling math, same rule as the Android app.
/// Reminder k is due at `anchorDate + k * periodDays` at `reminderMinutes` (local time).
/// The next reminder is the first one strictly after `now`.
enum ReminderMath {
    static func firstDue(_ config: CycleConfig, calendar: Calendar = .current) -> Date {
        let day = calendar.startOfDay(for: config.anchorDate)
        return calendar.date(byAdding: .minute, value: config.reminderMinutes, to: day) ?? day
    }

    static func next(_ config: CycleConfig, now: Date, calendar: Calendar = .current) -> NextReminder {
        let period = max(config.periodDays, 1)
        let first = firstDue(config, calendar: calendar)
        let due: Date
        if now < first {
            due = first
        } else {
            let elapsed = calendar.dateComponents([.day], from: first, to: now).day ?? 0
            let k = elapsed / period + 1
            due = calendar.date(byAdding: .day, value: k * period, to: first) ?? first
        }
        let previous = calendar.date(byAdding: .day, value: -period, to: due) ?? due
        return NextReminder(dueAt: due, previousDueAt: previous)
    }

    /// Dues strictly after `now`: the next `count` reminders.
    static func upcoming(_ config: CycleConfig, now: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        var result: [Date] = []
        var due = next(config, now: now, calendar: calendar).dueAt
        for _ in 0..<count {
            result.append(due)
            due = calendar.date(byAdding: .day, value: max(config.periodDays, 1), to: due) ?? due
        }
        return result
    }
}
