//
//  SettingsFeedBackView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 02.03.2022.
//

import SwiftUI

struct SettingsFeedBackView: View {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State var submissionText: String = ""
    @State var description: String
    @State var placeholder: String
    @State var title: String
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
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
                    save()
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
        .alert(isPresented: $showAlert) {
            return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                dismissView()
            }))
        }
    }
    func dismissView() {
        self.haptics.notificationOccurred(.success)
        self.presentationMode.wrappedValue.dismiss()
    }
    func save() {
        guard let currentUserID = currentUserID else {
            return
        }

        // Create new collection in DB and upload feedback
        DataService.instance.uploadFeedBack(content: submissionText, userID: currentUserID) { success in
            if success {
                self.alertTitle = "Success!"
                self.alertMessage = "Thank you for feedback! We will certainly take note of the comments."
                self.showAlert.toggle()
            } else {
                self.alertTitle = "Failed!"
                self.alertMessage = ""
                self.showAlert.toggle()
            }
        }
        
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
}

struct SettingsFeedBackView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFeedBackView(description: "", placeholder: "", title: "")
    }
}
