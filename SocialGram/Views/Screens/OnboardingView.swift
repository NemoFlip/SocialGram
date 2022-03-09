//
//  OnboardingView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 03.02.2022.
//

import SwiftUI
import Firebase
import FirebaseAuth
struct OnboardingView: View {
    @State var displayName: String = ""
    @State var email: String = ""
    @State var providerID: String = ""
    @State var provider: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State var showOnBoardingSignIn = false
    @State var showError = false
    var body: some View {
        VStack(spacing: 10) {
            Image("logo.transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(radius: 12)
            Text("Welcome to DogGram")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.theme.purpleColor)
            Text("SocialGram is the best app for sharing emotions with your friends. We are happy to have you!")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.theme.purpleColor)
                .padding()
            Button {
                showOnBoardingSignIn.toggle()
            } label: {
                SignInWithAppleButton()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
            Button {
                SignInWithGoogle.instance.signIn(view: self)
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.init(red: 222 / 255, green: 85 / 255, blue: 70 / 255))
                .cornerRadius(4)
                .font(.system(size: 18, weight: .medium, design: .rounded))
            }.accentColor(.white)
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Continue as guest")
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding()
            }.accentColor(.black)


        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.beigeColor)
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showOnBoardingSignIn, onDismiss: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            OnBoardingViewSignIn(displayName: $displayName, email: $email, providerID: $providerID, provider: $provider)
        }.alert(isPresented: $showError) {
            return Alert(title: Text("Error signing in 😞"))
        }
    }
    func connectToFirebase(name: String, email: String, provider: String, credential: AuthCredential) {
        AuthService.instance.logInUsertoFirebase(credential: credential) { providerID, isError,isNewUser, existingUserID  in
            if let isNewUser = isNewUser {
                if isNewUser {
                    if let providerID = providerID, !isError {
                        self.displayName = name
                        self.email = email
                        self.providerID = providerID
                        self.provider = provider
                        self.showOnBoardingSignIn.toggle()
                    } else {
                        print("Error getting info")
                        self.showError.toggle()
                    }
                } else {
                    if let existingUserID = existingUserID {
                        AuthService.instance.loginUserToApp(userID: existingUserID) { success in
                            if success {
                                print("Successfull logged in ")
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                print("Error logging existing user")
                                self.showError.toggle()
                            }
                        }
                    } else {
                        print("Error getting info")
                    }
                }
            } else {
                print("Error getting info")
                self.showError.toggle()
            }
            
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
