//
//  PosePerfect_ARApp.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import SwiftUI
import SwiftData

@main
struct PosePerfect_ARApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ARFrameModel.self,
            ARSkeletonModel.self,
            JointModel.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)  // Pass the container to SwiftData
    }
}
