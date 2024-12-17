import SwiftUI
import RealityKit

struct CameraView: View {
    @Binding var showARView: Bool  // Allows navigation back to ContentView
    @StateObject private var viewModel = CameraViewModel()  // Initialize ViewModel
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)  // Render the AR view
            
            // Overlay for recording buttons
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        viewModel.startRecording()
                    }) {
                        Text("Start Recording")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.stopRecording()
                    }) {
                        Text("Stop Recording")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            
            // Back button to navigate back to MainMenuView
            VStack {
                HStack {
                    Button(action: {
                        showARView = false  // Navigate back to MainMenuView
                    }) {
                        Image(systemName: "arrow.left")
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel  // Pass ViewModel
    
    func makeUIView(context: Context) -> ARView {
        viewModel.setupARView()
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
