import RealityKit
import ARKit
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    let arView = ARView(frame: .zero)
    private var bodyTrackingService: ARBodyTrackingService?
    private let recorderViewModel = RecorderViewModel()
    
    func setupARView() {
        // Previously, we configured AR here. Now ARBodyTrackingService handles configuration.
        // Just initialize the ARBodyTrackingService with the arView.
        bodyTrackingService = ARBodyTrackingService(arView: arView)
        
        // Set the onFrameUpdate closure to forward frames to the recorder.
        bodyTrackingService?.setFrameUpdateHandler { [weak self] frame in
            self?.recorderViewModel.appendFrame(frame: frame)
        }
    }
    
    func startRecording() {
        print("Recording started")
        recorderViewModel.startRecording(for: arView)
    }
    
    func stopRecording() {
        print("Recording stopped")
        recorderViewModel.stopRecording()
    }
}
