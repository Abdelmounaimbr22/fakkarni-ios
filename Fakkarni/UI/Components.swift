import SwiftUI

struct FCard<Content: View>: View {
    private let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Theme.navyCard)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.navyOutline.opacity(0.6), lineWidth: 1))
    }
}

struct GradientButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).fontWeight(.semibold)
            }
            .foregroundColor(Theme.navyDeep)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Theme.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct OutlineButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).fontWeight(.medium)
            }
            .foregroundColor(Theme.cyan)
            .frame(maxWidth: .infinity, minHeight: 48)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cyan.opacity(0.7), lineWidth: 1))
        }
    }
}

struct Chip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(selected ? Theme.navyDeep : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? Theme.cyan : Theme.navySurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.navyOutline, lineWidth: selected ? 0 : 1))
        }
    }
}

struct MinuteChips: View {
    let options: [Int]
    let selected: Int
    let onSelect: (Int) -> Void
    @EnvironmentObject var store: SettingsStore

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { minutes in
                    Chip(title: Fmt.minutesShort(minutes, store.language), selected: selected == minutes) {
                        onSelect(minutes)
                    }
                }
            }
        }
    }
}

struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.headline).foregroundColor(.white)
    }
}

struct BodyText: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.subheadline).foregroundColor(Theme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CountdownRing: View {
    let progress: Double
    let primary: String
    let secondary: String?

    var body: some View {
        ZStack {
            Circle().stroke(Theme.navyOutline.opacity(0.5), lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0.01), 1)))
                .stroke(Theme.brandGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text(primary)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                if let secondary {
                    Text(secondary).font(.callout).foregroundColor(Theme.cyan)
                }
            }
            .padding(24)
        }
        .frame(width: 220, height: 220)
    }
}

/// A sheet with a date or time picker and a Done button.
struct PickerSheet: View {
    enum Mode { case date, time }
    let mode: Mode
    @State var selection: Date
    let onConfirm: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: SettingsStore

    var body: some View {
        VStack(spacing: 16) {
            if mode == .date {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            } else {
                DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            GradientButton(title: store.t(.done)) {
                onConfirm(selection)
                dismiss()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.navyBackground.ignoresSafeArea())
        .environment(\.layoutDirection, store.language.layoutDirection)
        .environment(\.locale, store.language.locale)
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
    }
}
