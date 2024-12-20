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

    // Create a single RecorderViewModel instance at the highest level
    @StateObject var recorderViewModel = RecorderViewModel()

    var body: some Scene {
        WindowGroup {
            // Pass the recorderViewModel as an environment object to both views
            if showARView {
                CameraView(showARView: $showARView)
                    .environmentObject(recorderViewModel)
            } else {
                MainMenuView(showARView: $showARView)
                    .environmentObject(recorderViewModel)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
