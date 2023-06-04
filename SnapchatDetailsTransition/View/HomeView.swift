//
//  HomeView.swift
//  SnapchatDetailsTransition
//
//  Created by Osaretin Uyigue on 5/12/23.
//

import SwiftUI

struct HomeView: View {
    @State private var videoFiles: [VideoFile] = files
    @State private var isExpanded: Bool = false
    @Namespace private var namespace
    @State private var expandedID: String?

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
                .padding(.horizontal)
                .padding(.vertical, 10)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 10) {
                    ForEach($videoFiles) { $file in
                        if expandedID == file.id.uuidString && isExpanded {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 300)
                        } else {
                            CardView(videoFile: $file, isExpanded: $isExpanded, animationID: namespace) {
                                /// - We're going to leave this empty
                                OverlayView()
                            }
                            .frame(height: 300)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                    expandedID = file.id.uuidString
                                    isExpanded = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .overlay {
            if let expandedID, isExpanded {
                /// Displaying Details View with Animation
                DetailsView(videoFile: $videoFiles.index(expandedID), isExpanded: $isExpanded, animationID: namespace)
                
                /// - Adding Transition for Smooth Expansion
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.7)) {
                            isExpanded = false
                        }
                    }
            }
        }
    }
    
   
}


extension HomeView {
    
    @ViewBuilder
    private func OverlayView() -> some View {
        VStack {
            HStack {
               Image("Pic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iJustine")
                        .font(.callout)
                        .fontWeight(.bold)
                    
                    Text("4 hr ago")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "bookmark")
                    .font(.title3)
                
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .rotationEffect(.init(degrees: -90))
            }
            .foregroundColor(.white)
            .frame(maxHeight: .infinity, alignment: .top)
            
            viewMoreEpisodesButton
        }
    }
    
    private var viewMoreEpisodesButton: some View {
        Button {
            
        } label: {
            Text("View More Episodes")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white))
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    shareButton
                }
        }

    }
    
    private var shareButton: some View {
        Button {
            
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.ultraThinMaterial))
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .headerButtonBG()
            button(image: "magnifyingglass")
            Spacer()
            button(image: "person.badge.plus")
            button(image: "ellipsis")
        }
        .overlay {
            Text("Stories")
                .font(.title3)
                .fontWeight(.black)
        }
    }
    
    
    @ViewBuilder
    private func button(image: String) -> some View {
        Button {
            //
        } label: {
            Image(systemName: image)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .headerButtonBG()
        }
    }
}

private struct DetailsView: View {
    @Binding var videoFile: VideoFile
    @Binding var isExpanded: Bool
    var animationID: Namespace.ID
    @GestureState private var isDragging = false
    var body: some View {
        CardView(videoFile: $videoFile, isExpanded: $isExpanded, animationID: animationID, isDetailsView: true) {
            //
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture()
                .updating($isDragging, body: { _, dragState, _ in
                    dragState = true
                }).onChanged({ value in
                    var translation = value.translation
                    translation = isDragging ? translation : .zero
                    videoFile.offset = translation
                }).onEnded({ value in
                    if value.translation.height > 200 {
                        /// - Closing video with animation
                        videoFile.player.pause()
                        
                        /// - First Closing View And In the Mid of Animation Resetting The player to start and hiding the video view
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            videoFile.player.seek(to: .zero)
                            videoFile.playVideo = false
                        }
                        
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.7)) {
                            closeVideoPlayer()
                        }
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) {
                            videoFile.offset = .zero
                        }
                    }
                   
                })
        )
        .onAppear {
            /// - Playing the Video as soon as the animation appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeInOut) {
                    videoFile.playVideo = true
                    videoFile.player.play()
                }
            }
        }
    }
    
    private func closeVideoPlayer() {
        videoFile.offset = .zero
        isExpanded = false
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Binding<[VideoFile]> {
    func index(_ id: String) -> Binding<VideoFile> {
        let index = self.wrappedValue.firstIndex { item in
            item.id.uuidString == id
        } ?? 0
        return self[index]
    }
}

extension View {
    func headerButtonBG() -> some View {
        self
        .frame(width: 40, height: 40)
        .background {
            Circle()
                .fill(.gray.opacity(0.1))
        }
    }
}
