import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: RecordedVideoItem
    let onSave: (URL) -> Void
    
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Full height for player
            } else {
                ProgressView("Loading...")
            }

            HStack {
                Button("Save to Photos") {
                    onSave(video.videoURL)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            Spacer() // Ensure content fills space properly
        }
        .onAppear {
            player = AVPlayer(url: video.videoURL)
        }
        .navigationBarTitle(video.videoURL.lastPathComponent, displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full height for the entire view
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Add optional background
    }
}
