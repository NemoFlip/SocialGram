//
//  EnumsAndStructs.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 11.02.2022.
//

import Foundation

struct DatabaseUserField {
    static let displayName = "display_name"
    static let email = "email"
    static let providerID = "provider_id"
    static let provider = "provider"
    static let userID = "user_id"
    static let bio = "bio"
    static let dateCreated = "date_created"
}

struct CurrentUserDefaults {
    static let displayName = "display_name"
    static let userID = "user_id"
    static let bio = "bio"
}
struct DataBasePostField {
    static let displayName = "display_name"
    static let postID = "post_id"
    static let userID = "user_id"
    static let caption = "caption"
    static let dateCreated = "date_created"
    static let likeCount = "like_count"
    static let likedBy = "liked_by" // Array
    static let comments = "comments"
}
struct DataBaseCommentsField {
    static let displayName = "display_name"
    static let content = "content"
    static let commentID = "comment_id"
    static let dateCreated = "date_created"
    static let userID = "user_id"
    static let likedBy = "liked_by"
    static let likeCount = "like_count"
}
struct DataBaseReportField {
    static let content = "content"
    static let postID = "post_id"
    static let dateCreated = "date_created"
}
struct DataBaseFeedBackField {
    static let dateCreated = "date_created"
    static let content = "content"
    static let userID = "user_id"
}
enum SettingsEditTextOption {
    case displayName
    case bio
}
