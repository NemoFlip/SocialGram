//
//  AnalyticsService.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 01.03.2022.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    static let instance = AnalyticsService()
    func likePostDoubleTap() {
        Analytics.logEvent("like_double_tap", parameters: nil)
    }
    
    func likePostHeartPressed() {
        Analytics.logEvent("like_heart_pressed", parameters: nil)
    }
}
