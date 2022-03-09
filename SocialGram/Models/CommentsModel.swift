//
//  CommentsModel.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 24.01.2022.
//

import Foundation
import SwiftUI

struct CommentsModel: Identifiable, Hashable {
    var id = UUID()
    var commentID: String
    var userID: String
    var username: String
    var content: String
    var dateCreated: Date
    var likedByUser: Bool
    var likeCount: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension CommentsModel {
    func getDateCreated() -> String {
        let formatter = DateComponentsFormatter()
        let interval = dateCreated.timeIntervalSince(Date())
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: abs(interval)) ?? ""
        
    }
}
