import Foundation
import UIKit
import UserNotifications

/// Carries "open PROGRES" requests from a notification button to the UI.
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()
    @Published var pendingOpenProgres = false
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        return true
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    /// Show reminders as banners even while the app is open.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let action = response.actionIdentifier
        let epoch = response.notification.request.content.userInfo[ReminderIDs.dueEpochKey] as? Int
        Task { @MainActor in
            switch action {
            case ReminderIDs.Action.confirm:
                await ReminderEngine.shared.confirmBooking()
            case ReminderIDs.Action.snooze:
                if let epoch { await ReminderEngine.shared.snooze(dueEpoch: epoch) }
            case ReminderIDs.Action.open:
                AppRouter.shared.pendingOpenProgres = true
            case UNNotificationDismissActionIdentifier:
                if let epoch { await ReminderEngine.shared.dismiss(dueEpoch: epoch) }
            default:
                break
            }
            completionHandler()
        }
    }
}
