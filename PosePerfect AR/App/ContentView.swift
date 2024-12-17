//
//  ContentView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showARView = false

    var body: some View {
        if showARView {
            CameraView(showARView: $showARView)  // Render the CameraView
        } else {
            MainMenuView(showARView: $showARView)  // Render the MainMenuView
        }
    }

}

#Preview {
    ContentView()
}
