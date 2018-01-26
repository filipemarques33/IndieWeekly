//
//  User.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 11/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class User {
    
    //var id: String
    var username:String
    var email:String
    var profilePictureURL:URL?
    
    init(username: String, email: String, profilePictureURL:URL? = nil){
        //self.id = id
        self.username = username
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
    
}
