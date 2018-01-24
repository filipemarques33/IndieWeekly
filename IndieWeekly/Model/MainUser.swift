//
//  MainUser.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 11/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class MainUser: User {
    
    static var shared:MainUser? = nil
    
    // TODO: Add gameID type to String
    var library = [Game]()
    var wishlist = [Game]()
    var gamesLiked = [String]()
    var gamesDisliked = [String]()
    
    func add(game: Game, toList list: GameList, completion: @escaping ()->()) {
        DatabaseManager.add(gameID: game.id, toList: list.rawValue) { (error) in
            if error != nil  {
                print (error!.localizedDescription)
                return
            } else {
                switch list {
                case .library:
                    if let index = self.wishlist.index(where: {$0.id == game.id}) {
                        self.wishlist.remove(at: index)
                    }
                    self.library.append(game)
                    completion()
                case .wishlist:
                    if let index = self.library.index(where: {$0.id == game.id}) {
                        self.library.remove(at: index)
                    }
                    self.wishlist.append(game)
                    completion()
                }
            }
        }
    }
    
    func remove(game: Game, fromList list:GameList, completion: @escaping()->Void) {
        DatabaseManager.remove(gameID: game.id, toList: list.rawValue) { (error) in
            if error != nil  {
                print (error!.localizedDescription)
                return
            } else {
                switch list {
                case .library:
                    let index = self.library.index(where: {$0.id == game.id})
                    self.library.remove(at: index!)
                    completion()
                case .wishlist:
                    let index = self.wishlist.index(where: {$0.id == game.id})
                    self.wishlist.remove(at: index!)
                    completion()
                }
            }
        }
    }
}
