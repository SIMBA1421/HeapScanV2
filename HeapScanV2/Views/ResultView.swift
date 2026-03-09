import SwiftUI
import SceneKit
import WebKit

struct ResultView: View {
    @ObservedObject var session: ScanSession
    @State private var showingExportMenu = false
    @State private var showingReport = false
    @State private var generatedPDFUrl: URL?

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
                    Section(header: Text("Measurements (Density: \(session.density, specifier: "%.2f") t/m³)")) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(session.measurement?.volume ?? 0.0, specifier: "%.2f") m³")
                                .bold()
                        }
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\(session.weight, specifier: "%.2f") tonnes")
                                .bold()
                                .foregroundColor(.blue)
                        }
                        HStack {
                            Text("Base Area")
                            Spacer()
                            Text("\(session.measurement?.baseArea ?? 0.0, specifier: "%.2f") m²")
                                .bold()
                        }
                    }
                    
                    if let loc = session.location {
                        Section(header: Text("Location")) {
                            HStack {
                                Text("Coordinates")
                                Spacer()
                                Text("\(loc.coordinate.latitude, specifier: "%.4f"), \(loc.coordinate.longitude, specifier: "%.4f")")
                                    .font(.caption)
                            }
                            Link("Open in Google Maps", destination: URL(string: "https://www.google.com/maps?q=\(loc.coordinate.latitude),\(loc.coordinate.longitude)")!)
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
            .sheet(isPresented: $showingReport) {
                if let url = generatedPDFUrl {
                    ActivityViewController(activityItems: [url])
                }
            }
        }
    }
    
    func generatePDF() {
        if let url = ReportService.shared.generatePDF(session: session, snapshot: nil) {
            self.generatedPDFUrl = url
            self.showingReport = true
        }
    }
    
    func exportCSV() {
        // Build CSV string
        var csvText = "X,Y,Z,R,G,B\n"
        guard let points = session.processedCloud?.points, let colors = session.processedCloud?.colors else { return }
        
        for i in 0..<points.count {
            csvText += "\(points[i].x),\(points[i].y),\(points[i].z),\(colors[i].x),\(colors[i].y),\(colors[i].z)\n"
        }
        
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("HeapScan_Export_\(Date().timeIntervalSince1970).csv")
        try? csvText.write(to: path, atomically: true, encoding: .utf8)
        
        self.generatedPDFUrl = path
        self.showingReport = true
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
