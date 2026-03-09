import SwiftUI
import ARKit

struct LiDARScanView: View {
    @StateObject private var captureService = LiDARCaptureService()
    @State private var processor = PointCloudProcessor()
    @State private var calculator = VolumeCalculator()
    @State private var showingResult = false
    @State private var currentVolume: Double = 0
    @AppStorage("userName") private var userName = "Operator"
    @AppStorage("defaultDensity") private var density = 1.6
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("SCANNING: \(captureService.guidance)")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    if captureService.isAutoCaptureEnabled {
                        captureService.stopSession()
                        currentVolume = calculator.calculateVolume(cloud: captureService.pointCloudFlow)
                        showingResult = true
                    } else {
                        captureService.startSession()
                    }
                    captureService.isAutoCaptureEnabled.toggle()
                }) {
                    Circle()
                        .fill(captureService.isAutoCaptureEnabled ? .red : .white)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                }
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showingResult) {
            ResultView(
                volume: currentVolume,
                weight: currentVolume * density,
                operatorName: userName
            )
        }
    }
}
