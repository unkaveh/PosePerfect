//
//  RecorderViewModel.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//
import RealityKit
import ARKit
import AVFoundation
import UIKit
import VideoToolbox

class RecorderViewModel: NSObject, ObservableObject {
    private var recorder: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false
    private var recordingStartTime: Double?
    
    private var arDataPoints: [ARFrameModel] = []
    
    // Use a weak reference to avoid retain cycles if needed
    weak var arView: ARView? // TODO: Look up ARC (Automatic Reference Counting)
    private var arBodyTrackingService: ARBodyTrackingService?
    private var angleComputationService = AngleComputationService()

    func startRecording(for arView: ARView) {
        guard !isRecording else { return }
        isRecording = true
        self.arView = arView
        
        arBodyTrackingService = ARBodyTrackingService(arView: arView)
        arBodyTrackingService?.setFrameUpdateHandler { [weak self] frame in
            self?.handleFrameUpdate(frame)
        }
        
        let outputURL = generateOutputURL()
        do {
            recorder = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            
            // Get device screen dimensions dynamically
            let screenBounds = UIScreen.main.bounds
            let screenWidth = Int(screenBounds.width * UIScreen.main.scale)
            let screenHeight = Int(screenBounds.height * UIScreen.main.scale)

            // Setup video input with dynamic dimensions
            setupVideoInput(width: screenWidth, height: screenHeight)
            
            guard let recorder = recorder, let videoInput = videoInput, let pixelBufferAdaptor = pixelBufferAdaptor else { return }
            
            if recorder.canAdd(videoInput) {
                recorder.add(videoInput)
            }
            recorder.startWriting()
            // Don't start session yet; we start it on the first frame
            print("Recording setup complete: \(outputURL)")
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording, let recorder = recorder else { return }
        isRecording = false
        
        videoInput?.markAsFinished()
        recorder.finishWriting {
            print("Recording saved successfully.")
            self.saveARData()
        }
    }
    
    // Call this from CameraViewModel when ARFrame updates
    func appendFrame(frame: ARFrame) {
        guard isRecording,
              let recorder = recorder,
              recorder.status == .writing,
              let pixelBufferAdaptor = pixelBufferAdaptor,
              let videoInput = videoInput, videoInput.isReadyForMoreMediaData
        else { return }
        
        if recordingStartTime == nil {
            // First frame
            recordingStartTime = frame.timestamp
            recorder.startSession(atSourceTime: .zero)
        }
        
        let elapsedTime = frame.timestamp - (recordingStartTime ?? frame.timestamp)
        let presentationTime = CMTime(seconds: elapsedTime, preferredTimescale: 600)
        
        // Capture AR scene as UIImage
        arView?.snapshot(saveToHDR: false) { [weak self] uiImage in
            guard let self = self, let uiImage = uiImage else { return }
            // Get device screen dimensions dynamically
            let screenBounds = UIScreen.main.bounds
            let screenWidth = Int(screenBounds.width * UIScreen.main.scale)
            let screenHeight = Int(screenBounds.height * UIScreen.main.scale)
            
            // Convert UIImage to CVPixelBuffer
            guard let pixelBuffer = uiImage.pixelBuffer(width: screenWidth, height: screenHeight),
                  let pixelBufferAdaptor = self.pixelBufferAdaptor else {
                return
            }

            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            
            // Capture skeleton data after successfully appending frame
            self.captureFrameData(frame: frame)
        }

    }
    
    private func handleFrameUpdate(_ frame: ARFrame) {
        appendFrame(frame: frame)
        
        // Compute joint angles
        let jointAngles = AngleComputationService.computeJointAngles(from: frame)
        
        // You can use jointAngles here for real-time feedback or save them for later analysis
        print("Joint Angles: \(jointAngles)")
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
    private func setupVideoInput(width: Int, height: Int) {
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        videoInput?.expectsMediaDataInRealTime = true
        
        guard let videoInput = videoInput else { return }
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )
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

// MARK: - UIImage to CVPixelBuffer Extension
extension UIImage {
  /**
    Converts the image to an ARGB `CVPixelBuffer`.
  */
  public func pixelBuffer() -> CVPixelBuffer? {
    return pixelBuffer(width: Int(size.width), height: Int(size.height))
  }

  /**
    Resizes the image to `width` x `height` and converts it to an ARGB
    `CVPixelBuffer`.
  */
  public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_32ARGB,
                       colorSpace: CGColorSpaceCreateDeviceRGB(),
                       alphaInfo: .noneSkipFirst)
  }


  /**
    Resizes the image to `width` x `height` and converts it to a `CVPixelBuffer`
    with the specified pixel format, color space, and alpha channel.
  */
  public func pixelBuffer(width: Int, height: Int,
                          pixelFormatType: OSType,
                          colorSpace: CGColorSpace,
                          alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
    var maybePixelBuffer: CVPixelBuffer?
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     pixelFormatType,
                                     attrs as CFDictionary,
                                     &maybePixelBuffer)

    guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
      return nil
    }

    let flags = CVPixelBufferLockFlags(rawValue: 0)
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
      return nil
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }

    guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue)
    else {
      return nil
    }

    UIGraphicsPushContext(context)
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    UIGraphicsPopContext()

    return pixelBuffer
  }
}
