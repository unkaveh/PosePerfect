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

    @State private var showARView = false  // State to toggle between views

    var body: some Scene {
        WindowGroup {
            if showARView {
                CameraView(showARView: $showARView)
            } else {
                MainMenuView(showARView: $showARView)
            }
        }
        .modelContainer(sharedModelContainer)  // Pass the container to SwiftData
    }
}

#Preview {
    // Preview the MainMenuView first (default state)
    @Previewable @State var showARView = false

    return Group {
        if showARView {
            CameraView(showARView: .constant(showARView))
        } else {
            MainMenuView(showARView: .constant(showARView))
        }
    }
}
