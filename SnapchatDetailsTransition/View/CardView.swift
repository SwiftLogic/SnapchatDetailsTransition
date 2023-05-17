//
//  CardView.swift
//  SnapchatDetailsTransition
//
//  Created by Osaretin Uyigue on 5/12/23.
//

import SwiftUI
import AVKit

struct CardView<Overlay: View>: View {
    var overlay: Overlay
    @Binding var videoFile: VideoFile
    @Binding var isExpanded: Bool
    var animationID: Namespace.ID
    var isDetailsView: Bool = false
    
    init(videoFile: Binding<VideoFile>,
         isExpanded: Binding<Bool>,
         animationID: Namespace.ID,
         isDetailsView: Bool = false,
         @ViewBuilder overlay: @escaping() ->Overlay) {
        
        self._videoFile = videoFile
        self._isExpanded = isExpanded
        self.isDetailsView = isDetailsView
        self.animationID = animationID
        self.overlay = overlay()
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            /// - Displaying Thumbail Instead of showing paused video
            /// - For Saving Memory
            /// - Displaying Thumbnail
//            CustomVideoPlayer(player: videoFile.player)
//                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            if let thumbnail = videoFile.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .onAppear {
                        extractImageAt(time: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) { thumbnail in
                            videoFile.thumbnail = thumbnail
                        }
                    }
            }
        }
    }
}


extension CardView {
    private func extractImageAt(time: CMTime,
                                size: CGSize,
                                completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            let asset = AVAsset(url: videoFile.fileURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = size
            
            Task {
                do {
                    let cgImage = try await generator.image(at: time)
                    let thumbnail = UIImage(cgImage: cgImage.image)
                    await MainActor.run(body: {
                        completion(thumbnail)
                    })
                } catch let thumbnailGeneratorError {
                    print("Failed to Fetch Thumbnail, \(thumbnailGeneratorError.localizedDescription)")
                }
            }
        }
        
    }
    
}



struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
