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

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
                .padding(.horizontal)
                .padding(.vertical, 10)
            
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 10) {
                    ForEach($videoFiles) { $file in
                        CardView(videoFile: $file, isExpanded: $isExpanded, animationID: namespace) {
                            /// - We're going to leave this empty
                            
                        }
                        .frame(height: 300)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
