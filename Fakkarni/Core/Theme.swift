import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Theme {
    static let navyDeep = Color(hex: 0x030B24)
    static let navyBackground = Color(hex: 0x050F30)
    static let navySurface = Color(hex: 0x0A1A44)
    static let navyCard = Color(hex: 0x0E2358)
    static let navyOutline = Color(hex: 0x24408A)
    static let cyan = Color(hex: 0x22E4F5)
    static let turquoise = Color(hex: 0x14C9C0)
    static let textSecondary = Color(hex: 0xB4C4E8)
    static let danger = Color(hex: 0xFF6B6B)

    static let brandGradient = LinearGradient(colors: [cyan, turquoise], startPoint: .leading, endPoint: .trailing)
    static let backgroundGradient = LinearGradient(colors: [navyDeep, navyBackground, navySurface], startPoint: .top, endPoint: .bottom)
}
