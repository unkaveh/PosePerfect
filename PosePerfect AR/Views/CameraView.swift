import SwiftUI
import RealityKit

struct CameraView: View {
    @Binding var showARView: Bool
    @EnvironmentObject var recorderViewModel: RecorderViewModel
    @StateObject private var viewModel = CameraViewModel()
    
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var snackbarBgColor: Color = .gray
    @State private var snackbarIcon: String? = nil
    @State private var snackbarIconColor: Color = .white

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
            
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
            
            SnackbarView(
                show: $showSnackbar,
                bgColor: snackbarBgColor,
                txtColor: .white,
                icon: snackbarIcon,
                iconColor: snackbarIconColor,
                message: snackbarMessage
            )
            
            VStack {
                HStack {
                    Button(action: {
                        showARView = false
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
        .onAppear {
            // Provide the shared recorderViewModel to CameraViewModel
            viewModel.setRecorderViewModel(recorderViewModel)
        }
        .onChange(of: viewModel.recorderStatus) {
            handleStatusChange(viewModel.recorderStatus)
        }
    }
    
    private func handleStatusChange(_ status: RecordingStatus) {
        switch status {
        case .idle:
            updateSnackbar(message: "Recording Idle", bgColor: .gray, icon: "pause.fill")
        case .recording:
            updateSnackbar(message: "Recording Started", bgColor: .green, icon: "record.circle.fill")
        case .saving:
            updateSnackbar(message: "Saving Recording...", bgColor: .blue, icon: "tray.and.arrow.down.fill")
        case .completed:
            updateSnackbar(message: "Recording Completed", bgColor: .green, icon: "checkmark.circle.fill")
        case .error:
            updateSnackbar(message: "Recording Failed", bgColor: .red, icon: "exclamationmark.triangle.fill")
        }
    }
    
    private func updateSnackbar(message: String, bgColor: Color, icon: String?) {
        snackbarMessage = message
        snackbarBgColor = bgColor
        snackbarIcon = icon
        showSnackbar = true
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIView(context: Context) -> ARView {
        viewModel.setupARView()
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
