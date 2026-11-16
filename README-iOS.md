# FAKKARNI for iPhone

SwiftUI, iOS 16+, no third-party packages.

## Build on the Mac
1. Install Xcode from the App Store (open it once so it finishes installing components).
2. In Terminal: `brew install xcodegen` (Homebrew: https://brew.sh)
3. `cd` into this folder (the one containing `project.yml`) and run: `xcodegen`
4. Open `Fakkarni.xcodeproj`.
5. Click the project > target Fakkarni > Signing & Capabilities > pick your Team (your Apple ID works for testing).
   If the bundle id `dz.fakkarni.app` is taken, change it to something unique.
6. Plug in the iPhone, select it at the top, press Run.
   First run on the phone: Settings > General > VPN & Device Management > trust your developer profile.

## Notes
- Notifications are scheduled ahead of time (iOS has no exact alarms): the next 4 reminders and their Don't Forget repeats.
- Notification buttons appear when you long-press the notification.
- PROGRES: set `Progres.urlScheme` in Core/Progres.swift once its iOS URL scheme is known.
