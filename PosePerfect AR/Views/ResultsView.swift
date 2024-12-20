//
//  ResultsView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/19/24.
//

import SwiftUI

struct ResultsView: View {
    let results: SquatEvaluationResults
    var onGoBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Squat Evaluation Results")
                .font(.largeTitle)
                .padding(.top, 40)
            
            Text(results.perfectFormAchieved ?
                 "Perfect form! 100% of the bottom squat frames were correct." :
                 "Needs Improvement! Correctness: \(String(format: "%.2f", results.correctnessPercentage))%")
                .font(.headline)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Average knee angle at bottom: \(String(format: "%.2f", results.averageKneeAngleAtBottom))°")
                Text("Average knee deviation: \(String(format: "%.2f", results.averageKneeDeviation))°")
                Text("Average torso deviation: \(String(format: "%.2f", results.averageTorsoDeviation))°")
            }
            .font(.body)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onGoBack()
            }) {
                Text("Back to Main Menu")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
