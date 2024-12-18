//
//  MainMenuView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import SwiftUI

struct MainMenuView: View {
    @Binding var showARView: Bool
    @State private var showGallery = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    // Show the AR view
                    showARView = true
                }) {
                    Text("Start AR Experience")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.cornerRadius(8))
                        .foregroundColor(.white)
                }

                Button(action: {
                    // Show video gallery view
                    showGallery = true
                }) {
                    Text("View Recorded Videos")
                        .font(.headline)
                        .padding()
                        .background(Color.green.cornerRadius(8))
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showGallery) {
                VideoGalleryView()
            }
            .navigationBarTitle("PosePerfect AR", displayMode: .inline)
        }
    }
}

#Preview {
    @Previewable @State var showARView = false
    MainMenuView(showARView: $showARView)
}

