//
//  PostView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 23.01.2022.
//

import SwiftUI

struct PostView: View {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.presentationMode) var presentationMode
    var showHeaderAndFooter: Bool
    @State var post: PostModel
    @State var showActionSheet: Bool = false
    @State var animateLike = false
    @State var animateFooterLike = false
    @State var addHeartAnimationToView: Bool
    @State var postImages = [UIImage(named: "logo.loading")!]
    @State var actionSheetType: PostActionSheetOption = .generalForPostUser
    @State var profileImage: UIImage = UIImage(named: "logo.loading")!
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    @State var showApproveAlert = false
    var handler: () -> ()
    enum PostActionSheetOption {
        case generalForCurrentUser
        case generalForPostUser
        case reporting
    }
    var body: some View {
        VStack(spacing: 0) {
            if showHeaderAndFooter {
                headerSection
            }
            
            imageSection
            if showHeaderAndFooter {
                footerSection
                if let caption = post.caption {
                    captionSection(caption: caption)
                }
            }
        }.onAppear {
            getImages()
        }
        .navigationBarBackButtonHidden(false)
    }
    func likePost() {
        guard let currentUserID = currentUserID else {
            return
        }
        let updatedPost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption ,dateCreated: post.dateCreated, likeCount: post.likeCount + 1, likedByUser: true)
        post = updatedPost
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
            animateLike = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                animateLike = false
            }
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
            animateFooterLike = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                animateFooterLike = false
            }
        }
        DataService.instance.likePost(postID: post.postID, currentUserID: currentUserID)
    }
    
    func unlikePost() {
        guard let currentUserID = currentUserID else {
            return
        }
        let updatedPost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption ,dateCreated: post.dateCreated, likeCount: post.likeCount - 1, likedByUser: false)
        post = updatedPost
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
            animateFooterLike = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
                animateFooterLike = false
            }
        }
        DataService.instance.unlikePost(postID: post.postID, currentUserID: currentUserID)
    }
    
    func getImages() {
        if showHeaderAndFooter {
            ImageManager.instance.downloadProfileImage(userID: post.userID) { image in
                if let image = image {
                    self.profileImage = image
                }
            }
        }
        print("GETTING IMAGES")
        ImageManager.instance.downloadMultiplePostImages(postID: post.postID) { uiImages in
            self.postImages = uiImages
        }  
    }
}


struct PostView_Previews: PreviewProvider {
    static var post = PostModel(postID: "", userID: "", username: "Krider", caption: "This is the caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
    static var previews: some View {
        PostView(showHeaderAndFooter: true, post: post, addHeartAnimationToView: true) {
            
        }
            .previewLayout(.sizeThatFits)
    }
}
extension PostView {
    private var headerSection: some View {
        HStack {
            NavigationLink {
                LazyView {
                    ProfileView(isMyProfile: false, posts: PostArrayObject(userID: post.userID), profileDisplayName: post.username, profileUserID: post.userID)
                }
            } label: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            Button {
                if currentUserID ?? "" == post.userID {
                    self.actionSheetType = .generalForCurrentUser
                } else {
                    self.actionSheetType = .generalForPostUser
                }
                showActionSheet.toggle()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline)
            }.accentColor(.primary).actionSheet(isPresented: $showActionSheet) {
                getActionSheet()
            }
        }.padding(6)
    }
    private var imageSection: some View {
        ZStack {
            TabView {
                ForEach(postImages, id: \.self) { num in
                    Image(uiImage: num)
                        .resizable()
                        .scaledToFill()
                        .onTapGesture(count: 2) {
                            if !post.likedByUser {
                                likePost()
                                AnalyticsService.instance.likePostDoubleTap()
                                
                            }
                        }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 300)
            if addHeartAnimationToView && post.likedByUser {
                LIkeAnimationView(animate: $animateLike)
            }
        }
    }
    private var footerSection: some View {
        
        HStack(spacing: 20) {
            Button {
                if post.likedByUser {
                    unlikePost()
                } else {
                    likePost()
                    AnalyticsService.instance.likePostHeartPressed()
                }
            } label: {
                Image(systemName: post.likedByUser ? "heart.fill" : "heart")
                    .scaleEffect(animateFooterLike ? 1.09 : 1)
            }.accentColor(post.likedByUser ? .red : .primary).alert(isPresented: $showApproveAlert) {
                return Alert(title: Text("Approve deleting"), message: Text("You definitely want to delete this post?"), primaryButton: .default(Text("Yes"), action: {
                    DataService.instance.deletePost(postID: post.postID)
                
                    handler()
                    
                }), secondaryButton: .cancel())
            }
            NavigationLink {
                CommentsView(post: post)
            } label: {
                Image(systemName: "message")
                    .foregroundColor(.primary)
            }
            Button {
                sharePost()
            } label: {
                Image(systemName: "paperplane")
            } .alert(isPresented: $showAlert, content: {
                return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }).accentColor(.primary)
            Spacer()
        }
        .font(.system(size: 21, weight: .medium, design: .rounded))
        .padding(6)
    }
    private func captionSection(caption: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if post.likeCount != 0 {
                Text("\(post.likeCount) \(post.likeCount == 1 ? "like" : "likes")")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.leading, 9)
            }
            HStack(alignment: .lastTextBaseline) {
                Text(post.username)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.leading,3)
                Text(caption)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                
                Spacer(minLength: 0)
                
            }.padding(6)
            
            Text(post.getDateCreated())
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 9)
                .padding(.bottom, 6)
                
        }
            
        
    }
    private func getActionSheet() -> ActionSheet {
        guard let currentUserID = currentUserID else {
            return ActionSheet(title: Text("Nothing"))
        }
        if currentUserID == post.userID {
            switch self.actionSheetType {
            case .generalForCurrentUser:
                return ActionSheet(title: Text("What would you like to do?"), buttons: [
                    .destructive(Text("Report"), action: {
                        self.actionSheetType = .reporting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showActionSheet.toggle()
                        }
                        
                    }),
                    .destructive(Text("Delete post"), action: {
                        self.showApproveAlert.toggle()
                    }),
                    .default(Text("Learn more..."), action: {
                        //Learn more
                    }),
                    .cancel()
                ])
            case .reporting:
                return ActionSheet(title: Text("Why are you reporting this post?"), message: nil, buttons: [
                    .destructive(Text("This is inappropriat"), action: {
                        reportPost(reason: "This is inappropriat")
                    }),
                    .destructive(Text("This is spam"), action: {
                        reportPost(reason: "This is spam")
                    }),
                    .destructive(Text("It made me uncomfortable"), action: {
                        reportPost(reason: "It made me uncomfortable")
                    }),
                    .cancel({
                        self.actionSheetType = .generalForCurrentUser
                    })
                    
                ])
            case .generalForPostUser:
                return ActionSheet(title: Text("sadd"))
            }
            
        } else {
            switch self.actionSheetType {
            case .generalForPostUser:
                return ActionSheet(title: Text("What would you like to do?"), buttons: [
                    .destructive(Text("Report"), action: {
                        self.actionSheetType = .reporting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showActionSheet.toggle()
                        }
                        
                    }),
                    .default(Text("Learn more..."), action: {
                        //Learn more
                    }),
                    .cancel()
                ])
            case .reporting:
                return ActionSheet(title: Text("Why are you reporting this post?"), message: nil, buttons: [
                    .destructive(Text("This is inappropriat"), action: {
                        reportPost(reason: "This is inappropriat")
                    }),
                    .destructive(Text("This is spam"), action: {
                        reportPost(reason: "This is spam")
                    }),
                    .destructive(Text("It made me uncomfortable"), action: {
                        reportPost(reason: "It made me uncomfortable")
                    }),
                    .cancel({
                        self.actionSheetType = .generalForPostUser
                    })
                    
                ])
                
            case .generalForCurrentUser:
                return ActionSheet(title: Text("sadd"))
            }
        }
        
    }
    func reportPost(reason: String) {
        print("Reporting post")
        DataService.instance.uploadReport(reason: reason, postID: post.postID) { success in
            if success {
                self.alertTitle = "Reported!"
                self.alertMessage = "Thanks for reporting this post. We will review it shortly and take the appropriate action!"
                self.showAlert.toggle()
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "There was an error uploading the report. Please restart the app and try again."
                self.showAlert.toggle()
            }
        }
    }
    func sharePost() {
        let message = "Check out this post on DogGram!"
        let image = postImages[0]
        let link = URL(string: "https://www.google.com")!
        let activityViewController = UIActivityViewController(activityItems: [message, image, link], applicationActivities: nil)
        let viewController = UIApplication.shared.windows.first?.rootViewController
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
