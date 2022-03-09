//
//  SignInWithAppleButton.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 03.02.2022.
//

import Foundation
import SwiftUI
import AuthenticationServices
struct SignInWithAppleButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
}
