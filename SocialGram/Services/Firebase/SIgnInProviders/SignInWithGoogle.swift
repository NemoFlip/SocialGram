//
//  SignInWithGoogle.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 09.02.2022.
//

import Foundation
import SwiftUI
import GoogleSignIn
import Firebase
class SignInWithGoogle: NSObject {
    static let instance = SignInWithGoogle()
    var onboardingView: OnboardingView!
    func checkStatus(){
        if (GIDSignIn.sharedInstance.currentUser != nil) {
            guard let user = GIDSignIn.sharedInstance.currentUser else {return}
            guard let idToken = user.authentication.idToken else { return  }
            let accessToken = user.authentication.accessToken
            
            guard let fullname = user.profile?.name else {return}
            guard let email = user.profile?.email else {return}
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            self.onboardingView.connectToFirebase(name: fullname, email: email, provider: "google", credential: credential)
        } else {
           self.onboardingView.showError.toggle()
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("error: \(error)")
                self.onboardingView.showError.toggle()
                return
            }
            self.checkStatus()
        }
    }
    func signIn(view: OnboardingView) {
        self.onboardingView = view
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        let signInConfig = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        GIDSignIn.sharedInstance.signIn(
            with: signInConfig,
            presenting: presentingViewController,
            callback: { user, error in
                if let error = error {
                    print(error)
                    self.onboardingView.showError.toggle()
                    return
                }
                self.checkStatus()
                
            }
        )
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}


