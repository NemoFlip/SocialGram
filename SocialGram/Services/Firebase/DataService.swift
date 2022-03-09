//
//  DataService.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 15.02.2022.
//

import Foundation
import SwiftUI
import Firebase
class DataService {
    static let instance = DataService()
    private var REF_POSTS = DB_BASE.collection("posts")
    private var REF_REPORTS = DB_BASE.collection("reports")
    private var REF_FEEDBACK = DB_BASE.collection("feedback")
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    func uploadPost(image: UIImage, caption: String?, displayName: String, userID: String, handler: @escaping (_ success: Bool) -> ()) {
        let document = REF_POSTS.document()
        let postID = document.documentID
        ImageManager.instance.uploadPostImage(postID: postID, image: image) { success in
            if success {
                let postData: [String: Any] = [
                    DataBasePostField.displayName : displayName,
                    DataBasePostField.postID : postID,
                    DataBasePostField.userID : userID,
                    DataBasePostField.caption : caption,
                    DataBasePostField.dateCreated : FieldValue.serverTimestamp()
                ]
                document.setData(postData) { error in
                    if let error = error {
                        print(error)
                        handler(false)
                        return
                    } else {
                        handler(true)
                        return
                    }
                }
            } else {
                handler(false)
                return
            }
        }
    }
    func uploadReport(reason: String, postID: String, handler: @escaping (_ success: Bool) -> ()) {
        let data: [String : Any] = [
            DataBaseReportField.postID: postID,
            DataBaseReportField.content: reason,
            DataBaseReportField.dateCreated: FieldValue.serverTimestamp()
        ]
        REF_REPORTS.addDocument(data: data) { error in
            if let error = error {
                print("Error uploading report: \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
    func uploadFeedBack(content: String, userID: String, handler: @escaping (_ success: Bool) -> ()) {
        let data: [String: Any] = [
            DataBaseFeedBackField.userID : userID,
            DataBaseFeedBackField.content : content,
            DataBaseFeedBackField.dateCreated: FieldValue.serverTimestamp()
        ]
        REF_FEEDBACK.addDocument(data: data) { error in
            if let error = error {
                print("Error uploading feedback: \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
    func uploadComment(postID: String, content: String, displayName: String, userID: String, handler: @escaping (_ success: Bool,_ commentID: String?) -> ()) {
        let document = REF_POSTS.document(postID).collection(DataBasePostField.comments).document()
        let commentID = document.documentID
        let data: [String : Any] = [
            DataBaseCommentsField.userID : userID,
            DataBaseCommentsField.content : content,
            DataBaseCommentsField.commentID : commentID,
            DataBaseCommentsField.displayName : displayName,
            DataBaseCommentsField.dateCreated : FieldValue.serverTimestamp()
        ]
        document.setData(data) { error in
            if let error = error {
                print("Error uploading comment: \(error)")
                handler(false, nil)
                return
            } else {
                handler(true, commentID)
                return
            }
        }
        
        
    }
    func downloadPostForUser(userID: String, handler: @escaping (_ posts: [PostModel]) -> ()) {
        REF_POSTS.whereField(DataBasePostField.userID, isEqualTo: userID).getDocuments { snapshot, error in
            handler(self.getPostsFromSnapshot(snapshot: snapshot))
        }
    }
    func downloadComments(postID: String, handler: @escaping (_ comments: [CommentsModel]) -> ()) {
        REF_POSTS.document(postID).collection(DataBasePostField.comments).order(by: DataBaseCommentsField.dateCreated, descending: false).getDocuments { snapshot, error in
            handler(self.getComments(snapshot: snapshot))
        }
    }
    private func getComments(snapshot: QuerySnapshot?) -> [CommentsModel] {
        var commentsArray = [CommentsModel]()
        if let snapshot = snapshot, snapshot.documents.count > 0 {
            for document in snapshot.documents {
                if
                    let userID = document.get(DataBaseCommentsField.userID) as? String,
                    let displayName = document.get(DataBaseCommentsField.displayName) as? String,
                    let content = document.get(DataBaseCommentsField.content) as? String,
                    let timestamp = document.get(DataBaseCommentsField.dateCreated) as? Timestamp,
                    let currentUserID = currentUserID {
                let userIDArray = document.get(DataBaseCommentsField.likedBy) as? [String] ?? []
                let date = timestamp.dateValue()
                let commentID = document.documentID
                    let likeCount = document.get(DataBaseCommentsField.likeCount) as? Int ?? 0
                    let newComment = CommentsModel(commentID: commentID, userID: userID, username: displayName, content: content, dateCreated: date, likedByUser: userIDArray.contains(currentUserID), likeCount: likeCount)
                commentsArray.append(newComment)
                }
            }
            return commentsArray
        } else {
            print("No comments in document")
            return commentsArray
        }
    }
    func downloadPostForFeed(handler: @escaping (_ posts: [PostModel]) -> ()) {
        REF_POSTS.order(by: DataBasePostField.dateCreated, descending: true).limit(to: 50).getDocuments { snapshot, error in
            handler(self.getPostsFromSnapshot(snapshot: snapshot))
        }
    }
    private func getPostsFromSnapshot(snapshot: QuerySnapshot?) -> [PostModel] {
        var postArray = [PostModel]()
        if let snapshot = snapshot, snapshot.documents.count > 0 {
            for document in snapshot.documents {
                if
                    let userID = document.get(DataBasePostField.userID) as? String,
                    let displayName = document.get(DataBasePostField.displayName) as? String,
                    let timestamp = document.get(DataBasePostField.dateCreated) as? Timestamp {
                    
                        let date = timestamp.dateValue()
                        let postID = document.documentID
                        let caption = document.get(DataBasePostField.caption) as? String
                        let likeCount = document.get(DataBasePostField.likeCount) as? Int ?? 0
                        var likedByUser: Bool = false
                        if let userIDArray = document.get(DataBasePostField.likedBy) as? [String],
                           let currentUserID = currentUserID {
                            likedByUser = userIDArray.contains(currentUserID)
                        }
                        let newPost = PostModel(postID: postID, userID: userID, username: displayName,caption: caption, dateCreated: date, likeCount: likeCount, likedByUser: likedByUser)
                    postArray.append(newPost)
                }
                
            }
            return postArray
        } else {
            print("No documents for user")
            return postArray
        }
    }
    // MARK: UPDATE FUNCTIONS
    func likePost(postID: String, currentUserID: String) {
        let increment: Int64 = 1
        let data: [String: Any] = [
            DataBasePostField.likeCount: FieldValue.increment(increment),
            DataBasePostField.likedBy: FieldValue.arrayUnion([currentUserID])
        ]
        REF_POSTS.document(postID).updateData(data)
    }
    func unlikePost(postID: String, currentUserID: String) {
        let increment: Int64 = -1
        let data: [String: Any] = [
            DataBasePostField.likeCount: FieldValue.increment(increment),
            DataBasePostField.likedBy: FieldValue.arrayRemove([currentUserID])
        ]
        REF_POSTS.document(postID).updateData(data)
    }
    func updateDisplayNameOnPosts(userID: String, displayName: String) {
        downloadPostForUser(userID: userID) { posts in
            for post in posts {
                self.updatePostDisplayName(postID: post.postID, displayName: displayName)
            }
        }
    }
    private func updatePostDisplayName(postID: String, displayName: String) {
        let data: [String: Any] = [DataBasePostField.displayName: displayName]
        REF_POSTS.document(postID).updateData(data)
    }
    func likeComment(commentID: String, postID: String, userID: String) {
        let increment: Int64 = 1
        let data: [String: Any] = [DataBaseCommentsField.likeCount : FieldValue.increment(increment),
                                   DataBaseCommentsField.likedBy : FieldValue.arrayUnion([userID])
        ]
        REF_POSTS.document(postID).collection(DataBasePostField.comments).document(commentID).updateData(data)
    }
    func unlikeComment(commentID: String, postID: String, userID: String) {
        let increment: Int64 = -1
        let data: [String: Any] = [DataBaseCommentsField.likeCount : FieldValue.increment(increment),
                                   DataBaseCommentsField.likedBy : FieldValue.arrayRemove([userID])
        ]
        REF_POSTS.document(postID).collection(DataBasePostField.comments).document(commentID).updateData(data)
    }
    // MARK: DELETE FUNCTIONS
    func deleteComment(commentID: String, postID: String, handler: @escaping (_ success: Bool) -> ()) {
        REF_POSTS.document(postID).collection(DataBasePostField.comments).document(commentID).delete { error in
            if let error = error {
                print(error)
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
    func deletePost(postID: String) {
        REF_POSTS.document(postID).delete { error in
            if let error = error {
                print("Error deleting post: \(error)")
                return
            } else {
                ImageManager.instance.deleteImage(postID: postID) { success in
                    if success {
                        print("Successfully deleted post")
                    }
                    return
                }
            }
        }
    }
}
