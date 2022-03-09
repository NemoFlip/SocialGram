//
//  CommentsView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 24.01.2022.
//

import SwiftUI

struct CommentsView: View {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var displayName: String?
    @Environment(\.colorScheme) var colorScheme
    @State private var submissionText = ""
    @State private var commentsArray = [CommentsModel]()
    @State private var profilePicture: UIImage = UIImage(named: "logo.loading")!
    var post: PostModel
    var body: some View {
        VStack {
            allComentsSection
            addCommentSection
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getComments()
            getProfilePicture()
        }
        .padding(.horizontal, 6)
    }
    
    private func getComments() {
        //Get comments from DB
        guard self.commentsArray.isEmpty else { return }
        if let caption = post.caption, !caption.isEmpty {
            let captionComment = CommentsModel(commentID: "", userID: post.userID, username: post.username, content: caption, dateCreated: post.dateCreated, likedByUser: false, likeCount: 0)
            self.commentsArray.append(captionComment)
        }
        DataService.instance.downloadComments(postID: post.postID) { comments in
            self.commentsArray.append(contentsOf: comments)
            
        }
    }
    
    private func textIsAppropriate() -> Bool {
        let words = submissionText.components(separatedBy: " ")
        if words.contains("fuck") {
            return false
        }
        if submissionText.count < 3 {
            return false
        }
        return true
    }
    private func addComment() {
        guard let currentUserID = currentUserID, let displayName = displayName else {
            return
        }
        
        DataService.instance.uploadComment(postID: post.postID, content: submissionText, displayName: displayName, userID: currentUserID) { success, commentID in
            if success, let commentID = commentID {
                let newComment = CommentsModel(commentID: commentID, userID: currentUserID, username: displayName, content: submissionText, dateCreated: Date(), likedByUser: false, likeCount: 0)
                self.commentsArray.append(newComment)
                self.submissionText = ""
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        
    }
    private func getProfilePicture() {
        guard let currentUserID = currentUserID else {
            return
        }
        ImageManager.instance.downloadProfileImage(userID: currentUserID) { image in
            if let image = image {
                self.profilePicture = image
            }
        }
    }
    func deleteComment(commentID: String) {
        // Delete from db
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.instance.deleteComment(commentID: commentID, postID: post.postID) { success in
                if success {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            self.commentsArray = []
                            self.getComments()
                        }
                        
                    }
                    
                } else {
                    return
                }
            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CommentsView(post: PostModel(postID: "", userID: "", username: "", dateCreated: Date(), likeCount: 0, likedByUser: true))
        }
        .preferredColorScheme(.dark)
    }
}
extension CommentsView {
    private var addCommentSection: some View {
        HStack {
            Image(uiImage: profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(20)
            TextField("Add a comment here...", text: $submissionText)
            Button {
                if textIsAppropriate() {
                    addComment()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
            }
            .accentColor(colorScheme == .light ? Color.theme.purpleColor : .teal)
        }
        .padding(6)
    }
    private var allComentsSection: some View {
        ScrollView {
            LazyVStack {
                ForEach(commentsArray) {comment in
                    MessageView(comment: comment, likedByUser: comment.likedByUser, postID: post.postID)
                        .contextMenu(menuItems: {
                            if comment.userID == currentUserID && comment.commentID != "" {
                                Button(role: .destructive) {
                                    deleteComment(commentID: comment.commentID)
                                } label: {
                                    Label("Delete", systemImage: "xmark.circle")
                                }
                            }
                        })
                    Divider()
                }
            }
        }.padding(6)
    }
}
