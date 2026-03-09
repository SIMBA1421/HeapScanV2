import Foundation
import UIKit
import CoreLocation

struct PointCloud {
    var points: [Vector3]
    var colors: [Vector3]
    
    init(points: [Vector3] = [], colors: [Vector3] = []) {
        self.points = points
        self.colors = colors
    }
}

struct Vector3 {
    var x: Float
    var y: Float
    var z: Float
}

struct HeapMeasurement {
    var volume: Double
    var baseArea: Double
    var maxHeight: Double
    var qualityScore: Double
}

class ScanSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var rawCloud: PointCloud?
    @Published var processedCloud: PointCloud?
    @Published var measurement: HeapMeasurement?
    @Published var overallQuality: Double = 0.0
    @Published var density: Double = UserDefaults.standard.double(forKey: "defaultDensity") == 0 ? 1.5 : UserDefaults.standard.double(forKey: "defaultDensity")
    @Published var location: CLLocation?
    
    var timestamp: Date = Date()
    var frameCount: Int = 0
    
    var weight: Double {
        return (measurement?.volume ?? 0) * density
    }
}

struct Constants {
    static let maxFrames = 1000
    static let recommendedCoverageThreshold = 0.85
    static let bundleID = "com.maaden.minescanner.v2"
}

// Pseudo RANSAC / SOR logic
struct RANSAC {
    static func removeBasePlane(from points: [Vector3], iterations: Int, threshold: Float) -> (plane: [Vector3], remainingPoints: [Vector3]) {
        return ([], points) // Stub
    }
}

struct StatisticalOutlierRemoval {
    static func filter(_ points: [Vector3], kNeighbors: Int, stdDevMult: Float) -> [Vector3] {
        return points // Stub
    }
}
