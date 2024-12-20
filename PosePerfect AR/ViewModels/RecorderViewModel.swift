import RealityKit
import ARKit
import AVFoundation
import UIKit
import VideoToolbox
import CoreImage

class RecorderViewModel: NSObject, ObservableObject {
    @Published var status: RecordingStatus = .idle
    private var recorder: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false
    private var recordingStartTime: Double?
    
    private var arDataPoints: [ARFrameModel] = []
    
    // Use a weak reference to avoid retain cycles if needed
    weak var arView: ARView? // TODO: Look up ARC (Automatic Reference Counting)
    private var arBodyTrackingService: ARBodyTrackingService?
    private let angleComputationService = AngleComputationService()
    private let ciContext = CIContext()
    
    func startRecording(for arView: ARView) {
        guard !isRecording else { return }
        isRecording = true
        self.arView = arView
        arView.debugOptions.insert(.showStatistics)
        
        let outputURL = generateOutputURL()
        do {
            recorder = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            
            // Use device screen dimensions to preserve original aspect ratio
            let screenBounds = UIScreen.main.bounds
            let screenWidth = Int(screenBounds.width * UIScreen.main.scale)
            let screenHeight = Int(screenBounds.height * UIScreen.main.scale)

            setupVideoInput(width: screenWidth, height: screenHeight)
            
            guard let recorder = recorder, let videoInput = videoInput else { return }
            if recorder.canAdd(videoInput) {
                recorder.add(videoInput)
            }
            
            // Start writing immediately
            recorder.startWriting()
            recorder.startSession(atSourceTime: .zero)
            
            // Mark the start time for frames once we get the first ARFrame
            recordingStartTime = nil
            status = .recording
            print("Recording setup complete: \(outputURL)")
        } catch {
            status = .error
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording, let recorder = recorder else { return }
        isRecording = false
        status = .saving
        videoInput?.markAsFinished()
        recorder.finishWriting { [weak self] in
            guard let self = self else { return }
            print("Raw recording saved successfully.")
            status = .completed
            self.saveARData()
            // TODO: Post-processing after saving AR data
        }
    }
    
    func appendFrame(frame: ARFrame) {
        guard isRecording,
              let recorder = recorder,
              recorder.status == .writing,
              let pixelBufferAdaptor = pixelBufferAdaptor,
              let videoInput = videoInput,
              videoInput.isReadyForMoreMediaData else { return }

        if recordingStartTime == nil {
            // First frame: mark the start time
            recordingStartTime = frame.timestamp
        }
        
        // Calculate the presentation time based on ARFrame timestamps
        let elapsedTime = frame.timestamp - (recordingStartTime ?? frame.timestamp)
        let presentationTime = CMTime(seconds: elapsedTime, preferredTimescale: 600)
        
        let cameraPixelBuffer = frame.capturedImage
        guard let finalPixelBuffer = resizeAndOrientPixelBuffer(cameraPixelBuffer) else {
            return
        }
        
        pixelBufferAdaptor.append(finalPixelBuffer, withPresentationTime: presentationTime)
        
        // Capture skeleton data
        captureFrameData(frame: frame)
    }
    
    
    // MARK: - Capture AR Skeleton Data
    func captureFrameData(frame: ARFrame) {
        guard isRecording else { return }
        let jointAngles = AngleComputationService.computeJointAngles(from: frame)
        let dataPoint = ARFrameModel(
            timestamp: frame.timestamp,
            skeletonData: extractSkeletonData(from: frame),
            jointAngles: jointAngles
        )
        arDataPoints.append(dataPoint)
    }
    
    private func extractSkeletonData(from frame: ARFrame) -> [ARSkeletonModel] {
        var skeletonData: [ARSkeletonModel] = []
        for anchor in frame.anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                let skeleton = bodyAnchor.skeleton
                let jointPositions = skeleton.jointModelTransforms.enumerated().map { index, transform in
                    JointModel(
                        name: skeleton.definition.jointNames[index],
                        position: PositionModel(from: SIMD3<Float>(
                            transform.columns.3.x,
                            transform.columns.3.y,
                            transform.columns.3.z
                        ))
                    )
                }
                skeletonData.append(ARSkeletonModel(joints: jointPositions))
            }
        }
        return skeletonData
    }
    
    // MARK: - Save AR Data
    private func saveARData() {
        let codableData = arDataPoints.map { frame in
            CodableARFrameModel(
                timestamp: frame.timestamp,
                skeletonData: frame.skeletonData.map { skeleton in
                    CodableARSkeletonModel(
                        joints: skeleton.joints.map { joint in
                            CodableJointModel(
                                name: joint.name,
                                position: joint.position.toSIMD3()
                            )
                        }
                    )
                },
                jointAngles: frame.jointAngles
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(codableData)
            let outputURL = generateDataOutputURL()
            try data.write(to: outputURL)
            print("AR data saved at: \(outputURL)")
        } catch {
            print("Failed to save AR data: \(error)")
        }
    }
    
    // MARK: - Setup Video Input
    // TODO: adjust video so it looks better
    private func setupVideoInput(width: Int, height: Int) {
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        videoInput?.expectsMediaDataInRealTime = true
        videoInput?.transform = CGAffineTransform(rotationAngle: .pi/2)
        
        guard let videoInput = videoInput else { return }
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String : width,
                kCVPixelBufferHeightKey as String : height
            ]
        )
    }
    
    // MARK: - Resize and Orient Pixel Buffer
    private func resizeAndOrientPixelBuffer(_ srcPixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let screenBounds = UIScreen.main.bounds
        let targetWidth = Int(screenBounds.width * UIScreen.main.scale)
        let targetHeight = Int(screenBounds.height * UIScreen.main.scale)
        
        // Convert source pixel buffer to CIImage
        let ciImage = CIImage(cvPixelBuffer: srcPixelBuffer)
        
        // Create a scaled CIImage to the target size
        let scaleX = CGFloat(targetWidth) / ciImage.extent.width
        let scaleY = CGFloat(targetHeight) / ciImage.extent.height
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Create a new pixel buffer
        var outPixelBuffer: CVPixelBuffer?
        let attrs: [String:Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferWidthKey as String: targetWidth,
            kCVPixelBufferHeightKey as String: targetHeight,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        CVPixelBufferCreate(kCFAllocatorDefault, targetWidth, targetHeight, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &outPixelBuffer)
        
        guard let outputBuffer = outPixelBuffer else {
            return nil
        }
        
        ciContext.render(scaledImage, to: outputBuffer)
        
        return outputBuffer
    }

    // MARK: - Generate Output URLs
    private func generateOutputURL() -> URL {
        let filename = "PosePerfect_\(Date().timeIntervalSince1970).mov"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(filename)
    }
    
    private func generateDataOutputURL() -> URL {
        let filename = "PosePerfect_\(Date().timeIntervalSince1970).json"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(filename)
    }
}
