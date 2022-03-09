//
//  PostModel.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 23.01.2022.
//

import Foundation
import SwiftUI
struct PostModel: Identifiable, Hashable {
    var id = UUID()
    var postID: String // ID for the post in DB
    var userID: String // ID for the user in DB
    var username: String
    var caption: String?
    var dateCreated: Date
    var likeCount: Int
    var likedByUser: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension PostModel {
    func getDateCreated() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dateCreated, relativeTo: Date())
    }
}
