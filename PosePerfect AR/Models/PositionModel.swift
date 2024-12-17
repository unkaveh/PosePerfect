//
//  PositionModel.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import Foundation
import simd

struct PositionModel: Codable {
    var x: Float
    var y: Float
    var z: Float
    
    // Initialize with SIMD3<Float>
    init(from simd: SIMD3<Float>) {
        self.x = simd.x
        self.y = simd.y
        self.z = simd.z
    }
    
    // Convert back to SIMD3<Float>
    func toSIMD3() -> SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}
