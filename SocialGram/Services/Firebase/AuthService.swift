//
//  AuthService.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 10.02.2022.
//

import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore
let DB_BASE = Firestore.firestore()

class AuthService {
    static let instance = AuthService()
    private var REF_USERS = DB_BASE.collection("users")
    func logInUsertoFirebase(credential: AuthCredential, handler: @escaping (_ providerID: String?, _ isError: Bool,_ isNewUser: Bool?, _ userID: String?) -> ()) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print(error)
                handler(nil, true, nil, nil)
                return
            }
            guard let providerID = result?.user.uid else {
                print("Error getting id")
                handler(nil, true, nil, nil)
                return
            }
            self.checkIfUserExistsInDatabase(providerID: providerID) { existingUserID in
                if let existingUserID = existingUserID {
                    handler(providerID, false, false, existingUserID)
                } else {
                    handler(providerID, false, true, nil)
                }
            }
        }
    }
    func loginUserToApp(userID: String, handler: @escaping (_ success: Bool) -> ()) {
        getUserInfo(forUserID: userID) { name, bio in
            if let name = name, let bio = bio {
                handler(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UserDefaults.standard.set(userID, forKey: CurrentUserDefaults.userID)
                    UserDefaults.standard.set(bio, forKey: CurrentUserDefaults.bio)
                    UserDefaults.standard.set(name, forKey: CurrentUserDefaults.displayName)
                }
                    
                
            } else {
                print("Error getting user info for app.")
                handler(false)
            }
        }
    }
    func logOutUser(handler: @escaping (_ success: Bool) -> ()) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            handler(false)
            return
        }
        handler(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
            defaultsDictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    func createNewUserInFirebase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, handler: @escaping (_ userID: String?) -> ()) {
        let document = REF_USERS.document()
        let userID = document.documentID
        ImageManager.instance.uploadProfileImage(userID: userID, image: profileImage)
        let documentData: [String: Any] =
        [DatabaseUserField.displayName: name,
         DatabaseUserField.email: email,
         DatabaseUserField.providerID: providerID,
         DatabaseUserField.provider: provider,
         DatabaseUserField.userID: userID,
         DatabaseUserField.bio: "",
         DatabaseUserField.dateCreated: FieldValue.serverTimestamp()]
        
        document.setData(documentData) { error in
            if let error = error {
                print("Error uploading data to user document. \(error)")
                handler(nil)
            } else {
                handler(userID)
            }
        }
    }
    
    private func checkIfUserExistsInDatabase(providerID: String, handler: @escaping (_ existingUserID: String?) -> ()) {
        REF_USERS.whereField(DatabaseUserField.providerID, isEqualTo: providerID).getDocuments { snapshot, error in
            if let snapshot = snapshot, snapshot.count > 0, let document = snapshot.documents.first {
                let existingUserID = document.documentID
                handler(existingUserID)
                return
            } else {
                handler(nil)
                return
            }
        }
    }
    
    
    
    func getUserInfo(forUserID userID: String, handler: @escaping (_ name: String?,_ bio: String?) -> ()) {
        REF_USERS.document(userID).getDocument { snapshot, error in
            if let document = snapshot, let name = document.get(DatabaseUserField.displayName) as? String, let bio = document.get(DatabaseUserField.bio) as? String {
                print("Success getting user info")
                handler(name, bio)
                return
            } else {
                print("Error: \(String(describing: error))")
                handler(nil, nil)
                return
            }
        }
    }
    
    func updateUserDisplayName(userID: String, displayName: String, handler: @escaping (_ success: Bool) -> ()) {
        let data: [String: Any] = [DatabaseUserField.displayName: displayName]
        REF_USERS.document(userID).updateData(data) { error in
            if let error = error {
                print("Error updating displayName: \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
                
            }
        }
    }
    func updateUserBio(userID: String, bio: String, handler: @escaping (_ success: Bool) -> ()) {
        let data: [String: Any] = [DatabaseUserField.bio: bio]
        REF_USERS.document(userID).updateData(data) { error in
            if let error = error {
                print("Error updating bio: \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
                
            }
        }
    }
    func deleteUserDocument(userID: String) {
        REF_USERS.document(userID).delete { error in
            if let error = error {
                print(error)
                return
            } else {
                ImageManager.instance.deleteImageByUserID(userID: userID)
                Auth.auth().currentUser?.delete(completion: { error in
                    
                })
                print("Delete account in firebase")
                return
            }
        }
    }
    
}
