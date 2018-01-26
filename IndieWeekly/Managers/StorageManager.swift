//
//  StorageManager.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 26/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

class StorageManager {
    static var ref = Storage.storage().reference()
    
    static func upload(profilePic image:UIImage, forUser user:User, completionHandler: @escaping(Error?)->Void) {
        
        let imageRef = ref.child("profilePics").child("\(user.username).png")
        
        //TODO: Resize image to 300x300
        
        if let uploadData = UIImagePNGRepresentation(image) {
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/png"
            imageRef.putData(uploadData, metadata: uploadMetadata, completion: {
                (metadata, error) in
                if error != nil {
                    completionHandler(error)
                    return
                } else {
                    if let url = metadata?.downloadURL()?.absoluteString, let user = MainUser.shared {
                        DatabaseManager.update(profilePictureURL: url, forUser: user, completionHandler: {
                            (error) in
                            if error != nil {
                                completionHandler(error)
                                return
                            }
                            MainUser.shared?.profilePictureURL = metadata?.downloadURL()
                            completionHandler(nil)
                        })

                    }
                }
            })
        }
    }
    
}
