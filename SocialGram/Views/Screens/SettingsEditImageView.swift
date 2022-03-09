//
//  SettingsEditImageView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 03.02.2022.
//

import SwiftUI

struct SettingsEditImageView: View {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.presentationMode) var presentationMode
    @State var title: String
    @State var description: String
    @State var selectedImage: UIImage
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var profileImage: UIImage
    @State var showAlert: Bool = false
    let haptics = UINotificationFeedbackGenerator()
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(description)
                Spacer()
            }
            
            photoImagePickerSelection
            
            saveButtonSection
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .navigationTitle(title)
        .alert(isPresented: $showAlert) {
            return Alert(title: Text("Success!"), dismissButton: .default(Text("OK"), action: {
                self.haptics.notificationOccurred(.success)
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    func saveImage() {
        guard let currentUserID = currentUserID else {
            return
        }
        self.profileImage = selectedImage
        
        ImageManager.instance.uploadProfileImage(userID: currentUserID, image: selectedImage)
        self.showAlert.toggle()
    }
}

struct SettingsEditImageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsEditImageView(title: "Title", description: "Description", selectedImage: UIImage(named: "dog2")!, profileImage: .constant(UIImage(named: "dog2")!))
        }
    }
}

extension SettingsEditImageView {
    private var photoImagePickerSelection: some View {
        Button {
            self.showImagePicker.toggle()
        } label: {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipped()
                .cornerRadius(12)
        }.sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: $sourceType)
                .ignoresSafeArea()
        }
    }
    private var saveButtonSection: some View {
        Button {
            saveImage()
        } label: {
            Text("Save")
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.theme.purpleColor)
                .cornerRadius(12)
        }.accentColor(.theme.yellowColor)

    }
}
