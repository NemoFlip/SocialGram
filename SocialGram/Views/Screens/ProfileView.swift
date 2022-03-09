//
//  ProfileView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 29.01.2022.
//

import SwiftUI
import Firebase
struct ProfileView: View {
    var isMyProfile: Bool
    @ObservedObject var posts: PostArrayObject
    @Environment(\.colorScheme) var colorScheme
    @State var profileDisplayName: String
    var profileUserID: String
    @State var showSettings = false
    @State var profileBio: String = ""
    @State var profileImage = UIImage(named: "logo.loading")!
    var body: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: "profileViewRefresh") {
                posts.getPostsForUser(userID: profileUserID)
            }
            ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $profileImage, postArray: posts, profileBio: $profileBio)
            Divider()
            ImageGridView(posts: posts)
        }.coordinateSpace(name: "profileViewRefresh")
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3")
                    
                }.accentColor(colorScheme == .light ? .theme.purpleColor : .teal)
                    .opacity(isMyProfile ? 1 : 0)
            }
        }
        .onAppear(perform: {
            getProfileImage()
            getAdditionalProfileInfo()
        })
        .sheet(isPresented: $showSettings) {
            SettingsView(userDisplayName: $profileDisplayName, userBio: $profileBio, profilePicture: $profileImage)
                .preferredColorScheme(colorScheme)
        }
    }
    func getProfileImage() {
        ImageManager.instance.downloadProfileImage(userID: profileUserID) { image in
            if let image = image {
                self.profileImage = image
            }
            
        }
    }
    func getAdditionalProfileInfo() {
        AuthService.instance.getUserInfo(forUserID: profileUserID) { name, bio in
            if let name = name {
                self.profileDisplayName = name
            }
            if let bio = bio {
                self.profileBio = bio
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(isMyProfile: true, posts: PostArrayObject(userID: ""), profileDisplayName: "Krider", profileUserID: "")
        }
    }
}
