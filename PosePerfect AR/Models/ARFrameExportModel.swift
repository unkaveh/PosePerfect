//
//  CodableARModels.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

// These are lightweight copies of my SwiftData models and are only used for JSON serialization and file export.
import Foundation
import simd

struct CodableARFrameModel: Codable {
    let timestamp: TimeInterval
    let skeletonData: [CodableARSkeletonModel]
    let jointAngles: [String: Float]
}

struct CodableARSkeletonModel: Codable {
    let joints: [CodableJointModel]
}

struct CodableJointModel: Codable {
    let name: String
    let position: [Float]  // Use an array of Floats for simplicity
    
    init(name: String, position: SIMD3<Float>) {
        self.name = name
        self.position = [position.x, position.y, position.z]  // Convert SIMD3 to array
    }
}


