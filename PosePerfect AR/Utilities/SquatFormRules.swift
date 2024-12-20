//
//  SquatFormRules.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/19/24.
//

import Foundation

struct SquatFormRules {
    // Knee angle range for correct squat depth (parallel)
    static let kneeAngleRange: ClosedRange<Float> = 70...100
    
    // Maximum torso angle from vertical allowed (to prevent excessive forward lean)
    static let maxTorsoAngle: Float = 45
    
    // Optional: Hip angle or other measurements can be added here.
    
    // Thresholds to identify standing vs bottom phases:
    // Standing is when knees are near full extension (>160°)
    // Going to set it at 140 for now
    static let standingKneeAngleThreshold: Float = 140.0
    
    // Ideal angles (for calculating percentage off)
    static let idealKneeAngle: Float = 85  // midpoint of 70–100
    static let idealTorsoAngle: Float = 0   // ideally as vertical as possible, but we only enforce a max
    
    // If you want to consider how to calculate "percentage off":
    // We can define a max deviation. For example, if knee angle should be 85 ideally,
    // and the user has 100, that's a 15° deviation. We might sum deviations and divide by count.
    // Similarly for torso angle.
}
