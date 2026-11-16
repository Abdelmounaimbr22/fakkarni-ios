import Foundation

/// All user-facing text, in both languages. Keys are checked at compile time.
enum K: CaseIterable {
    case brandFull
    case tagline
    case next
    case back
    case start
    case done
    case change
    case stepCounter
    case langArabic
    case langEnglish
    case onbWelcomeTitle
    case onbWelcomeBody
    case onbWelcomeNote
    case onbLanguageTitle
    case onbLanguageBody
    case onbDateTitle
    case onbDateBody
    case onbTimeTitle
    case onbTimeBody
    case firstReminder
    case onbDFTitle
    case onbDFBody
    case dfEnable
    case dfRepeatEvery
    case notifPermTitle
    case notifPermBody
    case notifPermGrant
    case notifPermGranted
    case notifPermLater
    case onbProgresTitle
    case onbProgresBody
    case progresIosHint
    case openProgres
    case greetingMorning
    case greetingAfternoon
    case greetingEvening
    case dashNextBookingIn
    case dashNextReminder
    case dashCycle
    case dashCycleDay
    case dfOn
    case dfOff
    case dashNotSet
    case notifOffWarning
    case openSystemSettings
    case helpTitle
    case helpDevelopedBy
    case helpBody
    case helpContactButton
    case settingsTitle
    case settingsLanguage
    case settingsCycle
    case settingsNextDate
    case settingsReminderTime
    case settingsDontForget
    case settingsRepeatInterval
    case settingsSnooze
    case settingsReminders
    case settingsTestNotification
    case settingsProgres
    case settingsPrivacy
    case settingsPrivacyBody
    case settingsAbout
    case settingsVersion
    case notifTip
    case notifTitle
    case notifBody
    case notifActionOpen
    case notifActionSnooze
    case notifActionConfirm
    case notifTestTitle
    case notifTestBody
}

enum Strings {
    static func text(_ key: K, _ language: AppLanguage) -> String {
        guard let pair = table[key] else { return "\(key)" }
        return language == .arabic ? pair.ar : pair.en
    }

    private static let table: [K: (en: String, ar: String)] = [
        .brandFull: (en: "FAKKARNI | فكرني", ar: "FAKKARNI | فكرني"),
        .tagline: (en: "Never Miss Your Booking.", ar: "لا تفوّت حجزك أبدًا."),
        .next: (en: "Next", ar: "التالي"),
        .back: (en: "Back", ar: "رجوع"),
        .start: (en: "Get started", ar: "ابدأ الآن"),
        .done: (en: "Done", ar: "تم"),
        .change: (en: "Change", ar: "تغيير"),
        .stepCounter: (en: "Step %d of %d", ar: "الخطوة %d من %d"),
        .langArabic: (en: "العربية", ar: "العربية"),
        .langEnglish: (en: "English", ar: "English"),
        .onbWelcomeTitle: (en: "Welcome to FAKKARNI", ar: "مرحبًا بك في فكرني"),
        .onbWelcomeBody: (en: "Your reminder assistant for renewing your university booking in PROGRES, every three days, so you never forget.", ar: "مساعدك للتذكير بتجديد حجزك الجامعي في تطبيق PROGRES كل ثلاثة أيام، حتى لا تنسى أبدًا."),
        .onbWelcomeNote: (en: "FAKKARNI does not replace PROGRES. It only reminds you and opens it for you.", ar: "فكرني لا يحل محل PROGRES، بل يذكّرك ويفتحه لك فقط."),
        .onbLanguageTitle: (en: "Choose your language", ar: "اختر لغتك"),
        .onbLanguageBody: (en: "You can change it anytime in Settings.", ar: "يمكنك تغييرها في أي وقت من الإعدادات."),
        .onbDateTitle: (en: "When is your next booking?", ar: "متى موعد حجزك القادم؟"),
        .onbDateBody: (en: "Pick the date you expect to renew your booking. We will repeat the reminder every 3 days.", ar: "اختر التاريخ الذي تتوقع فيه تجديد حجزك. سنكرر التذكير كل 3 أيام."),
        .onbTimeTitle: (en: "Reminder time", ar: "وقت التذكير"),
        .onbTimeBody: (en: "At what time should we remind you in each cycle?", ar: "في أي ساعة تريد أن نذكّرك في كل دورة؟"),
        .firstReminder: (en: "First reminder", ar: "أول تذكير"),
        .onbDFTitle: (en: "Don't Forget Mode", ar: "وضع «لا تنسَ»"),
        .onbDFBody: (en: "If you do not respond, we keep reminding you until you confirm your booking or dismiss the reminder.", ar: "إن لم تستجب، سنواصل تذكيرك حتى تؤكد حجزك أو تتجاهل التذكير."),
        .dfEnable: (en: "Enable Don't Forget Mode", ar: "تفعيل وضع «لا تنسَ»"),
        .dfRepeatEvery: (en: "Repeat every", ar: "كرّر كل"),
        .notifPermTitle: (en: "Notifications", ar: "الإشعارات"),
        .notifPermBody: (en: "Reminders are shown as notifications, so FAKKARNI needs your permission.", ar: "تظهر التذكيرات على شكل إشعارات، لذا يحتاج فكرني إلى إذنك."),
        .notifPermGrant: (en: "Allow notifications", ar: "السماح بالإشعارات"),
        .notifPermGranted: (en: "Notifications are allowed", ar: "الإشعارات مسموحة"),
        .notifPermLater: (en: "You can also enable them later from iPhone Settings.", ar: "يمكنك أيضًا تفعيلها لاحقًا من إعدادات الآيفون."),
        .onbProgresTitle: (en: "PROGRES app", ar: "تطبيق PROGRES"),
        .onbProgresBody: (en: "FAKKARNI opens the official PROGRES app for you when it is time to renew.", ar: "يفتح فكرني تطبيق PROGRES الرسمي لك عندما يحين وقت التجديد."),
        .progresIosHint: (en: "If PROGRES does not open, search for it in the App Store.", ar: "إن لم يُفتح PROGRES، ابحث عنه في App Store."),
        .openProgres: (en: "Open PROGRES", ar: "فتح PROGRES"),
        .greetingMorning: (en: "Good morning", ar: "صباح الخير"),
        .greetingAfternoon: (en: "Good afternoon", ar: "نهارك سعيد"),
        .greetingEvening: (en: "Good evening", ar: "مساء الخير"),
        .dashNextBookingIn: (en: "Next booking in", ar: "الحجز القادم بعد"),
        .dashNextReminder: (en: "Next reminder", ar: "التذكير القادم"),
        .dashCycle: (en: "3-day cycle", ar: "دورة الأيام الثلاثة"),
        .dashCycleDay: (en: "Day %d of %d", ar: "اليوم %d من %d"),
        .dfOn: (en: "Don't Forget Mode: On", ar: "وضع «لا تنسَ»: مفعّل"),
        .dfOff: (en: "Don't Forget Mode: Off", ar: "وضع «لا تنسَ»: متوقف"),
        .dashNotSet: (en: "Set your next booking date in Settings.", ar: "حدّد موعد حجزك القادم من الإعدادات."),
        .notifOffWarning: (en: "Notifications are turned off, so you will not get your reminder.", ar: "الإشعارات متوقفة، لذلك لن يصلك التذكير."),
        .openSystemSettings: (en: "Open iPhone Settings", ar: "فتح إعدادات الآيفون"),
        .helpTitle: (en: "Help & Contact", ar: "المساعدة والتواصل"),
        .helpDevelopedBy: (en: "Developed by", ar: "طُوِّر بواسطة"),
        .helpBody: (en: "Found a problem or have a suggestion? Reach out to the developer.", ar: "وجدت مشكلة أو عندك اقتراح؟ تواصل مع المطور."),
        .helpContactButton: (en: "Contact the developer", ar: "تواصل مع المطور"),
        .settingsTitle: (en: "Settings", ar: "الإعدادات"),
        .settingsLanguage: (en: "Language", ar: "اللغة"),
        .settingsCycle: (en: "Booking cycle", ar: "دورة الحجز"),
        .settingsNextDate: (en: "Next booking date", ar: "موعد الحجز القادم"),
        .settingsReminderTime: (en: "Reminder time", ar: "وقت التذكير"),
        .settingsDontForget: (en: "Don't Forget Mode", ar: "وضع «لا تنسَ»"),
        .settingsRepeatInterval: (en: "Repeat interval", ar: "فترة التكرار"),
        .settingsSnooze: (en: "Remind me later after", ar: "«ذكرني لاحقاً» بعد"),
        .settingsReminders: (en: "Reminders", ar: "التذكيرات"),
        .settingsTestNotification: (en: "Send a test notification", ar: "إرسال إشعار تجريبي"),
        .settingsProgres: (en: "PROGRES", ar: "PROGRES"),
        .settingsPrivacy: (en: "Privacy", ar: "الخصوصية"),
        .settingsPrivacyBody: (en: "Everything stays on your device. FAKKARNI has no account and no server, collects no data, and never asks for your PROGRES password.", ar: "كل شيء يبقى على جهازك. لا يملك فكرني حسابًا ولا خادمًا، ولا يجمع أي بيانات، ولا يطلب كلمة مرور PROGRES أبدًا."),
        .settingsAbout: (en: "About", ar: "حول التطبيق"),
        .settingsVersion: (en: "Version %@", ar: "الإصدار %@"),
        .notifTip: (en: "Tip: press and hold a reminder notification to see its buttons.", ar: "نصيحة: اضغط مطولًا على إشعار التذكير لتظهر أزراره."),
        .notifTitle: (en: "Time to Renew Your Booking!", ar: "حان وقت إعادة الحجز!"),
        .notifBody: (en: "Your university booking reminder is due. Open PROGRES to continue.", ar: "لا تنسَ تجديد حجزك الجامعي عبر تطبيق PROGRES."),
        .notifActionOpen: (en: "Open PROGRES", ar: "فتح PROGRES"),
        .notifActionSnooze: (en: "Remind me later", ar: "ذكرني لاحقاً"),
        .notifActionConfirm: (en: "Booking completed", ar: "تم الحجز"),
        .notifTestTitle: (en: "Test reminder", ar: "تذكير تجريبي"),
        .notifTestBody: (en: "Notifications are working. This is only a test.", ar: "الإشعارات تعمل. هذا اختبار فقط."),
    ]
}
