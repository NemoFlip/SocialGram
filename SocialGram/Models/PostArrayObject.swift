//
//  PostArrayObject.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 23.01.2022.
//

import Foundation

class PostArrayObject: ObservableObject {
    @Published var dataArray = [PostModel]()
    @Published var postCount = "0"
    @Published var likeCount = "0"
    /// FOR SINGLE POST SELECTION
    init(post: PostModel) {
        self.dataArray.append(post)
    }
    /// USED FOR GETTING POSTS FOR USER
    init(userID: String) {
        DataService.instance.downloadPostForUser(userID: userID) { posts in
            let sortedPosts = posts.sorted(by: {$0.dateCreated > $1.dateCreated})
            self.dataArray.append(contentsOf: sortedPosts)
            self.getLikeAndPostCount()
        }
    }
    /// USED FOR GETTING POSTS FOR FEED
    init(shuffled: Bool) {
        DataService.instance.downloadPostForFeed { posts in
            if shuffled {
                let shuffledPosts = posts.shuffled()
                self.dataArray.append(contentsOf: shuffledPosts)
            } else {
                self.dataArray.append(contentsOf: posts)
            }
        }
    }
    func getLikeAndPostCount() {
        self.postCount = "\(self.dataArray.count)"
        
        let likeCountArray = dataArray.map { existingModel in
            return existingModel.likeCount
        }
        
        self.likeCount = likeCountArray.reduce(0, +).suffixNumber()
    }
    func getFeedAndBrowsePosts(shuffled: Bool) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.instance.downloadPostForFeed { [self] posts in
                print(posts.count != self.dataArray.count)
                if posts.count != self.dataArray.count {
                    self.dataArray = []
                    DispatchQueue.main.async {
                        if shuffled {
                            let shuffledPosts = posts.shuffled()
                            self.dataArray.append(contentsOf: shuffledPosts)
                        } else {
                            self.dataArray.append(contentsOf: posts)
                        }
                    }
                }
            }
        }
    }
    func getPostsForUser(userID: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.instance.downloadPostForUser(userID: userID) { posts in
                if (posts.count != self.dataArray.count) {
                    self.dataArray = []
                    DispatchQueue.main.async {
                        self.dataArray.append(contentsOf: posts)
                        self.getLikeAndPostCount()
                    }
                } else if (posts.map({$0.likeCount}).reduce(0, +) != self.dataArray.map({$0.likeCount}).reduce(0, +)) {
                    self.likeCount = String(posts.map({$0.likeCount}).reduce(0, +))
                }
            }
        }
    }
}
