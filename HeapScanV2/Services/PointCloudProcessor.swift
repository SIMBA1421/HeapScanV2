import Foundation
import Accelerate

class PointCloudProcessor {
    func processRawScan(_ cloud: PointCloud) -> PointCloud {
        var processedPoints = cloud.points
        
        let removedGround = RANSAC.removeBasePlane(from: processedPoints, iterations: 1500, threshold: 0.05)
        let filteredClouds = StatisticalOutlierRemoval.filter(removedGround.remainingPoints, kNeighbors: 30, stdDevMult: 3.0)
        
        let sortedDesc = filteredClouds.sorted { $0.y > $1.y }
        var validPoints = [Vector3]()
        validPoints.append(contentsOf: sortedDesc)
        
        return .init(points: validPoints, colors: cloud.colors)
    }
    
    func calculateVolume(cloud: PointCloud) -> HeapMeasurement {
        var volume: Double = 0.0
        var baseArea: Double = 0.0
        var maxHeight: Double = 0.0
        
        guard cloud.points.count > 0 else { return HeapMeasurement(volume: 0, baseArea: 0, maxHeight: 0, qualityScore: 0) }
        
        let groundLevel = cloud.points.map { $0.y }.min() ?? 0
        let highestPoint = cloud.points.map { $0.y }.max() ?? 0
        
        maxHeight = Double(abs(highestPoint - groundLevel))
        
        let gridSize: Float = 0.1 // 10cm grid
        
        var grid = [String: [Float]]()
        
        for p in cloud.points {
            let col = Int(round(p.x / gridSize))
            let row = Int(round(p.z / gridSize))
            let key = "\(col),\(row)"
            
            if grid[key] == nil {
                grid[key] = [p.y]
            } else {
                grid[key]?.append(p.y)
            }
        }
        
        let cellArea = Double(gridSize * gridSize)
        
        for (key, heights) in grid {
            let avgH = heights.reduce(0, +) / Float(heights.count)
            let zDistanceToGround = abs(avgH - groundLevel)
            
            volume += Double(zDistanceToGround) * cellArea
            baseArea += cellArea
        }
        
        return HeapMeasurement(volume: volume, baseArea: baseArea, maxHeight: maxHeight, qualityScore: 0.95)
    }
}

class QualityAnalyzer {
    var averageCoverage: Double = 0.0
    
    func analyzeCoverage(cloud: PointCloud) -> (score: Double, heatmap: [[Double]]) {
        let densityMap = self.calculateKDE(points: cloud.points)
        let score = densityMap.flatMap { $0 }.reduce(0, +) / Double(densityMap.count * densityMap[0].count)
        
        self.averageCoverage = score * 0.8 + self.averageCoverage * 0.2 // EMA
        
        return (self.averageCoverage, densityMap)
    }
    
    private func calculateKDE(points: [Vector3]) -> [[Double]] {
        return Array(repeating: Array(repeating: 1.0, count: 10), count: 10) // Mock
    }
}
