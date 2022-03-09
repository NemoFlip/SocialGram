//
//  ImageGridView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 25.01.2022.
//

import SwiftUI

struct ImageGridView: View {
    @ObservedObject var posts: PostArrayObject //Заменить потом на environmentObject
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 3),
                            GridItem(.flexible(), spacing: 3)
                            ,GridItem(.flexible(), spacing: 3)],
                  alignment: .center,
                  spacing: 3,
                  pinnedViews: []) {
            ForEach(posts.dataArray) { post in
                NavigationLink {
                    FeedView(posts: PostArrayObject(post: post), title: "Explore")
                } label: {
                    PostView(showHeaderAndFooter: false, post: post, addHeartAnimationToView: false)
                }

                
            }
        }
        
    }
}

struct ImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGridView(posts: PostArrayObject(userID: ""))
            .previewLayout(.sizeThatFits)
    }
}
