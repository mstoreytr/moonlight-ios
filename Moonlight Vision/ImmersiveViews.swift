//
//  ImmersiveViews.swift
//  Moonlight Vision
//
//  Created by Mark Storey on 2/11/24.
//  Copyright © 2024 Moonlight Game Streaming Project. All rights reserved.
//
import Collections
import SwiftUI
import RealityKit

struct ImmersiveViews: View {
    
    @State var views: OrderedDictionary = ["Test": ImmersiveMoonlightSpaces(spaceID: "immersive-space", 
                                                                            title: "Test space",
                                                                            imageName: "building.2.fill")]
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(minimum: 200, maximum: 300))], content: {
                ForEach(views.keys, id: \.self) { key in
                    if let space = views[key] {
                        Button(action: {
                            Task {
                                let result = await openImmersiveSpace(id: space.spaceID)
                                if case .error = result {
                                    print("An error occurred")
                                }
                            }
                        }, label: {
                            HStack {
                                Text(space.title)
                                Image(systemName: space.imageName)
                                    .renderingMode(.template)
                            }
                        })
                    }
                }
            }).padding(50.0)
        }
        .safeAreaInset(edge: .bottom, content: {
            Button("Clear Space", role: .destructive) {
                Task {
                   await dismissImmersiveSpace()
                }
            }.padding()
        })
    }
}

struct ImmersiveMoonlightSpaces {
    let spaceID: String
    let title: String
    let imageName: String
}
