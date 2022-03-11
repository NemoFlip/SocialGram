//
//  FeedView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 23.01.2022.
//

import SwiftUI
import FirebaseAuth
import Firebase
struct FeedView: View {
    @ObservedObject var posts: PostArrayObject
    var title: String
    var body: some View {
        VStack {
            titleSection
            ScrollView {
                PullToRefresh(coordinateSpaceName: "PullToRefresh") {
                    posts.getFeedAndBrowsePosts(shuffled: false)
                    
                }
                LazyVStack {
                    ForEach(posts.dataArray) {
                        PostView(showHeaderAndFooter: true, post: $0, addHeartAnimationToView: true) {
                            posts.getFeedAndBrowsePosts(shuffled: false)
                        }
                    }
                }
            }.coordinateSpace(name: "PullToRefresh")
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedView(posts: PostArrayObject(userID: ""), title: "Socialgram")
        }
    }
}
extension FeedView {
    private var titleSection: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }.padding(.leading)
    }
}

