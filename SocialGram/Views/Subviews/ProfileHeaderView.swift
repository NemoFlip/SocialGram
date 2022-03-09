//
//  ProfileHeaderView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 29.01.2022.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var profileDisplayName: String
    @Binding var profileImage: UIImage
    @ObservedObject var postArray: PostArrayObject
    @Binding var profileBio: String
    var body: some View {
        VStack(alignment: .leading,spacing: 10) {
            HStack(spacing: 20) {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                Spacer()
                VStack(spacing: 5) {
                    Text(postArray.postCount)
                        .font(.title2)
                        .fontWeight(.bold)
                    Capsule()
                        .fill(.gray)
                        .frame(width: 20, height: 3)
                    Text("Posts")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                }.padding(.trailing)
                VStack(spacing: 5) {
                    Text(postArray.likeCount)
                        .font(.title2)
                        .fontWeight(.bold)
                    Capsule()
                        .fill(.gray)
                        .frame(width: 20, height: 3)
                    Text("Likes")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                }
                Spacer()
            }
            Text(profileDisplayName)
                .font(.title2)
                .fontWeight(.bold)
            if !profileBio.isEmpty {
                Text(profileBio)
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    @State static var profDisName = "Krider"
    static var previews: some View {
        ProfileHeaderView(profileDisplayName: $profDisName, profileImage: .constant(UIImage(named: "dog1")!), postArray: PostArrayObject(shuffled: false), profileBio: .constant(""))
            .previewLayout(.sizeThatFits)
    }
}
