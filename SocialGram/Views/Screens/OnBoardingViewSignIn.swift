//
//  OnBoardingViewSignIn.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 04.02.2022.
//

import SwiftUI

struct OnBoardingViewSignIn: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var displayName: String
    @Binding var email: String
    @Binding var providerID: String
    @Binding var provider: String
    @State private var showImagePicker = false
    @State private var image = UIImage(named: "dog1")!
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showError = false
    var body: some View {
        VStack(spacing: 20) {
            
            Text("What's your name?")
                .font(.title)
                
                .fontWeight(.bold)
                .foregroundColor(.theme.yellowColor)
                .autocapitalization(.none)
            TextField("Add your name here...", text: $displayName)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.theme.beigeColor)
                .cornerRadius(12)
                .font(.headline)
                .autocapitalization(.sentences)
                .padding(.horizontal)
            
            if image != UIImage(named: "dog1") && !displayName.isEmpty {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(75)
                
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Finish registration!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.yellowColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }.accentColor(.theme.purpleColor)
            }
            
            Button {
                showImagePicker.toggle()
            } label: {
                Text("Finish: Add profile picture")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.yellowColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }.opacity(!displayName.isEmpty ? 1 : 0)
                .accentColor(.theme.purpleColor)
                .animation(.easeInOut(duration: 0.3))
            
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.purpleColor)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showImagePicker, onDismiss: {
            createAccount()
        }) {
            ImagePicker(image: $image, sourceType: $sourceType)
        }.alert(isPresented: $showError) {
            return Alert(title: Text("Error creating account😞"))
        }
    }
    func createAccount() {
        AuthService.instance.createNewUserInFirebase(name: displayName, email: email, providerID: providerID, provider: provider, profileImage: image) { userID in
            if let userID = userID {
                //SUCCESS
                print("Successfully created account in dataBase")
                AuthService.instance.loginUserToApp(userID: userID) { success in
                    if success {
                        print("User logged in")
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error logging in")
                        self.showError.toggle()
                    }
                }
            } else {
                print("Error creating user id Database")
                self.showError.toggle()
            }
        }
    }
}

struct OnBoardingViewSignIn_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingViewSignIn(displayName: .constant("Krider"), email: .constant("email"), providerID: .constant("test"), provider: .constant("test"))
    }
}
