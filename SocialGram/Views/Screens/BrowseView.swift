//
//  BrowseView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 25.01.2022.
//

import SwiftUI
struct BrowseView: View {
    @ObservedObject var posts: PostArrayObject
    var body: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: "browseViewRefresh") {
                posts.getFeedAndBrowsePosts(shuffled: true)
            }
            CarouselView()
            ImageGridView(posts: posts)
        }
        .coordinateSpace(name: "browseViewRefresh")
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrowseView(posts: PostArrayObject(userID: ""))
        }
    }
}
