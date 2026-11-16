import SwiftUI

@main
struct FakkarniApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = SettingsStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .task {
                    ReminderEngine.shared.registerCategories()
                    await ReminderEngine.shared.reschedule()
                }
        }
    }
}
