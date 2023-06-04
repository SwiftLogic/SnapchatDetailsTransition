//
//  CardView.swift
//  SnapchatDetailsTransition
//
//  Created by Osaretin Uyigue on 5/12/23.
//

import SwiftUI
import AVKit

struct CardView<Overlay: View>: View {
    private let screenSize = UIScreen.main.bounds
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
                    .opacity(videoFile.playVideo ? 0 : 1)
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        /// - Displaying Video Player Only for Details View
                        if videoFile.playVideo && isDetailsView {
                            CustomVideoPlayer(player: videoFile.player)
                                .transition(.identity)
                        }
                    }
                    .overlay {
                        overlay
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .scaleEffect(scale)
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
        /// Adding Matched Geometry
        .matchedGeometryEffect(id: videoFile.id.uuidString, in: animationID)
        .offset(videoFile.offset)
        ///-  Make the card move around the center of the screen when the user drags it.
        .offset(y: videoFile.offset.height * -0.7)
    }
    
    private var scale: CGFloat {
        var yOffset = videoFile.offset.height
        /// - Applying scaling only when dragged downwards
        yOffset = yOffset < 0 ? 0 : yOffset
        var progress = yOffset / screenSize.height
        /// - Limiting Progress
        progress = 1 - (progress > 0.4 ? 0.4 : progress)
        /// - When the View is Closed Immediately Reset the Scale to 1, so matched geo can do it's thing
        return (isExpanded ? progress : 1)
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
                    let cgImage = try await generator.image(at: time).image
                    guard let colorCorrectedImage = cgImage.copy(colorSpace: CGColorSpaceCreateDeviceRGB()) else {return}
                    let thumbnail = UIImage(cgImage: colorCorrectedImage)
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
