import SwiftUI

@main
struct HeapScanV2App: App {
    var body: some Scene {
        WindowGroup {
            ScanView()
                .preferredColorScheme(.dark)
        }
    }
}
