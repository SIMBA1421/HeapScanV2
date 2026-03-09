import SwiftUI
import ARKit

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let pc = viewModel.currentPointCloud {
                LivePointCloudView(pointCloud: pc, qualityMap: viewModel.qualityMap)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Frames: \(viewModel.frameCount)/\(Constants.maxFrames)")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("Quality: \(Int(viewModel.qualityScore * 100))%")
                            .foregroundColor(viewModel.qualityScore > 0.8 ? .green : .orange)
                            .font(.subheadline)
                    }
                    .padding()
                    Spacer()
                    Button(action: {
                        // Settings
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.5)))
                    }
                    .padding()
                }
                
                Spacer()
                
                if viewModel.isScanning {
                    Text(viewModel.guidanceMessage)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.7)))
                }
                
                Spacer()
                
                HStack {
                    if let thumbnail = viewModel.lastCaptureThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                    } else {
                        Spacer().frame(width: 80)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isScanning {
                            viewModel.finishScanning()
                        } else {
                            viewModel.startScanning()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(viewModel.isScanning ? Color.red : Color.white)
                                .frame(width: 65, height: 65)
                        }
                    }
                    
                    Spacer()
                    Spacer().frame(width: 80) // Balance
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $viewModel.showResults) {
            if let session = viewModel.session {
                ResultView(session: session)
            }
        }
    }
}
