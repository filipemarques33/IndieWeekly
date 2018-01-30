//
//  Game.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 15/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

struct Store {
    var name:String
    var website:URL?
    var image:UIImage?
}

enum GameList:String {
    case library = "library"
    case wishlist = "wishlist"
}

struct Comment {
    var id:String
    var creator:User
    var dateCreated:Date
    var content:String
}

class Game {
    var id:String
    var name:String
    var developer:String
    var devWebsite:URL
    var screenshotURL:URL?
    var posterURL:URL?
    var genre:String
    var platforms:String
    var releaseDate:Date
    var synopsis:String
    var editorsCritic:String
    var stores:[Store] = []
    var comments:[Comment] = []

    init(id: String, name:String, developer:String, devWebsite:URL, posterURL:URL?, screenshotURL:URL?, genre:String, platforms:String, releaseDate:Date, synopsis:String, editorsCritic:String, stores:[Store]) {
        self.id = id
        self.name = name
        self.developer = developer
        self.devWebsite = devWebsite
        self.posterURL = posterURL
        self.screenshotURL = screenshotURL
        self.genre = genre
        self.platforms = platforms
        self.releaseDate = releaseDate
        self.synopsis = synopsis
        self.editorsCritic = editorsCritic
        self.stores = stores
    }


}

