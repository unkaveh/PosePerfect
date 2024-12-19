//
//  ARBodyTrackingService.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/19/24.
//

import ARKit
import RealityKit

class ARBodyTrackingService: NSObject, ARSessionDelegate {
    private var arView: ARView
    private var characterAnchor: AnchorEntity
    private var jointEntities: [String: Entity] = [:]
    private var onFrameUpdate: ((ARFrame) -> Void)?
    
    init(arView: ARView) {
        self.arView = arView
        self.characterAnchor = AnchorEntity()
        super.init()
        setupARView()
    }
    
    func setupARView() {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("Body tracking is not supported on this device.")
        }
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(characterAnchor)
        initializeSkeletonEntities()
        
        // Set this service as the ARSession delegate
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
    
    func setFrameUpdateHandler(_ handler: @escaping (ARFrame) -> Void) {
        onFrameUpdate = handler
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateSkeletonPositions(from: frame)
        onFrameUpdate?(frame)
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
