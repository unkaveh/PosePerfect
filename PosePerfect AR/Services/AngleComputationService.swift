//
//  AngleComputationService.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/19/24.
//

import ARKit
import simd

class AngleComputationService {
    static func computeJointAngles(from frame: ARFrame) -> [String: Float] {
        var jointAngles: [String: Float] = [:]
        
        for anchor in frame.anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            let skeleton = bodyAnchor.skeleton
            
            // Compute knee angle
            if let leftKneeAngle = computeKneeAngle(skeleton: skeleton, side: .left) {
                jointAngles["leftKneeAngle"] = leftKneeAngle
            }
            if let rightKneeAngle = computeKneeAngle(skeleton: skeleton, side: .right) {
                jointAngles["rightKneeAngle"] = rightKneeAngle
            }
            
            // Compute hip angle
            if let leftHipAngle = computeHipAngle(skeleton: skeleton, side: .left) {
                jointAngles["leftHipAngle"] = leftHipAngle
            }
            if let rightHipAngle = computeHipAngle(skeleton: skeleton, side: .right) {
                jointAngles["rightHipAngle"] = rightHipAngle
            }
        }
        
        return jointAngles
    }
    
    private static func computeKneeAngle(skeleton: ARSkeleton3D, side: Side) -> Float? {
        let hipJoint = side == .left ? "left_upLeg_joint" : "right_upLeg_joint"
        let kneeJoint = side == .left ? "left_leg_joint" : "right_leg_joint"
        let ankleJoint = side == .left ? "left_foot_joint" : "right_foot_joint"
        
        guard let hipTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: hipJoint)),
              let kneeTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: kneeJoint)),
              let ankleTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: ankleJoint)) else {
            return nil
        }
        
        let hipPosition = simd_make_float3(hipTransform.columns.3)
        let kneePosition = simd_make_float3(kneeTransform.columns.3)
        let anklePosition = simd_make_float3(ankleTransform.columns.3)
        
        let thighVector = kneePosition - hipPosition
        let calfVector = anklePosition - kneePosition
        
        return angleBetweenVectors(thighVector, calfVector)
    }
    
    private static func computeHipAngle(skeleton: ARSkeleton3D, side: Side) -> Float? {
        let spineJoint = "spine_2_joint"
        let hipJoint = side == .left ? "left_upLeg_joint" : "right_upLeg_joint"
        let kneeJoint = side == .left ? "left_leg_joint" : "right_leg_joint"
        
        guard let spineTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: spineJoint)),
              let hipTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: hipJoint)),
              let kneeTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: kneeJoint)) else {
            return nil
        }
        
        let spinePosition = simd_make_float3(spineTransform.columns.3)
        let hipPosition = simd_make_float3(hipTransform.columns.3)
        let kneePosition = simd_make_float3(kneeTransform.columns.3)
        
        let spineVector = hipPosition - spinePosition
        let thighVector = kneePosition - hipPosition
        
        return angleBetweenVectors(spineVector, thighVector)
    }
    
    private static func angleBetweenVectors(_ v1: SIMD3<Float>, _ v2: SIMD3<Float>) -> Float {
        let dotProduct = simd_dot(v1, v2)
        let magnitudeProduct = simd_length(v1) * simd_length(v2)
        let angle = acos(dotProduct / magnitudeProduct)
        return angle * (180 / .pi) // Convert to degrees
    }
    
    private enum Side {
        case left
        case right
    }
}
