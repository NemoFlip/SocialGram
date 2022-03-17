//
//  PostImageView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 28.01.2022.
//

import SwiftUI

struct PostImageView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var showAlert = false
    @State var postUploadedSuccessfully = false
    @State var showMultipleImagePicker = false
    @State var multipleImages: [UIImage] = []
    @State private var captionText: String = ""
    @Binding var imageSelected: UIImage
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var displayName: String?
    var body: some View {
        VStack(spacing: 0) {
            xmarkButton
            ScrollView {
                imageWithEditor
                postPictureButton
            }
            .alert(isPresented: $showAlert) {
                if postUploadedSuccessfully {
                    return Alert(title: Text("Successfully uploaded post!"), dismissButton: .default(Text("OK"), action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }))
                } else {
                    return Alert(title: Text("Error uploading post"))
                }
            }
            
        }
    }
    private func postPicture() {
        guard let currentUserID = currentUserID else {
            return
        }
        guard let displayName = displayName else {
            return
        }
        if !multipleImages.contains(imageSelected) {
            multipleImages.insert(imageSelected, at: 0)
        }
        DataService.instance.uploadPost(images: multipleImages, caption: captionText, displayName: displayName, userID: currentUserID) { success in
            postUploadedSuccessfully = success
            showAlert.toggle()
        }
    }
}

struct PostImageView_Previews: PreviewProvider {
    @State static var image = UIImage(named: "dog1")!
    static var previews: some View {
        PostImageView(imageSelected: $image)
            .preferredColorScheme(.dark)
    }
}
extension PostImageView {
    private var xmarkButton: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .padding()
            }.accentColor(.primary)
            Spacer()
            plusButtton
        }
    }
    private var plusButtton: some View {
        Button {
            self.showMultipleImagePicker.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .padding()
        }
        .accentColor(.primary)
        .sheet(isPresented: $showMultipleImagePicker, onDismiss: {
            if !multipleImages.contains(imageSelected) {
                multipleImages.insert(imageSelected, at: 0)
            }
        }) {
            MultipleImagePicker(images: $multipleImages, dismissView: $showMultipleImagePicker)
        }.disabled(multipleImages.count >= 5)

    }
    private var imageWithEditor: some View {
        VStack {
            if multipleImages.isEmpty {
                DisplayImage(image: imageSelected)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(multipleImages, id: \.self) { image in
                            DisplayImage(image: image)
                        }
                    }
                }
            }
                TextEditor(text: $captionText)
                    .padding(5)
                    .background(colorScheme == .light ? Color.theme.beigeColor : .theme.purpleColor)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .font(.headline)
                    .cornerRadius(12)
                    .autocapitalization(.sentences)
        }
    }
    private var postPictureButton: some View {
        Button {
            postPicture()
        } label: {
            Text("Post picture")
                .font(.title3)
                
                .fontWeight(.bold)

                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.theme.purpleColor)
                .cornerRadius(12)
                .padding()
        }.accentColor(.theme.yellowColor)
    }
}


struct DisplayImage: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 100)
            .cornerRadius(12)
            .clipped()
            .padding(.leading, 5)
    }
}
