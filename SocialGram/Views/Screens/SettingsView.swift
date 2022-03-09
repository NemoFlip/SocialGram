//
//  SettingsView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 30.01.2022.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var showError = false
    @Binding var userDisplayName: String
    @Binding var userBio: String
    @Binding var profilePicture: UIImage
    let haptics = UINotificationFeedbackGenerator()
    var body: some View {
        NavigationView {
            ScrollView {
                socialGramSection

                profileSettingsSection
                
                applitcationSection
                
                copyrightInfoSection

            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                    }.accentColor(.primary)

                }
            }
        }.accentColor(colorScheme == .light ? .theme.purpleColor : .teal)
    }
    func openCustomURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func signOut() {
        AuthService.instance.logOutUser { success in
            if success {
                print("Successfully logged out")
                haptics.notificationOccurred(.success)
                self.presentationMode.wrappedValue.dismiss()
            } else {
                print("Error logging out")
                haptics.notificationOccurred(.error)
                self.showError.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userDisplayName: .constant("Krider"), userBio: .constant("Krider"), profilePicture: .constant(UIImage(named: "dog1")!))
            .preferredColorScheme(.dark)
    }
}
extension SettingsView {
    private var socialGramSection: some View {
        GroupBox {
            HStack(spacing: 10) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(width: 80, height: 80)
                    
                Text("SocialGram is the best app for sharing emotions with your friends. We are happy to have you!")
                    .font(.footnote)
            }
        } label: {
            SettingsLabelView(labelText: "SocialGram", imageName: "dot.radiowaves.left.and.right")
        }.padding()
    }
    private var profileSettingsSection: some View {
        GroupBox {
            
            NavigationLink {
                SettingsEditTextView(submissionText: userDisplayName, title: "Display name", settingsEditTextOption: .displayName, description: "You can change your display name here. This will be seen by other users on your profile and on your posts!", placeholder: "Display name...", profileText: $userDisplayName)
            } label: {
                SettingsRowView(leftIcon: "pencil", text: "Display Name", color: .theme.purpleColor)
            }
            
            NavigationLink {
                SettingsEditTextView(submissionText: userBio, title: "Profile Bio", settingsEditTextOption: .bio, description: "Your bio is a great place to know a little bit more about you!", placeholder: "Your bio here...", profileText: $userBio)
            } label: {
                SettingsRowView(leftIcon: "text.quote", text: "Bio", color: .theme.purpleColor)
            }

            NavigationLink {
                SettingsEditImageView(title: "Profile Picture", description: "There you can select or change an image. It will be shown on your profile and on your posts!", selectedImage: profilePicture, profileImage: $profilePicture)
            } label: {
                SettingsRowView(leftIcon: "photo", text: "Profile Picture", color: .theme.purpleColor)
            }
            NavigationLink {
                SettingsFeedBackView(description: "There you can submit your suggestions to improve our app!", placeholder: "Your suggestion here...", title: "Feedback")
            } label: {
                SettingsRowView(leftIcon: "message.fill", text: "FeedBack", color: .theme.purpleColor)
            }

            Button {
                signOut()
            } label: {
                SettingsRowView(leftIcon: "figure.walk", text: "Sign out", color: .theme.purpleColor)
            }.alert(isPresented: $showError) {
                return Alert(title: Text("Error logging out the user"))
            }
        } label: {
            SettingsLabelView(labelText: "Profile", imageName: "person.fill")
        }.padding()
    }
    private var applitcationSection: some View {
        GroupBox {
            Button {
                openCustomURL(urlString: "https://www.google.com")
            } label: {
                SettingsRowView(leftIcon: "folder.fill", text: "Privacy Policy", color: .theme.yellowColor)
            }

            Button {
                openCustomURL(urlString: "https://www.yahoo.com")
            } label: {
                SettingsRowView(leftIcon: "folder.fill", text: "Terms & Conditions", color: .theme.yellowColor)
            }
            
            Button {
                openCustomURL(urlString: "https://www.bingo.com")
            } label: {
                SettingsRowView(leftIcon: "globe", text: "SocialGram's Website", color: .theme.yellowColor)
            }

        } label: {
            SettingsLabelView(labelText: "Application", imageName: "apps.iphone")
        }.padding()
    }
    private var copyrightInfoSection: some View {
        GroupBox(content: {
            Text("SocialGram was made with love. \n All rights Reserved \n Social Apps inc. \n Copyright 2022")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }).padding().padding(.bottom, 80)
    }
}
