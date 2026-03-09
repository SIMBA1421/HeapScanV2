import SwiftUI
import CoreLocation

struct SetupView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("defaultDensity") private var defaultDensity: Double = 1.6
    @State private var isReady = false
    
    var body: some View {
        if isReady {
            MainTabView()
        } else {
            VStack {
                Text("HeapScan V2 Configuration")
                    .font(.title)
                    .bold()
                
                Form {
                    Section(header: Text("Operator Info")) {
                        TextField("Your Name", text: $userName)
                    }
                    Section(header: Text("Material Default (t/m³)")) {
                        TextField("Density", value: $defaultDensity, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                }
                
                Button("Start Scan") {
                    isReady = true
                }
                .disabled(userName.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}
