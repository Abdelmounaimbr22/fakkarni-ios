import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: SettingsStore
    @ObservedObject private var router = AppRouter.shared

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            if store.onboardingDone {
                NavigationStack { DashboardView() }
            } else {
                OnboardingView()
            }
        }
        .tint(Theme.cyan)
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, store.language.layoutDirection)
        .environment(\.locale, store.language.locale)
        .onReceive(router.$pendingOpenProgres) { pending in
            if pending {
                router.pendingOpenProgres = false
                Progres.open()
            }
        }
    }
}
