import UIKit

/// Opening the official PROGRES app.
/// If PROGRES has a known URL scheme on iOS, put it in `urlScheme` (for example "progres://")
/// and add the same scheme (without "://") to LSApplicationQueriesSchemes in project.yml.
/// Until then the button opens the App Store search for PROGRES.
enum Progres {
    static let urlScheme: String? = nil
    static let storeSearchURL = URL(string: "https://apps.apple.com/search?term=PROGRES")!

    @MainActor
    static func open() {
        if let scheme = urlScheme, let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(storeSearchURL)
        }
    }
}
