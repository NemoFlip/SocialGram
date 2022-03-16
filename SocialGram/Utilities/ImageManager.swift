//
//  ImageManager.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 12.02.2022.
//

import Foundation
import FirebaseStorage
import SwiftUI
let imageCache = NSCache<AnyObject, UIImage>()
class ImageManager {
    static let instance = ImageManager()
    private var REF_STOR = Storage.storage()
    
    func uploadProfileImage(userID: String, image: UIImage) {
        let path = getProfileImagePath(userID: userID)
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            self?.uploadImage(path: path, image: image) { _ in }
        }
    }
    func uploadMultiplePostImages(postID: String, images: [UIImage], handler: @escaping (_ success: Bool) -> ()) {
        for number in 0..<images.count {
            let path = getPostImagesPath(postID: postID, num: number + 1)
            DispatchQueue.global(qos: .userInitiated).sync {
                self.uploadImage(path: path, image: images[number]) { success in
                    if !success {
                        DispatchQueue.main.async {
                            handler(false)
                        }
                        return
                    }
                }
                print("Uploaded image: \(number)")
            }
            print("Uploaded image2: \(number)")
            
        }
        handler(true)
    }
    
    func downloadProfileImage(userID: String, handler: @escaping (_ image: UIImage?) -> ()) {
        let path = getProfileImagePath(userID: userID)
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            self?.downloadImage(path: path) { image in
                DispatchQueue.main.async {
                    handler(image)
                }
            }
        }
    }
    func downloadMultiplePostImages(postID: String, handler: @escaping (_ uiImages: [UIImage]) -> ()) {
        var resultArray = [UIImage]()
        let myGroup = DispatchGroup()
        print("Downloading")
        for i in 1...5 {
            myGroup.enter()
            let path = getPostImagesPath(postID: postID, num: i)
            DispatchQueue.global(qos: .userInitiated).async {
                if let cachedImage = imageCache.object(forKey: path) {
                    resultArray.append(cachedImage)
                    myGroup.leave()
                } else {
                    path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, error in
                        if let data = returnedImageData, let image = UIImage(data: data) {
                            imageCache.setObject(image, forKey: path)
                            resultArray.append(image)
                        }
                        myGroup.leave()
                    }
                }
            }
            
        }
        
        myGroup.notify(queue: .main) {
            print("ARRAY")
            print(resultArray)
            handler(resultArray)
        }
    }
    private func getProfileImagePath(userID: String) -> StorageReference {
        let userPath = "users/\(userID)/profile"
        let storagePath = REF_STOR.reference(withPath: userPath)
        return storagePath
    }
//    private func getPostImagePath(postID: String) -> StorageReference {
//        let postPath = "posts/\(postID)/1"
//        let storagePath = REF_STOR.reference(withPath: postPath)
//        return storagePath
//    }
    private func getPostImagesPath(postID: String, num: Int) -> StorageReference {
        let postPath = "posts/\(postID)/\(num)"
        let storagePath = REF_STOR.reference(withPath: postPath)
        return storagePath
    }
    private func uploadImage(path: StorageReference, image: UIImage, handler: @escaping (_ success: Bool) -> ()) {
        var compression: CGFloat = 1.0
        let maxFileSize: Int = 240 * 240
        let maxCompression: CGFloat = 0.05
        guard var originalData = image.jpegData(compressionQuality: compression) else {
            print("Error gettting data from image")
            handler(false)
            return
        }
        while (originalData.count > maxFileSize) && (compression > maxCompression) {
            compression -= 0.05
            if let compressionData = image.jpegData(compressionQuality: compression) {
                originalData = compressionData
            }
        }
        guard let finalData = image.jpegData(compressionQuality: compression) else {
            print("Error gettting data from image")
            handler(false)
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        path.putData(finalData, metadata: metaData) { _, error in
            if let error = error {
                print("Error uploading image. \(error)")
                handler(false)
                return
            } else {
                print("Success")
                handler(true)
                return
            }
        }
    }
    private func downloadImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> ()) {
        if let cachedImage = imageCache.object(forKey: path) {
            handler(cachedImage)
            return
        } else {
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, error in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: path)
                    handler(image)
                    return
                } else {
//                    print("Error getting image")
                    handler(nil)
                    return
                }
            }
        }
    }
    func deleteImage(postID: String, handler: @escaping (_ success: Bool) -> ()) {
        let ref = REF_STOR.reference().child("posts/\(postID)/")
        ref.listAll { list, error in
            if let error = error {
                print("Error: \(error)")
                handler(false)
                return
            }
            else {
                list.items.forEach { refer in
                    refer.delete { error2 in
                        if let error2 = error2 {
                            print("Error: \(error2)")
                            handler(false)
                            return
                        }
                    }
                }
            }
            
        }
        handler(true)
    }
    func deleteImageByUserID(userID: String) {
        let path = getProfileImagePath(userID: userID)
        path.delete { error in
            if let error = error {
                print("Error deleting image: \(error)")
                return
            } else {
                print("Successfully deleted image")
                return
            }
        }
    }
}
