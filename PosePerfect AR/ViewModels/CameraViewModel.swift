//
//  CameraViewModel.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import RealityKit
import ARKit


class CameraViewModel: NSObject, ObservableObject, ARSessionDelegate {
    let arView = ARView(frame: .zero)
    private var characterAnchor = AnchorEntity()
    private var jointEntities: [String: Entity] = [:]
    
    // Setup ARSession
    func setupARView() {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("Body tracking is not supported on this device.")
        }
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        arView.scene.addAnchor(characterAnchor)
        initializeSkeletonEntities()
        arView.session.delegate = self
    }
    
    // Initialize joint markers
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
        // Implement recording logic here
        print("Recording started")
    }
    
    func stopRecording() {
        // Implement stop recording logic here
        print("Recording stopped")
    }
}

extension CameraViewModel {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            updateJointPositions(skeleton: bodyAnchor.skeleton, rootTransform: bodyAnchor.transform)
        }
    }
    
    private func updateJointPositions(skeleton: ARSkeleton3D, rootTransform: simd_float4x4) {
        let jointCount = skeleton.definition.jointCount
        for i in 0..<jointCount {
            let jointName = skeleton.definition.jointNames[i]
            let jointTransform = skeleton.jointModelTransforms[i]
            let worldJointTransform = rootTransform * jointTransform
            let position = simd_make_float3(worldJointTransform.columns.3)
            
            if let jointEntity = jointEntities[jointName] {
                jointEntity.position = position
            }
        }
    }
}
