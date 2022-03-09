//
//  SignUpView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 03.02.2022.
//

import SwiftUI

struct SignUpView: View {
    @State var showOnboarding = false
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("logo.transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text("You're not signed in! ☹️")
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.theme.purpleColor)
            Text("Click the button below to create an account")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.theme.purpleColor)
            Button {
                showOnboarding.toggle()
            } label: {
                Text("Sign in / Sign up".uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.theme.purpleColor)
                    .cornerRadius(12)
                    .shadow(radius: 12)
                   
                
            }.accentColor(.theme.yellowColor)
            Spacer()
            Spacer()

        }.padding(40)
            .background(Color.theme.beigeColor)
            .edgesIgnoringSafeArea(.top)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
