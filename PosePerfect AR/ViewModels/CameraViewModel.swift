import RealityKit
import ARKit
import SwiftUI

class CameraViewModel: NSObject, ObservableObject, ARSessionDelegate {
    let arView = ARView(frame: .zero)
    private var characterAnchor = AnchorEntity()
    private var jointEntities: [String: Entity] = [:]
    private let recorderViewModel = RecorderViewModel()
    
    func setupARView() {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("Body tracking is not supported on this device.")
        }
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(characterAnchor)
        initializeSkeletonEntities()
        
        // Set self as the session delegate
        arView.session.delegate = self
    }
    
    private func initializeSkeletonEntities() {
        let skeletonDef = ARSkeletonDefinition.defaultBody3D
        for jointName in skeletonDef.jointNames {
            let sphere = MeshResource.generateSphere(radius: 0.02)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let jointEntity = ModelEntity(mesh: sphere, materials: [material])
            characterAnchor.addChild(jointEntity)
            jointEntities[jointName] = jointEntity
        }
    }
    
    func startRecording() {
        print("Recording started")
        recorderViewModel.startRecording(for: arView)
    }
    
    func stopRecording() {
        print("Recording stopped")
        recorderViewModel.stopRecording()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Update character joints for visualization
        updateSkeletonPositions(from: frame)
        
        // Append the frame for recording
        recorderViewModel.appendFrame(frame: frame)
    }
    
    private func updateSkeletonPositions(from frame: ARFrame) {
        for anchor in frame.anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            let skeleton = bodyAnchor.skeleton
            let jointCount = skeleton.definition.jointCount
            for i in 0..<jointCount {
                let jointName = skeleton.definition.jointNames[i]
                let jointTransform = skeleton.jointModelTransforms[i]
                let worldJointTransform = bodyAnchor.transform * jointTransform
                let position = simd_make_float3(worldJointTransform.columns.3)
                
                if let jointEntity = jointEntities[jointName] {
                    jointEntity.position = position
                }
            }
        }
    }
}
