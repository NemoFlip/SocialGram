//
//  MessageView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 24.01.2022.
//

import SwiftUI

struct MessageView: View {
    @AppStorage(CurrentUserDefaults.userID) var userID: String?
    @State var comment: CommentsModel
    @State var profilePicture: UIImage = UIImage(named: "logo.loading")!
    @State var likedByUser: Bool
    var postID: String
    var body: some View {
        HStack {
            profileImage
            commentSection
            Spacer(minLength: 0)
            if comment.commentID != "" {
                likeSection
            }
            
        }.contentShape(Rectangle())
            .onAppear {
                getProfilePicture()
            }
    }
    func likeMessage() {
        guard let userID = userID else {
            return
        }
        
        likedByUser.toggle()
        comment = CommentsModel(commentID: comment.commentID, userID: comment.userID, username: comment.username, content: comment.content, dateCreated: comment.dateCreated, likedByUser: true, likeCount: comment.likeCount + 1)
        DataService.instance.likeComment(commentID: comment.commentID, postID: postID, userID: userID)
    }
    func unlikeMessage() {
        guard let userID = userID else {
            return
        }
        likedByUser.toggle()
        comment = CommentsModel(commentID: comment.commentID, userID: comment.userID, username: comment.username, content: comment.content, dateCreated: comment.dateCreated, likedByUser: true, likeCount: comment.likeCount - 1)
        DataService.instance.unlikeComment(commentID: comment.commentID, postID: postID, userID: userID)
    }
    func getProfilePicture() {
        let userID = comment.userID
        ImageManager.instance.downloadProfileImage(userID: userID) { image in
            if let image = image {
                self.profilePicture = image
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static let commentModel = CommentsModel(commentID: "", userID: "", username: "Krider", content: "This is my outfit for today dwasdasdsadassadasa", dateCreated: Date(), likedByUser: false, likeCount: 0)
    static var previews: some View {
        MessageView(comment: commentModel, likedByUser: false, postID: "")
            .previewLayout(.sizeThatFits)
    }
}
extension MessageView {
    private var likeSection: some View {
        Button {
            if likedByUser {
                unlikeMessage()
            } else {
                likeMessage()
            }
        } label: {
            Image(systemName: likedByUser ? "heart.fill" : "heart")
                .foregroundColor(likedByUser ? .red : .black)
        }
    }
    private var profileImage: some View {
        NavigationLink {
            LazyView {
                ProfileView(isMyProfile: false, posts: PostArrayObject(userID: comment.userID), profileDisplayName: comment.username, profileUserID: comment.userID)
            }
            
        } label: {
            Image(uiImage: profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
        }
    }
    private var commentSection: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Group {
                    Text(comment.username + "  ")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    + Text(comment.content)
                        .font(.system(size: 15, weight: .regular, design: .default))
                    
                }.foregroundColor(.primary)
                
            }
            if comment.commentID != "" {
                HStack {
                    Text(comment.getDateCreated())
                    Text("\(comment.likeCount) \(comment.likeCount == 1 ? "like" : "likes")")
                }
                .foregroundColor(.secondary)
                .font(.system(size: 12, weight: .medium, design: .default))
            }
        }
    }
}
