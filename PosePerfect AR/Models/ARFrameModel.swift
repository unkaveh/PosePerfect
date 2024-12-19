//
//  ARFrameModel.swift swift Copy code .swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//
import Foundation
import SwiftData
import simd

@Model
class ARFrameModel {
    var timestamp: TimeInterval
    @Relationship(deleteRule: .cascade) var skeletonData: [ARSkeletonModel] = []
    var jointAngles: [String: Float] = [:]
    
    
    init(timestamp: TimeInterval, skeletonData: [ARSkeletonModel] = [], jointAngles: [String: Float] = [:]) {
        self.timestamp = timestamp
        self.skeletonData = skeletonData
        self.jointAngles = jointAngles
    }
}

@Model
class ARSkeletonModel {
    @Relationship(deleteRule: .cascade) var joints: [JointModel] = []
    
    init(joints: [JointModel] = []) {
        self.joints = joints
    }
}

@Model
class JointModel {
    var name: String
    var position: PositionModel  // Use PositionModel instead of SIMD3<Float> - active issue: https://developer.apple.com/forums/thread/763667?answerId=803624022#803624022

    init(name: String, position: PositionModel) {
        self.name = name
        self.position = position
    }
}
