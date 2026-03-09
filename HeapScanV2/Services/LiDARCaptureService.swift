import ARKit
import Combine
import CoreMotion
import AudioToolbox

// Max performance LiDAR service
class LiDARCaptureService: NSObject, ARSessionDelegate {
    private var arSession = ARSession()
    private var motionManager = CMMotionManager()
    
    @Published var pointCloudFlow: PointCloud?
    @Published var guidance: String = "Initialize"
    
     var isAutoCaptureEnabled = true
     private var lastCaptureTime = Date()
    
    private let confidenceThreshold: Float = 0.85
    private let stabilizationWindow: TimeInterval = 0.5
    private let maxAngularVelocity: Double = 0.1
    
    override init() {
        super.init()
        arSession.delegate = self
        setupMotion()
    }
    
    func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        } else {
            fatalError("LiDAR is required for HeapScanV2")
        }
        
        // Maximum frame rate implicitly (no power saving modes enabled)
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopSession() {
        arSession.pause()
        motionManager.stopGyroUpdates()
    }
    
    private func setupMotion() {
        motionManager.gyroUpdateInterval = 0.1
        motionManager.startGyroUpdates()
    }
    
    func isStable() -> Bool {
        guard let gyroData = motionManager.gyroData else { return false }
        let isQuiet = abs(gyroData.rotationRate.x) < maxAngularVelocity &&
                      abs(gyroData.rotationRate.y) < maxAngularVelocity &&
                      abs(gyroData.rotationRate.z) < maxAngularVelocity
        return isQuiet
    }
    
    func triggerAutoCapture() {
        let now = Date()
        if now.timeIntervalSince(lastCaptureTime) > 1.0 { // Minimum 1s gap
            AudioServicesPlaySystemSound(1520) // Haptic peek
            lastCaptureTime = now
            guidance = "Auto Captured"
        }
    }
    
    // ARKit Delegate to process raw depth
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let depthData = frame.sceneDepth ?? frame.smoothedSceneDepth else { return }
        
        let depthBuffer = depthData.depthMap
        let confidenceBuffer = depthData.confidenceMap
        
        // CVPixelBuffer processing to extract points
        // In a real implementation we would convert the dense depth map + camera intrinsics into 3D points
        var newPoints = [Vector3]()
        var newColors = [Vector3]()
        
        // Mock processing for skeleton
        for _ in 0..<100 {
            newPoints.append(Vector3(x: Float.random(in: -5...5), y: Float.random(in: -2...0), z: Float.random(in: -5...5)))
            newColors.append(Vector3(x: 1, y: 1, z: 1)) // White default
        }
        
        let cloud = PointCloud(points: newPoints, colors: newColors)
        
        DispatchQueue.main.async {
            self.pointCloudFlow = cloud
        }
    }
}
