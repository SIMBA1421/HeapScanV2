import SwiftUI
import SceneKit
import WebKit

struct ResultView: View {
    @ObservedObject var session: ScanSession
    @State private var showingExportMenu = false
    @State private var showingReport = false

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    // Final point cloud render
                    if let resultCloud = session.processedCloud {
                        LivePointCloudView(pointCloud: resultCloud, qualityMap: [])
                            .frame(height: 300)
                            .cornerRadius(12)
                            .padding()
                    } else {
                        Text("Processing Model...")
                            .foregroundColor(.gray)
                    }
                }

                List {
                    Section(header: Text("Measurements")) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(session.measurement?.volume ?? 0.0, specifier: "%.2f") m³")
                                .bold()
                        }
                        HStack {
                            Text("Base Area")
                            Spacer()
                            Text("\(session.measurement?.baseArea ?? 0.0, specifier: "%.2f") m²")
                                .bold()
                        }
                        HStack {
                            Text("Max Height")
                            Spacer()
                            Text("\(session.measurement?.maxHeight ?? 0.0, specifier: "%.2f") m")
                                .bold()
                        }
                    }
                    
                    Section(header: Text("Quality")) {
                         HStack {
                            Text("Total Points")
                            Spacer()
                            Text("\(session.processedCloud?.points.count ?? 0)")
                        }
                        HStack {
                            Text("Coverage Score")
                            Spacer()
                            Text("\(Int(session.overallQuality * 100))%")
                        }
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
                .actionSheet(isPresented: $showingExportMenu) {
                    ActionSheet(title: Text("Export Data"), buttons: [
                        .default(Text("Generate PDF Report")) {
                            generatePDF()
                        },
                        .default(Text("Export Point Cloud (CSV)")) {
                            exportCSV()
                        },
                        .cancel()
                    ])
                }
            }
            .navigationTitle("Scan Results")
            .navigationBarItems(trailing: Button("Done") {
                // Return to scan
            })
        }
    }
    
    func generatePDF() {
        // Report logic
    }
    
    func exportCSV() {
        // CSV logic
    }
}
