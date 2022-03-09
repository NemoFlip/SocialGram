//
//  SocialGramApp.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 22.01.2022.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
@main
struct SocialGramApp: App {
    let appearance: UITabBarAppearance = UITabBarAppearance()
    let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
    init() {
        FirebaseApp.configure()
        
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
