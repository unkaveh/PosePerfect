//
//  VideoGalleryView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//
import SwiftUI

struct VideoGalleryView: View {
    @StateObject private var viewModel = VideoGalleryViewModel()
    @State private var selectedVideo: RecordedVideoItem?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.videos) { video in
                        VStack {
                            Image(uiImage: video.thumbnail)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedVideo = video
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Recordings")
            .sheet(item: $selectedVideo) { video in
                VideoPlayerView(video: video, onSave: { url in
                    viewModel.saveToPhotoLibrary(videoURL: url) { success in
                        print(success ? "Saved to photos" : "Failed to save")
                    }
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var showARView = false
    VideoGalleryView()
}
