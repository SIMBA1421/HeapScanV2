import SwiftUI
import SceneKit
import ARKit

struct LivePointCloudView: UIViewRepresentable {
    var pointCloud: PointCloud
    var qualityMap: [[Double]] // 0-1 coverage map
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        context.coordinator.sceneView = view
        
        view.scene = SCNScene()
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = UIColor.black
        
        let rootNode = view.scene!.rootNode
        let pointCloudNode = context.coordinator.createPointCloudNode(from: pointCloud)
        rootNode.addChildNode(pointCloudNode)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let rootNode = uiView.scene?.rootNode {
            rootNode.childNodes.forEach { $0.removeFromParentNode() }
            let pointCloudNode = context.coordinator.createPointCloudNode(from: pointCloud)
            rootNode.addChildNode(pointCloudNode)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: LivePointCloudView
        weak var sceneView: SCNView?
        
        init(_ parent: LivePointCloudView) {
            self.parent = parent
        }
        
        func createPointCloudNode(from cloud: PointCloud) -> SCNNode {
            let numPoints = cloud.points.count
            if numPoints == 0 { return SCNNode() }
            
            var scnVectors = cloud.points.map { SCNVector3($0.x, $0.y, $0.z) }
            
            let geometrySource = SCNGeometrySource(vertices: scnVectors)
            let colors = cloud.colors.map { SCNVector3($0.x, $0.y, $0.z) }
            
            // Assign gradient based on coverage data
            let colorSource = SCNGeometrySource(colors: colors)
            
            var indices: [Int32] = (0..<Int32(numPoints)).map { $0 }
            let geometryElement = SCNGeometryElement(indices: indices, primitiveType: .point)
            
            geometryElement.maximumPointScreenSpaceRadius = 5.0
            geometryElement.minimumPointScreenSpaceRadius = 1.0
            geometryElement.pointSize = 3.0
            
            let geometry = SCNGeometry(sources: [geometrySource, colorSource], elements: [geometryElement])
            geometry.firstMaterial?.diffuse.contents = UIColor.white
            geometry.firstMaterial?.isDoubleSided = true
            
            return SCNNode(geometry: geometry)
        }
    }
}
