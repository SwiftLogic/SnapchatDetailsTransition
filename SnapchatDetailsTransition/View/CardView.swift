//
//  CardView.swift
//  SnapchatDetailsTransition
//
//  Created by Osaretin Uyigue on 5/12/23.
//

import SwiftUI

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
        }
    }
}   

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
