import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @EnvironmentObject var store: SettingsStore

    private let stepCount = 6
    @State private var step = 0
    @State private var date = Calendar.current.startOfDay(for: Date())
    @State private var time = Fmt.dateFromMinutes(8 * 60)
    @State private var dontForget = DontForgetConfig()
    @State private var notificationsGranted = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(0..<stepCount, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Theme.cyan : Theme.navyOutline.opacity(0.6))
                            .frame(height: 4)
                    }
                }
                Text(String(format: store.t(.stepCounter), step + 1, stepCount))
                    .font(.caption).foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    stepContent
                }
                .padding(20)
            }

            HStack(spacing: 12) {
                if step > 0 {
                    OutlineButton(title: store.t(.back)) { step -= 1 }
                }
                GradientButton(title: step == stepCount - 1 ? store.t(.start) : store.t(.next)) {
                    if step == stepCount - 1 { finish() } else { step += 1 }
                }
            }
            .padding(20)
        }
        .task { notificationsGranted = await granted() }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: welcome
        case 1: language
        case 2: dateStep
        case 3: timeStep
        case 4: dontForgetStep
        default: progresStep
        }
    }

    private func title(_ t: K, _ b: K) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.t(t)).font(.title.bold()).foregroundColor(.white)
            Text(store.t(b)).font(.body).foregroundColor(Theme.textSecondary)
        }
    }

    private var welcome: some View {
        VStack(spacing: 20) {
            Image("Logo").resizable().scaledToFit().frame(width: 160, height: 160)
            Text(store.t(.brandFull)).font(.title2.bold()).foregroundColor(.white)
            Text(store.t(.tagline)).foregroundColor(Theme.cyan)
            VStack(alignment: .leading, spacing: 12) {
                Text(store.t(.onbWelcomeTitle)).font(.title3.bold()).foregroundColor(.white)
                Text(store.t(.onbWelcomeBody)).foregroundColor(Theme.textSecondary)
                FCard { BodyText(store.t(.onbWelcomeNote)) }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var language: some View {
        VStack(alignment: .leading, spacing: 16) {
            title(.onbLanguageTitle, .onbLanguageBody)
            HStack(spacing: 8) {
                Chip(title: store.t(.langArabic), selected: store.language == .arabic) {
                    store.language = .arabic
                    ReminderEngine.shared.registerCategories()
                }
                Chip(title: store.t(.langEnglish), selected: store.language == .english) {
                    store.language = .english
                    ReminderEngine.shared.registerCategories()
                }
            }
        }
    }

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            title(.onbDateTitle, .onbDateBody)
            FCard {
                DatePicker("", selection: $date, in: Calendar.current.startOfDay(for: Date())..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            }
        }
    }

    private var timeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            title(.onbTimeTitle, .onbTimeBody)
            FCard {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            FCard {
                BodyText(store.t(.firstReminder))
                Text(Fmt.dateTime(firstReminderDate, store.language))
                    .font(.headline).foregroundColor(Theme.cyan)
            }
        }
    }

    private var firstReminderDate: Date {
        let cycle = CycleConfig(anchorDate: date, reminderMinutes: Fmt.minutesFromDate(time))
        return ReminderMath.next(cycle, now: Date()).dueAt
    }

    private var dontForgetStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            title(.onbDFTitle, .onbDFBody)
            FCard {
                Toggle(store.t(.dfEnable), isOn: $dontForget.enabled)
                    .foregroundColor(.white)
                    .tint(Theme.cyan)
                if dontForget.enabled {
                    BodyText(store.t(.dfRepeatEvery))
                    MinuteChips(options: DontForgetConfig.repeatOptions, selected: dontForget.repeatMinutes) {
                        dontForget.repeatMinutes = $0
                    }
                }
            }
            FCard {
                HStack {
                    Image(systemName: "bell.fill").foregroundColor(Theme.cyan)
                    SectionTitle(store.t(.notifPermTitle))
                }
                BodyText(store.t(.notifPermBody))
                if notificationsGranted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.cyan)
                        Text(store.t(.notifPermGranted)).foregroundColor(.white)
                    }
                } else {
                    OutlineButton(title: store.t(.notifPermGrant)) {
                        Task { notificationsGranted = await ReminderEngine.shared.requestAuthorization() }
                    }
                    BodyText(store.t(.notifPermLater))
                }
            }
        }
    }

    private var progresStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            title(.onbProgresTitle, .onbProgresBody)
            FCard {
                BodyText(store.t(.progresIosHint))
                OutlineButton(title: store.t(.openProgres), systemImage: "arrow.up.right.square") {
                    Progres.open()
                }
            }
        }
    }

    private func granted() async -> Bool {
        let status = await ReminderEngine.shared.authorizationStatus()
        return status == .authorized || status == .provisional || status == .ephemeral
    }

    private func finish() {
        store.dontForget = dontForget
        store.cycle = CycleConfig(anchorDate: Calendar.current.startOfDay(for: date), reminderMinutes: Fmt.minutesFromDate(time))
        store.onboardingDone = true
        Task { await ReminderEngine.shared.cycleChanged() }
    }
}
