//
//  UploadView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 27.01.2022.
//

import SwiftUI

struct UploadView: View {
    @State private var showImagePickerController = false
    @State var image: UIImage = UIImage(named: "logo")!
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.colorScheme) var colorScheme
    @State private var showPostImageView = false
    var body: some View {
        uploadSection
    }
    func segueToPostImageView() {
        if image != UIImage(named: "logo") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showPostImageView.toggle()
            }
        } else {
            return 
        }
        
    }
}

struct UploadView_Previews: PreviewProvider {
    @State static var image = UIImage(named: "dog1")!
    static var previews: some View {
        UploadView(image: image)
    }
}
extension UploadView {
    private var takePhotoSection: some View {
        Button {
            sourceType = .camera
            self.showImagePickerController.toggle()
        } label: {
            Text("Take photo".uppercased())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.theme.yellowColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.purpleColor)
    }
    private var loadPhotoSection: some View {
        Button {
            self.sourceType = .photoLibrary
            self.showImagePickerController.toggle()
        } label: {
            Text("Import photo".uppercased())
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.theme.purpleColor)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.yellowColor)
        
    }
    private var uploadSection: some View {
        ZStack {
            VStack(spacing: 0) {
                takePhotoSection
                
                loadPhotoSection

            }.sheet(isPresented: $showImagePickerController,onDismiss: segueToPostImageView, content: {
                ImagePicker(image: $image, sourceType: $sourceType).preferredColorScheme(colorScheme)
                    .accentColor(colorScheme == .light ? .theme.purpleColor : .teal)
            })
            Image("logo.transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(radius: 12)
                .fullScreenCover(isPresented: $showPostImageView, onDismiss: {
                    image = UIImage(named: "logo")!
                }) {
                        PostImageView(imageSelected: $image)
                        .preferredColorScheme(colorScheme)
                }
        }.ignoresSafeArea(.all, edges: .top)
    }
}
