//
//  MultipleImagePicker.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 16.03.2022.
//

import Foundation
import SwiftUI
import PhotosUI

struct MultipleImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var dismissView: Bool
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: MultipleImagePicker
        init(parent: MultipleImagePicker) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismissView.toggle()
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { resultImage, error in
                        guard let resultImage = resultImage else {
                            print("ERROR: \(String(describing: error))")
                            return
                        }
                        self.parent.images.append(resultImage as! UIImage)
                        
                    }
                } else {
                    print("Can't load images")
                    return
                }
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
}
