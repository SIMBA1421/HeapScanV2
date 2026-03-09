import SwiftUI

struct ResultView: View {
    let volume: Double
    let weight: Double
    let operatorName: String
    
    @State private var showingExportMenu = false
    @State private var generatedPDFUrl: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                 List {
                    Section(header: Text("Details")) {
                        HStack { Text("Operator"); Spacer(); Text(operatorName) }
                        HStack { Text("Volume"); Spacer(); Text("\(volume, specifier: "%.2f") m³").bold() }
                        HStack { Text("Weight"); Spacer(); Text("\(weight, specifier: "%.2f") t").bold().foregroundColor(.blue) }
                    }
                 }
                 .listStyle(InsetGroupedListStyle())
                 
                 Button(action: {
                     showingExportMenu.toggle()
                 }) {
                     Text("Export Report")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding()
                         .frame(maxWidth: .infinity)
                         .background(Color.blue)
                         .cornerRadius(10)
                 }
                 .padding()
            }
            .navigationTitle("Scan Result")
            .navigationBarItems(trailing: Button("Done") {
                // Return
            })
            .actionSheet(isPresented: $showingExportMenu) {
                ActionSheet(title: Text("Export Configuration"), buttons: [
                    .default(Text("Generate PDF")) { generatePDF() },
                    .cancel()
                ])
            }
        }
    }
    
    func generatePDF() {
        // Stub implementation referencing PDFGeneratorService.swift
    }
}
