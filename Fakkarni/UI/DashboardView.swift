import SwiftUI
import UserNotifications

struct DashboardView: View {
    @EnvironmentObject var store: SettingsStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var authStatus: UNAuthorizationStatus = .authorized

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            ScrollView {
                VStack(spacing: 16) {
                    header(now: context.date)
                    if let cycle = store.cycle {
                        let info = ReminderMath.next(cycle, now: context.date)
                        countdownCard(cycle: cycle, info: info, now: context.date)
                        cycleCard(cycle: cycle, info: info, now: context.date)
                    } else {
                        FCard { BodyText(store.t(.dashNotSet)) }
                    }
                    if authStatus == .denied || authStatus == .notDetermined {
                        notificationsOffCard
                    }
                    dontForgetCard
                    GradientButton(title: store.t(.openProgres), systemImage: "arrow.up.right.square") {
                        Progres.open()
                    }
                    if store.cycle != nil {
                        OutlineButton(title: store.t(.notifActionConfirm), systemImage: "checkmark.circle") {
                            Task { await ReminderEngine.shared.confirmBooking() }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill").foregroundColor(Theme.cyan)
                }
            }
        }
        .task { await refreshAuth() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task {
                    await refreshAuth()
                    await ReminderEngine.shared.reschedule()
                }
            }
        }
    }

    private func refreshAuth() async {
        authStatus = await ReminderEngine.shared.authorizationStatus()
    }

    private func greeting(hour: Int) -> String {
        switch hour {
        case 5..<12: return store.t(.greetingMorning)
        case 12..<18: return store.t(.greetingAfternoon)
        default: return store.t(.greetingEvening)
        }
    }

    private func header(now: Date) -> some View {
        HStack(spacing: 12) {
            Image("Logo").resizable().scaledToFit().frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting(hour: Calendar.current.component(.hour, from: now)))
                    .font(.title3.bold()).foregroundColor(.white)
                Text(store.t(.tagline)).font(.footnote).foregroundColor(Theme.cyan)
            }
            Spacer()
        }
    }

    private func countdownCard(cycle: CycleConfig, info: NextReminder, now: Date) -> some View {
        let total = max(info.dueAt.timeIntervalSince(info.previousDueAt), 1)
        let elapsed = now.timeIntervalSince(info.previousDueAt)
        let progress = min(max(elapsed / total, 0), 1)
        let parts = Fmt.countdown(info.dueAt.timeIntervalSince(now), store.language)
        return FCard {
            Text(store.t(.dashNextBookingIn)).font(.subheadline).foregroundColor(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
            CountdownRing(progress: progress, primary: parts.primary, secondary: parts.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(parts.secondary.map { Fmt.join(parts.primary, $0, store.language) } ?? parts.primary)
            Text(store.t(.dashNextReminder)).font(.footnote).foregroundColor(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(Fmt.dateTime(info.dueAt, store.language)).font(.headline).foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func cycleCard(cycle: CycleConfig, info: NextReminder, now: Date) -> some View {
        let length = cycle.periodDays
        let elapsedDays = Calendar.current.dateComponents([.day], from: info.previousDueAt, to: now).day ?? 0
        let day = min(max(elapsedDays + 1, 1), length)
        return FCard {
            HStack {
                SectionTitle(store.t(.dashCycle))
                Spacer()
                Text(String(format: store.t(.dashCycleDay), day, length))
                    .font(.subheadline).foregroundColor(Theme.cyan)
            }
            HStack(spacing: 6) {
                ForEach(1...max(length, 1), id: \.self) { i in
                    Capsule()
                        .fill(i <= day ? Theme.cyan : Theme.navyOutline.opacity(0.6))
                        .frame(height: 6)
                }
            }
        }
    }

    private var dontForgetCard: some View {
        FCard {
            HStack {
                Image(systemName: store.dontForget.enabled ? "bell.badge.fill" : "bell.slash.fill")
                    .foregroundColor(store.dontForget.enabled ? Theme.cyan : Theme.textSecondary)
                Text(store.t(store.dontForget.enabled ? .dfOn : .dfOff)).foregroundColor(.white)
            }
        }
    }

    private var notificationsOffCard: some View {
        FCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.slash.fill").foregroundColor(Theme.danger)
                Text(store.t(.notifOffWarning)).font(.subheadline).foregroundColor(.white)
            }
            if authStatus == .notDetermined {
                OutlineButton(title: store.t(.notifPermGrant)) {
                    Task {
                        _ = await ReminderEngine.shared.requestAuthorization()
                        await refreshAuth()
                        await ReminderEngine.shared.reschedule()
                    }
                }
            } else {
                OutlineButton(title: store.t(.openSystemSettings)) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}
