import SwiftUI

struct ScanHistoryView: View {
    @State private var history: [ScanSession] = []
    
    var body: some View {
        NavigationView {
            List(history) { session in
                VStack(alignment: .leading) {
                    Text("\(session.date, style: .date)")
                    Text("\(session.volume, specifier: "%.2f") m³ • \(session.weight, specifier: "%.2f") t")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Scan History")
        }
    }
}
