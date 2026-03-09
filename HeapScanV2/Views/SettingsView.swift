import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("defaultDensity") private var defaultDensity: Double = 1.6
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Photographer / Operator Name", text: $userName)
                }
                
                Section(header: Text("Material & Mathematics"), footer: Text("Note: Density determines weight calculation. Units are strictly locked to Metric (m³, tonnes).")) {
                    HStack {
                        Text("Default Density")
                        Spacer()
                        TextField("Density", value: $defaultDensity, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("t/m³")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Volume Unit")
                        Spacer()
                        Text("m³")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Weight Unit")
                        Spacer()
                        Text("Tonnes")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
