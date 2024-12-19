//
//  VideoGalleryVideoModel.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//

import SwiftUI
import AVFoundation
import Photos

class VideoGalleryViewModel: ObservableObject {
    @Published var videos: [RecordedVideoItem] = []
    
    init() {
        loadVideos()
    }
    
    private func loadVideos() {
        // Load from documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Find all mov files
        if let enumerator = FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: nil) {
            var items: [RecordedVideoItem] = []
            for case let fileURL as URL in enumerator {
                guard fileURL.pathExtension == "mov" else { continue }
                
                // Check for matching .json file
                let baseName = fileURL.deletingPathExtension().lastPathComponent
                let jsonURL = documentsURL.appendingPathComponent("\(baseName).json")
                let jsonExists = FileManager.default.fileExists(atPath: jsonURL.path)
                
                // Generate thumbnail
                if let thumbnail = generateThumbnail(url: fileURL) {
                    let videoItem = RecordedVideoItem(videoURL: fileURL,
                                                      jsonURL: jsonExists ? jsonURL : nil,
                                                      thumbnail: thumbnail)
                    items.append(videoItem)
                }
            }
            
            // Sort by most recent or whatever ordering you prefer
            videos = items.sorted(by: { $0.videoURL.lastPathComponent > $1.videoURL.lastPathComponent })
        }
    }
    
    private func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 300, height: 300)
        
        let time = CMTime(seconds: 0.0, preferredTimescale: 600)
        let semaphore = DispatchSemaphore(value: 1)
        var generatedImage: CGImage?
        var generatedError: Error?
        
        semaphore.wait() // lock
        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
            if let cgImage = cgImage {
                generatedImage = cgImage
            } else if let error = error {
                generatedError = error
            }
            semaphore.signal()
        }
        
        semaphore.wait()  // wait until async call completes
        semaphore.signal() // release the lock
        
        if let cgImage = generatedImage {
            return UIImage(cgImage: cgImage)
        } else {
            if let error = generatedError {
                print("Failed to generate thumbnail: \(error)")
            }
            return nil
        }
    }
    
    func saveToPhotoLibrary(videoURL: URL, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success && error == nil)
                }
            }
        }
    }
}
