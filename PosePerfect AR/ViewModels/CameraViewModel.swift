import Combine
import RealityKit
import ARKit

class CameraViewModel: NSObject, ObservableObject {
    let arView = ARView(frame: .zero)
    private var bodyTrackingService: ARBodyTrackingService?
    private var recorderViewModel: RecorderViewModel?
    
    @Published var recorderStatus: RecordingStatus = .idle
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
    }
    
    func setRecorderViewModel(_ recorderViewModel: RecorderViewModel) {
        self.recorderViewModel = recorderViewModel
        recorderViewModel.$status
            .receive(on: DispatchQueue.main)
            .assign(to: &$recorderStatus)
    }
    
    func setupARView() {
        bodyTrackingService = ARBodyTrackingService(arView: arView)
        
        bodyTrackingService?.setFrameUpdateHandler { [weak self] frame in
            self?.recorderViewModel?.appendFrame(frame: frame)
        }
    }
    
    func startRecording() {
        guard let recorderViewModel = recorderViewModel else { return }
        recorderViewModel.startRecording(for: arView)
    }
    
    func stopRecording() {
        guard let recorderViewModel = recorderViewModel else { return }
        recorderViewModel.stopRecording()
    }
}
