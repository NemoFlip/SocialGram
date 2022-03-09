//
//  SettingsEditTextView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 31.01.2022.
//

import SwiftUI

struct SettingsEditTextView: View {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State var submissionText: String = ""
    @State var title: String
    @State var settingsEditTextOption: SettingsEditTextOption
    @State var description: String
    @State var placeholder: String
    @Binding var profileText: String
    @State var showSuccessAlert = false
    let haptics = UINotificationFeedbackGenerator()
    var body: some View {
        VStack {
            HStack {
                Text(description)
                Spacer()
            }
            TextField(placeholder, text: $submissionText)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(colorScheme == .light ? Color.theme.beigeColor : .purple)
                .cornerRadius(12)
                .font(.headline)
                .autocapitalization(.sentences)
                
            Button {
                if textIsAppropriate() {
                    saveText()
                }
            } label: {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .light ? Color.theme.purpleColor : .theme.yellowColor)
                    .cornerRadius(12)
            }.accentColor(colorScheme == .light ? Color.theme.yellowColor : .theme.purpleColor)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .navigationTitle(title)
        .alert(isPresented: $showSuccessAlert) {
            return Alert(title: Text("Saved!"), message: nil, dismissButton: .default(Text("OK"), action: {
                dismissView()
            }))
        }
    }
    func dismissView() {
        self.haptics.notificationOccurred(.success)
        self.presentationMode.wrappedValue.dismiss()
    }
    private func textIsAppropriate() -> Bool {
        let words = submissionText.components(separatedBy: " ")
        if words.contains("fuck") {
            return false
        }
        if submissionText.count < 3 {
            return false
        }
        return true
    }
    func saveText() {
        guard let currentUserID = currentUserID else {
            return
        }
        switch settingsEditTextOption {
        case .displayName:
            self.profileText = submissionText
            
            UserDefaults.standard.set(submissionText, forKey: CurrentUserDefaults.displayName)
            
            DataService.instance.updateDisplayNameOnPosts(userID: currentUserID, displayName: submissionText)
            
            AuthService.instance.updateUserDisplayName(userID: currentUserID, displayName: submissionText) { success in
                if success {
                    showSuccessAlert.toggle()
                }
            }
        case .bio:
            self.profileText = submissionText
            
            UserDefaults.standard.set(submissionText, forKey: CurrentUserDefaults.bio)
            
            AuthService.instance.updateUserBio(userID: currentUserID, bio: submissionText) { success in
                if success {
                    self.showSuccessAlert.toggle()
                }
            }
        }
    }
}

struct SettingsEditTextView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsEditTextView(submissionText: "Krider", title: "Test", settingsEditTextOption: .displayName, description: "THis is the description", placeholder: "Placeholder", profileText: .constant("Kriderok"))
        }
    }
}
