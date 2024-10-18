//
//  RecipeCellView.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import SwiftUI
import Models
import Tools

struct RecipeCellView: View {
    @Environment(\.openURL) private var openURL
    
    var viewModel: Recipe.ViewModel
    
    @Binding var cellFrame: CGRect
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: viewModel.name)
                .frame(width: cellFrame.width)
                .bordered()
//            CacheAsyncImage.init(url: viewModel.thumbnailUrl ?? .init(fileURLWithPath: "photo"))
            AsyncImage.init(url: viewModel.thumbnailUrl) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.title)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                        .frame(width: cellFrame.width).cornerRadius(10)
                }
            }.frame(width: cellFrame.width).cornerRadius(10)
            Button {
                if let url = viewModel.sourceUrl {
                    openURL(url)
                }
            } label: {
                Text(verbatim: "Source: \(String(viewModel.sourceUrl?.path(percentEncoded: true) ?? String()))")
                    .lineLimit(1)
            }
            Button {
                if let url = viewModel.youtubeUrl {
                    openURL(url)
                }
            } label: {
                Text(verbatim: "YouTube: \(String(viewModel.youtubeUrl?.path(percentEncoded: true) ?? String()))")
                    .lineLimit(1)
            }
            Spacer()
        }
    }

}

struct RecipeCell_Previews: PreviewProvider {
    static var demo: Recipe.ViewModel = .mock
    @State static var frame: CGRect = .init(x: 0, y: 0, width: 340, height: 0)
    static var previews: some View {
        Group {
            RecipeCellView(viewModel: RecipeCell_Previews.demo, cellFrame: $frame)
        }
    }
}
