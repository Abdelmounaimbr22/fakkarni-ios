import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: SettingsStore
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                languageCard
                cycleCard
                dontForgetCard
                remindersCard
                progresCard
                privacyCard
                helpCard
                aboutCard
            }
            .padding(20)
        }
        .background(Theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle(store.t(.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDatePicker) {
            PickerSheet(mode: .date, selection: store.cycle?.anchorDate ?? Date()) { date in
                updateCycle(date: Calendar.current.startOfDay(for: date), minutes: nil)
            }
        }
        .sheet(isPresented: $showTimePicker) {
            PickerSheet(mode: .time, selection: Fmt.dateFromMinutes(store.cycle?.reminderMinutes ?? 480)) { time in
                updateCycle(date: nil, minutes: Fmt.minutesFromDate(time))
            }
        }
    }

    private func updateCycle(date: Date?, minutes: Int?) {
        let current = store.cycle
        let anchor = date ?? current?.anchorDate ?? Calendar.current.startOfDay(for: Date())
        let mins = minutes ?? current?.reminderMinutes ?? 480
        store.cycle = CycleConfig(anchorDate: anchor, reminderMinutes: mins, periodDays: current?.periodDays ?? 3)
        Task { await ReminderEngine.shared.cycleChanged() }
    }

    private var languageCard: some View {
        FCard {
            SectionTitle(store.t(.settingsLanguage))
            HStack(spacing: 8) {
                Chip(title: store.t(.langArabic), selected: store.language == .arabic) { setLanguage(.arabic) }
                Chip(title: store.t(.langEnglish), selected: store.language == .english) { setLanguage(.english) }
            }
        }
    }

    private func setLanguage(_ language: AppLanguage) {
        store.language = language
        // Button titles and notification text follow the language.
        ReminderEngine.shared.registerCategories()
        Task { await ReminderEngine.shared.cycleChanged() }
    }

    private var cycleCard: some View {
        FCard {
            SectionTitle(store.t(.settingsCycle))
            valueRow(
                label: store.t(.settingsNextDate),
                value: store.cycle.map { Fmt.date($0.anchorDate, store.language) } ?? "-"
            ) { showDatePicker = true }
            valueRow(
                label: store.t(.settingsReminderTime),
                value: store.cycle.map { Fmt.time(Fmt.dateFromMinutes($0.reminderMinutes), store.language) } ?? "-"
            ) { showTimePicker = true }
        }
    }

    private func valueRow(label: String, value: String, onChange: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                BodyText(label)
                Text(value).font(.headline).foregroundColor(.white)
            }
            Spacer()
            Button(store.t(.change), action: onChange).foregroundColor(Theme.cyan)
        }
        .padding(.vertical, 4)
    }

    private var dontForgetCard: some View {
        FCard {
            Toggle(isOn: Binding(
                get: { store.dontForget.enabled },
                set: { setDontForget($0) }
            )) {
                SectionTitle(store.t(.settingsDontForget))
            }
            .tint(Theme.cyan)
            if store.dontForget.enabled {
                BodyText(store.t(.settingsRepeatInterval))
                MinuteChips(options: DontForgetConfig.repeatOptions, selected: store.dontForget.repeatMinutes) { minutes in
                    store.dontForget.repeatMinutes = minutes
                    Task { await ReminderEngine.shared.reschedule() }
                }
                BodyText(store.t(.settingsSnooze))
                MinuteChips(options: DontForgetConfig.snoozeOptions, selected: store.dontForget.snoozeMinutes) { minutes in
                    store.dontForget.snoozeMinutes = minutes
                }
            }
        }
    }

    private func setDontForget(_ enabled: Bool) {
        store.dontForget.enabled = enabled
        Task {
            if !enabled { await ReminderEngine.shared.cancelRepeats() }
            await ReminderEngine.shared.reschedule()
        }
    }

    private var remindersCard: some View {
        FCard {
            SectionTitle(store.t(.settingsReminders))
            BodyText(store.t(.notifTip))
            OutlineButton(title: store.t(.settingsTestNotification), systemImage: "bell") {
                Task {
                    _ = await ReminderEngine.shared.requestAuthorization()
                    await ReminderEngine.shared.sendTest()
                }
            }
            OutlineButton(title: store.t(.openSystemSettings), systemImage: "gearshape") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private var progresCard: some View {
        FCard {
            SectionTitle(store.t(.settingsProgres))
            BodyText(store.t(.progresIosHint))
            GradientButton(title: store.t(.openProgres), systemImage: "arrow.up.right.square") {
                Progres.open()
            }
        }
    }

    private var privacyCard: some View {
        FCard {
            SectionTitle(store.t(.settingsPrivacy))
            BodyText(store.t(.settingsPrivacyBody))
        }
    }

    private var helpCard: some View {
        FCard {
            SectionTitle(store.t(.helpTitle))
            BodyText(store.t(.helpBody))
            BodyText(store.t(.helpDevelopedBy))
            Text(DeveloperInfo.name).font(.headline).foregroundColor(Theme.cyan)
            Link(destination: DeveloperInfo.contactURL) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.square")
                    Text(store.t(.helpContactButton)).fontWeight(.semibold)
                }
                .foregroundColor(Theme.navyDeep)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Theme.brandGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var aboutCard: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return FCard {
            SectionTitle(store.t(.settingsAbout))
            Text(store.t(.brandFull)).foregroundColor(.white)
            Text(store.t(.tagline)).font(.subheadline).foregroundColor(Theme.cyan)
            BodyText(String(format: store.t(.settingsVersion), version))
        }
    }
}
