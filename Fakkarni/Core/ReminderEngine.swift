import Foundation
import UserNotifications

/// Schedules local notifications. iOS has no "exact alarm" API: instead the next few reminders
/// (and their Don't Forget repeats) are scheduled ahead of time, and refreshed whenever the app
/// opens or the student changes something.
///
/// Notification identifiers:
///  - "due-<epoch>"        the cycle reminder due at <epoch>
///  - "fu-<epoch>-<i>"     Don't Forget repeats after that due
///  - "sn-<epoch>-<i>"     repeats started by "Remind me later"
/// Repeats of a reminder that already fired are owned by the notification buttons
/// (snooze / dismiss / confirm) and are never wiped by a plain reschedule.
/// Constants live outside the main-actor class so the notification delegate can read them freely.
enum ReminderIDs {
    enum Action {
        static let open = "OPEN_PROGRES"
        static let snooze = "SNOOZE"
        static let confirm = "CONFIRM_BOOKING"
    }
    static let category = "BOOKING_REMINDER"
    static let dueEpochKey = "dueEpoch"
}

@MainActor
final class ReminderEngine {
    static let shared = ReminderEngine()

    private let center = UNUserNotificationCenter.current()
    private let maxCycles = 4
    private let maxRepeats = 8

    private var store: SettingsStore { SettingsStore.shared }

    // MARK: Permission and categories

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Button titles follow the in-app language, so this runs at launch and on every language change.
    func registerCategories() {
        let language = store.language
        let open = UNNotificationAction(identifier: ReminderIDs.Action.open, title: Strings.text(.notifActionOpen, language), options: [.foreground])
        let snooze = UNNotificationAction(identifier: ReminderIDs.Action.snooze, title: Strings.text(.notifActionSnooze, language), options: [])
        let confirm = UNNotificationAction(identifier: ReminderIDs.Action.confirm, title: Strings.text(.notifActionConfirm, language), options: [])
        let category = UNNotificationCategory(
            identifier: ReminderIDs.category,
            actions: [open, snooze, confirm],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])
    }

    // MARK: Public operations

    /// Brings the scheduled notifications in line with the settings. Safe to call any time.
    func reschedule() async {
        guard let cycle = store.cycle else {
            await removePending { _ in true }
            return
        }
        let now = Date()
        let nowEpoch = Int(now.timeIntervalSince1970)
        let df = store.dontForget
        var desired: [(id: String, date: Date, epoch: Int)] = []

        for due in ReminderMath.upcoming(cycle, now: now, count: maxCycles) {
            let epoch = Int(due.timeIntervalSince1970)
            desired.append((id: "due-\(epoch)", date: due, epoch: epoch))
            if df.enabled {
                for i in 1...maxRepeats {
                    let date = due.addingTimeInterval(TimeInterval(i * df.repeatMinutes * 60))
                    desired.append((id: "fu-\(epoch)-\(i)", date: date, epoch: epoch))
                }
            }
        }

        let desiredIDs = Set(desired.map { $0.id })
        // Remove stale requests of future reminders. Past reminders' repeats are left alone.
        await removePending { id in
            guard let epoch = Self.epoch(of: id) else { return false }
            return epoch > nowEpoch && !desiredIDs.contains(id)
        }
        for item in desired where item.date > now {
            await add(id: item.id, at: item.date, dueEpoch: item.epoch)
        }
    }

    /// The student changed the date or time: forget everything pending and start over.
    func cycleChanged() async {
        await removePending { _ in true }
        center.removeAllDeliveredNotifications()
        await reschedule()
    }

    /// "Booking completed": the only action that counts as a booking.
    /// The next reminder is `periodDays` from today, at the same time.
    func confirmBooking() async {
        await removePending { _ in true }
        center.removeAllDeliveredNotifications()
        if let cycle = store.cycle {
            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            let anchor = cal.date(byAdding: .day, value: cycle.periodDays, to: today) ?? today
            store.cycle = CycleConfig(anchorDate: anchor, reminderMinutes: cycle.reminderMinutes, periodDays: cycle.periodDays)
        }
        await reschedule()
    }

    /// "Remind me later": ask again after the snooze time (and keep repeating if Don't Forget is on).
    func snooze(dueEpoch: Int) async {
        await removePending { id in Self.epoch(of: id) == dueEpoch }
        await removeDelivered(dueEpoch: dueEpoch)
        let df = store.dontForget
        let count = df.enabled ? maxRepeats : 1
        let start = Date().addingTimeInterval(TimeInterval(df.snoozeMinutes * 60))
        for i in 0..<count {
            let date = start.addingTimeInterval(TimeInterval(i * df.repeatMinutes * 60))
            await add(id: "sn-\(dueEpoch)-\(i)", at: date, dueEpoch: dueEpoch)
        }
    }

    /// The student swiped the reminder away: stop repeating it. It is not marked as booked.
    func dismiss(dueEpoch: Int) async {
        await removePending { id in Self.epoch(of: id) == dueEpoch && !id.hasPrefix("due-") }
    }

    /// Don't Forget Mode was switched off: pending repeats stop.
    func cancelRepeats() async {
        await removePending { id in id.hasPrefix("fu-") || id.hasPrefix("sn-") }
    }

    func sendTest() async {
        let content = UNMutableNotificationContent()
        content.title = Strings.text(.notifTestTitle, store.language)
        content.body = Strings.text(.notifTestBody, store.language)
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: "test", content: content, trigger: trigger))
    }

    // MARK: Helpers

    private func add(id: String, at date: Date, dueEpoch: Int) async {
        let content = UNMutableNotificationContent()
        content.title = Strings.text(.notifTitle, store.language)
        content.body = Strings.text(.notifBody, store.language)
        content.sound = .default
        content.categoryIdentifier = ReminderIDs.category
        content.userInfo = [ReminderIDs.dueEpochKey: dueEpoch]
        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func removePending(where shouldRemove: (String) -> Bool) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map { $0.identifier }.filter { Self.isOurs($0) && shouldRemove($0) }
        if !ids.isEmpty { center.removePendingNotificationRequests(withIdentifiers: ids) }
    }

    private func removeDelivered(dueEpoch: Int) async {
        let delivered = await center.deliveredNotifications()
        let ids = delivered
            .filter { ($0.request.content.userInfo[ReminderIDs.dueEpochKey] as? Int) == dueEpoch }
            .map { $0.request.identifier }
        if !ids.isEmpty { center.removeDeliveredNotifications(withIdentifiers: ids) }
    }

    private static func isOurs(_ id: String) -> Bool {
        id.hasPrefix("due-") || id.hasPrefix("fu-") || id.hasPrefix("sn-")
    }

    private static func epoch(of id: String) -> Int? {
        let parts = id.split(separator: "-")
        guard parts.count >= 2, isOurs(id) else { return nil }
        return Int(parts[1])
    }
}
