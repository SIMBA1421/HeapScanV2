import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            LiDARScanView()
                .tabItem {
                    Label("Scan", systemImage: "viewfinder")
                }
            ScanHistoryView()
                .tabItem {
                    Label("History", systemImage: "list.dash")
                }
        }
    }
}
