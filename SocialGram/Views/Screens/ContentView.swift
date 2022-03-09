//
//  ContentView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 22.01.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var displayName: String?
    @StateObject var feedPosts = PostArrayObject(shuffled: false)
    @StateObject var browsePosts = PostArrayObject(shuffled: true)
    var body: some View {
        if let currentUserID = currentUserID {
            TabView {
                NavigationView {
                    FeedView(posts: feedPosts, title: "Socialgram")
                        .navigationBarHidden(true)
                }
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                NavigationView {
                    BrowseView(posts: browsePosts)
                }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                    }
                UploadView()
                    .tabItem {
                        Image(systemName: "plus.square")
                    }
                ZStack {
                    if let userID = currentUserID, let displayName = displayName {
                        NavigationView {
                            ProfileView(isMyProfile: true, posts: PostArrayObject(userID: userID), profileDisplayName: displayName, profileUserID: userID)
                        }
                    }
                }
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                    }
            }
            .accentColor(colorScheme == .light ? Color.theme.purpleColor : .teal)
        } else {
            SignUpView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.portrait)
    }
}
