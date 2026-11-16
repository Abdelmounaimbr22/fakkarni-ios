import Foundation

enum Fmt {
    static func date(_ date: Date, _ language: AppLanguage, style: DateFormatter.Style = .full) -> String {
        let f = DateFormatter()
        f.locale = language.locale
        f.dateStyle = style
        f.timeStyle = .none
        return f.string(from: date)
    }

    static func time(_ date: Date, _ language: AppLanguage) -> String {
        let f = DateFormatter()
        f.locale = language.locale
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }

    static func dateTime(_ date: Date, _ language: AppLanguage) -> String {
        "\(Fmt.date(date, language, style: .medium)) · \(time(date, language))"
    }

    static func minutesShort(_ n: Int, _ language: AppLanguage) -> String {
        language == .arabic ? "\(n) د" : "\(n) min"
    }

    /// Date for a number of minutes after midnight today (used by time pickers).
    static func dateFromMinutes(_ minutes: Int) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .minute, value: minutes, to: cal.startOfDay(for: Date())) ?? Date()
    }

    static func minutesFromDate(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    // MARK: Countdown

    struct CountdownParts {
        let primary: String
        let secondary: String?
    }

    static func countdown(_ remaining: TimeInterval, _ language: AppLanguage) -> CountdownParts {
        let totalMinutes = max(Int(remaining / 60), 1)
        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes % (24 * 60)) / 60
        let minutes = totalMinutes % 60
        if days > 0 {
            return CountdownParts(primary: unit(.day, days, language), secondary: hours > 0 ? unit(.hour, hours, language) : nil)
        } else if hours > 0 {
            return CountdownParts(primary: unit(.hour, hours, language), secondary: minutes > 0 ? unit(.minute, minutes, language) : nil)
        }
        return CountdownParts(primary: unit(.minute, minutes, language), secondary: nil)
    }

    enum Unit { case day, hour, minute }

    static func unit(_ unit: Unit, _ n: Int, _ language: AppLanguage) -> String {
        if language == .english {
            let word: String
            switch unit {
            case .day: word = "day"
            case .hour: word = "hour"
            case .minute: word = "minute"
            }
            return "\(n) \(word)\(n == 1 ? "" : "s")"
        }
        // Arabic plural rules: 1, 2, 3-10, 11-99, 100+
        let forms: (one: String, two: String, few: String, many: String)
        switch unit {
        case .day: forms = ("يوم واحد", "يومان", "أيام", "يومًا")
        case .hour: forms = ("ساعة واحدة", "ساعتان", "ساعات", "ساعة")
        case .minute: forms = ("دقيقة واحدة", "دقيقتان", "دقائق", "دقيقة")
        }
        switch n {
        case 1: return forms.one
        case 2: return forms.two
        default:
            let r = n % 100
            if r >= 3 && r <= 10 { return "\(n) \(forms.few)" }
            if r >= 11 { return "\(n) \(forms.many)" }
            let other: String
            switch unit {
            case .day: other = "يوم"
            case .hour, .minute: other = forms.many
            }
            return "\(n) \(other)"
        }
    }

    static func join(_ a: String, _ b: String, _ language: AppLanguage) -> String {
        language == .arabic ? "\(a) و\(b)" : "\(a) and \(b)"
    }
}
