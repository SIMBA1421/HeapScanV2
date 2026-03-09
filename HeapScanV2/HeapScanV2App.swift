import SwiftUI
import CoreLocation

@main
struct HeapScanV2App: App {
    var body: some Scene {
        WindowGroup {
            SetupView()
                .preferredColorScheme(.dark)
        }
    }
}
