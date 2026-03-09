import SwiftUI
import Combine

class ScanViewModel: ObservableObject {
    @Published var currentPointCloud: PointCloud?
    @Published var frameCount: Int = 0
    @Published var isScanning: Bool = false
    @Published var qualityScore: Double = 0.0
    @Published var showResults: Bool = false
    @Published var guidanceMessage: String = "Ready to scan"
    @Published var lastCaptureThumbnail: UIImage?
    @Published var qualityMap: [[Double]] = []
    
    // Core references
    var session: ScanSession?
    var captureService = LiDARCaptureService()
    var processor = PointCloudProcessor()
    var qualityAnalyzer = QualityAnalyzer()
    
    private var trackingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        captureService.$pointCloudFlow.sink { [weak self] newCloud in
            guard let self = self, let newCloud = newCloud else { return }
            self.currentPointCloud = newCloud // Merge incoming points
            self.frameCount += 1
            self.analyzeQuality()
            self.generateThumbnail()
        }.store(in: &cancellables)
        
        captureService.$guidance.sink { [weak self] message in
            self?.guidanceMessage = message
        }.store(in: &cancellables)
    }
    
    func startScanning() {
        isScanning = true
        frameCount = 0
        session = ScanSession() // Start new trace
        currentPointCloud = PointCloud()
        guidanceMessage = "Move slowly over the stockpile"
        captureService.startSession() // Max performance profile
    }
    
    func finishScanning() {
        isScanning = false
        captureService.stopSession()
        
        guard let finalCloud = currentPointCloud else { return }
        guidanceMessage = "Processing model..."
        
        // Post-processing
        DispatchQueue.global(qos: .userInitiated).async {
            let processed = self.processor.processRawScan(finalCloud)
            let measurement = self.processor.calculateVolume(cloud: processed)
            
            DispatchQueue.main.async {
                self.session?.processedCloud = processed
                self.session?.measurement = measurement
                self.session?.overallQuality = self.qualityAnalyzer.averageCoverage
                self.showResults = true
            }
        }
    }
    
    private func analyzeQuality() {
        guard let cloud = currentPointCloud else { return }
        let quality = qualityAnalyzer.analyzeCoverage(cloud: cloud)
        self.qualityScore = quality.score
        self.qualityMap = quality.heatmap
        
        if quality.score < 0.6 {
            guidanceMessage = "Scan uncovered red areas"
        } else if quality.score > 0.9 {
            guidanceMessage = "Excellent coverage"
        } else {
            guidanceMessage = "Keep scanning evenly"
        }
        
         if captureService.isAutoCaptureEnabled && captureService.isStable() && quality.score > 0.85 {
             captureService.triggerAutoCapture()
         }
    }
    
    private func generateThumbnail() {
        // Render 2D View
    }
}
