//
//  MainMenuView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import SwiftUI

struct MainMenuView: View {
    @Binding var showARView: Bool  
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Body Tracking App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Button(action: {
                showARView = true  // Navigate to CameraView
            }) {
                Text("Camera")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                exit(0)
            }) {
                Text("Off")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
