import Combine
import RealityKit
import ARKit

class CameraViewModel: NSObject, ObservableObject {
    let arView = ARView(frame: .zero)
    private var bodyTrackingService: ARBodyTrackingService?
    private let recorderViewModel = RecorderViewModel()
    
    // Expose RecorderViewModel's status to CameraView
    @Published var recorderStatus: RecordingStatus = .idle
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        // Observe RecorderViewModel's status changes
        recorderViewModel.$status
            .receive(on: DispatchQueue.main)
            .assign(to: &$recorderStatus)
    }
    
    func setupARView() {
        bodyTrackingService = ARBodyTrackingService(arView: arView)
        
        bodyTrackingService?.setFrameUpdateHandler { [weak self] frame in
            self?.recorderViewModel.appendFrame(frame: frame)
        }
    }
    
    func startRecording() {
        recorderViewModel.startRecording(for: arView)
    }
    
    func stopRecording() {
        recorderViewModel.stopRecording()
    }
}

