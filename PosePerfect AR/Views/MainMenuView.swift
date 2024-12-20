import SwiftUI

struct MainMenuView: View {
    @Binding var showARView: Bool
    @State private var showGallery = false
    @State private var showResultsView = false
    @EnvironmentObject var recorderViewModel: RecorderViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    showARView = true
                }) {
                    Text("Start AR Experience")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.cornerRadius(8))
                        .foregroundColor(.white)
                }

                Button(action: {
                    showGallery = true
                }) {
                    Text("View Recorded Videos")
                        .font(.headline)
                        .padding()
                        .background(Color.green.cornerRadius(8))
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .navigationTitle("PosePerfect AR")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showGallery) {
                VideoGalleryView()
            }
            // When showResultsView is true, navigate to ResultsView
            .navigationDestination(isPresented: $showResultsView) {
                if let results = recorderViewModel.evaluationResults {
                    ResultsView(results: results) {
                        // On go back, reset the results and dismiss the ResultsView
                        recorderViewModel.evaluationResults = nil
                        showResultsView = false
                    }
                } else {
                    // If for some reason results are nil, just go back
                    Text("No Results Found")
                        .onAppear {
                            showResultsView = false
                        }
                }
            }
            // Observe changes in evaluationResults and navigate to ResultsView if needed
            .onReceive(recorderViewModel.$evaluationResults) { newValue in
                if newValue != nil {
                    // Display ResultsView
                    showResultsView = true
                }
            }
        }
    }
}
