//
//  DatabaseManager.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 10/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import FirebaseDatabase
import UIKit

class DatabaseManager {
    
    static var ref:DatabaseReference = Database.database().reference()
    
    static func add(user: MainUser, completionHandler: @escaping(Error?) -> Void) {
        let userRef = ref.child("users").child(user.username)
    
        let userDict: [String : AnyObject] = [
            "username": user.username as AnyObject,
            "email": user.email as AnyObject,
            "profilePictureURL": "" as AnyObject,
            "gameList": "" as AnyObject,
            "gamesRated": "" as AnyObject
        ]
    
        userRef.setValue(userDict) {
            (error, _) in
            
            guard (error == nil) else {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
    
    static func fetchUser(byUsername username: String, completionHandler: @escaping (MainUser?) -> Void) {
        
        let userRef = ref.child("users/\(username)")
        
        userRef.observeSingleEvent(of: .value) {
            (userSnapshot) in
            
            //Getting user's information dictionary
            guard var userDictionary = userSnapshot.value as? [String: AnyObject] else {
                print("User ID fetched returned a nil snapshot from DB.")
                completionHandler(nil)
                return
            }
            
            userDictionary["id"] = username as AnyObject
            
            //Fetching user's basic information
            
            guard let user = fetchUserBasicInfo(userDictionary: userDictionary) else {
                print("Error on fetching user (\(username))'s basic profile information.")
                completionHandler(nil)
                return
            }
            
            let mainUser = MainUser(username: user.username, email: user.email, profilePictureURL: user.profilePictureURL)
            
            fetchMainUserDetailedInfo(user: mainUser, userDictionary: userDictionary) {
                (success) in
                
                guard (success == true) else {
                    print("Error on fetching user's detailed profile information.")
                    completionHandler(nil)
                    return
                }
                
                completionHandler(mainUser)
            }
        }
    }
    
    static func fetchUser(byUsername username: String, completionHandler: @escaping (User?) -> Void) {
        
        let userRef = ref.child("users/\(username)")
        
        userRef.observeSingleEvent(of: .value) {
            (userSnapshot) in
            
            //Getting user's information dictionary
            guard var userDictionary = userSnapshot.value as? [String: AnyObject] else {
                print("User ID fetched returned a nil snapshot from DB.")
                completionHandler(nil)
                return
            }
            
            userDictionary["id"] = username as AnyObject
            
            //Fetching user's basic information
            
            if let user = fetchUserBasicInfo(userDictionary: userDictionary) {
                completionHandler(user)
            } else {
                print("Error on fetching user (\(username))'s basic profile information.")
                completionHandler(nil)
                return
            }
        }
    }
    
    static func fetchUserBasicInfo(userDictionary: [String : AnyObject]) -> User? {
        
        guard let userUsername = userDictionary["username"] as? String else {
            print("Fetching user's name from DB returns nil.")
            return nil
        }
        
        guard let userEmail = userDictionary["email"] as? String else {
            print("Fetching user's email from DB returns nil.")
            return nil
        }
        
        var userProfilePictureURL:URL?
        if let imageURL = userDictionary["profilePictureURL"] as? String {
            userProfilePictureURL = URL(string: imageURL)
        } else {
            print("Fetching game's poster from DB returns nil.")
            userProfilePictureURL = nil
        }
        
        let user = User(username: userUsername, email: userEmail, profilePictureURL:userProfilePictureURL)
        print("User (\(user.username)) fetched successfully.")

        return user
    }
    
    static func fetchMainUser(byEmail email: String, completionHandler: @escaping (MainUser?) -> Void) {
        
        let usersRef = ref.child("users")
        
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) {
            (userSnapshot) in
            
            if let usersSnapList = userSnapshot.children.allObjects as? [DataSnapshot] {
                
                if (usersSnapList.count == 0) {
                    print("No user with this name found on DB.")
                    completionHandler(nil)
                    return
                } else if (usersSnapList.count != 1) {
                    print("Found more than one user with this name on DB.")
                    completionHandler(nil)
                    return
                }
                
                let userSnap = usersSnapList[0]
                
                guard var userDictionary = userSnap.value as? [String: AnyObject] else {
                    print("User ID fetched returned a nil snapshot from DB.")
                    completionHandler(nil)
                    return
                }
                
                userDictionary["id"] = userSnap.key as AnyObject
                
                guard let user = fetchUserBasicInfo(userDictionary: userDictionary) else {
                    print("Error on fetching user (\(email))'s basic profile information.")
                    completionHandler(nil)
                    return
                }
                
                let mainUser = MainUser(username: user.username, email: user.email, profilePictureURL: user.profilePictureURL)
                
                fetchMainUserDetailedInfo(user: mainUser, userDictionary: userDictionary) {
                    (success) in
                    
                    guard (success == true) else {
                        print("Error on fetching user's detailed profile information.")
                        completionHandler(nil)
                        return
                    }
                    
                    completionHandler(mainUser)
                }
            }
        }
    }
    
    static func fetchMainUserDetailedInfo(user: MainUser, userDictionary: [String : AnyObject], completionHandler: @escaping (Bool) -> Void) {
        
        //Reading user's protectors
        
        let gamesDict = userDictionary["gameList"] as? [String : AnyObject] ?? [:]
        
        var userLibrary: [Game] = []
        var userWishlist: [Game] = []
        var blacklist = [String]()
        
        if let blacklistDict = userDictionary["blacklist"] as? [String:AnyObject] {
            for username in blacklistDict {
                blacklist.append(username.key)
            }
        } else {
            print("Fetching game's blacklist from DB returns nil.")
        }
        
        let dispatchGroup = DispatchGroup()
        
        for gameDict in gamesDict {
            dispatchGroup.enter()
            let gameID = gameDict.key
            
            fetchGame(byID: gameID) {
                (game) in
                
                guard let game = game else {
                    print("Error on fetching game with id: \(gameID).")
                    completionHandler(false)
                    return
                }
                
                if gameDict.value as! String == "library" {
                    userLibrary.append(game)
                } else {
                    userWishlist.append(game)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            
            user.blacklistedUsers = blacklist
            user.library = userLibrary
            user.wishlist = userWishlist
            completionHandler(true)
        }
    }
    
    static func fetchGame(byID gameID: String, completionHandler: @escaping (Game?) -> Void) {
        
        let gameRef = ref.child("games/\(gameID)")
        
        gameRef.observeSingleEvent(of: .value) {
            (gameSnapshot) in
            
            //Getting user's information dictionary
            guard var gameDictionary = gameSnapshot.value as? [String: AnyObject] else {
                print("Game ID fetched returned a nil snapshot from DB.")
                completionHandler(nil)
                return
            }
            
            gameDictionary["id"] = gameID as AnyObject
            
            //Fetching user's basic information
            
            guard let game = fetchGameBasicInfo(gameDictionary: gameDictionary) else {
                print("Error on fetching game (\(gameID))'s basic profile information.")
                completionHandler(nil)
                return
            }
            
            completionHandler(game)
        }
    }
    
    static func fetchGameOfTheWeek(completionHandler: @escaping (Game?) -> Void) {
        
        let gameRef = ref.child("gameOfTheWeek")
        
        gameRef.observeSingleEvent(of: .value) {
            (gameSnapshot) in
            guard let gameID = gameSnapshot.value as? String else {
                print("Game reference fetched returned a nil snapshot from DB.")
                completionHandler(nil)
                return
            }
            
            fetchGame(byID: gameID, completionHandler: {
                (fetchedGame) in
                completionHandler(fetchedGame)
            })
        }
    }
    
    static func fetchGameBasicInfo(gameDictionary: [String : AnyObject]) -> Game? {
        
        guard let gameID = gameDictionary["id"] as? String else {
            print("Fetching game's ID from DB returns nil.")
            return nil
        }
        
        guard let gameName = gameDictionary["name"] as? String else {
            print("Fetching game's name from DB returns nil.")
            return nil
        }
        
        guard let gameDev = gameDictionary["developer"] as? String else {
            print("Fetching game's developer from DB returns nil.")
            return nil
        }
        
        var gameDevWebsite:URL
        if let devWebsite = gameDictionary["devWebsite"] as? String {
            gameDevWebsite = URL(string: devWebsite)!
        } else {
            print("Fetching game's devWebsite from DB returns nil.")
            return nil
        }
        
        var gamePosterURL:URL?
        if let posterURL = gameDictionary["posterURL"] as? String {
            gamePosterURL = URL(string: posterURL)!
        } else {
            print("Fetching game's poster from DB returns nil.")
            gamePosterURL = nil
        }
        
        var gameScreenshotURL:URL?
        if let screenshotURL = gameDictionary["screenshotURL"] as? String {
            gameScreenshotURL = URL(string: screenshotURL)!
        } else {
            print("Fetching game's screenshot from DB returns nil.")
            gameScreenshotURL = nil
        }
        
        guard let gameGenre = gameDictionary["genre"] as? String else {
            print("Fetching game's genre from DB returns nil.")
            return nil
        }
        
        guard let gamePlatforms = gameDictionary["platforms"] as? String else {
            print("Fetching game's platforms from DB returns nil.")
            return nil
        }
        
        var gameReleaseDate:Date
        if let releaseDate = gameDictionary["releaseDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            gameReleaseDate = dateFormatter.date(from: releaseDate)!
        } else {
            print("Fetching game's releaseDate from DB returns nil.")
            return nil
        }
        
        guard let gameSynopsis = gameDictionary["synopsis"] as? String else {
            print("Fetching game's synopsis from DB returns nil.")
            return nil
        }
        
        guard let gameEditorsCritic = gameDictionary["editorsCritic"] as? String else {
            print("Fetching game's editorsCritic from DB returns nil.")
            return nil
        }
        
        var gameStores = [Store]()
        if let storesDict = gameDictionary["stores"] as? [String:AnyObject] {
            for storeDict in storesDict {
                let storeName = storeDict.key
                let storeURL:URL? = URL(string: (storeDict.value as? String)!)
                let storeImage = UIImage(named:"storeIcon_\(storeName)")
                let store = Store(name: storeName, website: storeURL!, image: storeImage!)
                gameStores.append(store)
                
            }
        } else {
            print("Fetching game's stores from DB returns nil.")
        }

        
        let game = Game(id: gameID, name: gameName, developer: gameDev, devWebsite: gameDevWebsite, posterURL: gamePosterURL, screenshotURL: gameScreenshotURL, genre: gameGenre, platforms: gamePlatforms, releaseDate: gameReleaseDate, synopsis: gameSynopsis, editorsCritic: gameEditorsCritic, stores: gameStores)
        print("Game (\(game.id)) fetched successfully.")
        
        return game
    }
    
    static func fetchGameComments(game:Game, completionHandler: @escaping(Bool) -> Void){
        let commentsRef = ref.child("games").child(game.id).child("comments")
        
        commentsRef.observeSingleEvent(of: .value) {
            (commentsSnapshot) in
            
            var gameComments = [Comment]()
            
            //Getting user's information dictionary
            guard let commentsDict = commentsSnapshot.value as? [String: AnyObject] else {
                print("Comments fetched returned a nil snapshot from DB.")
                game.comments = gameComments
                completionHandler(false)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for comment in commentsDict {
                
                let commDict = comment.value as? [String:AnyObject] ?? [:]
                
                let commentCreator = commDict["username"] as! String
                
                let blacklist = MainUser.shared?.blacklistedUsers ?? [String]()
                
                if !blacklist.contains(commentCreator) {
                    dispatchGroup.enter()
                    fetchUser(byUsername: commentCreator, completionHandler: {
                        (user) in
                        
                        var commentDate:Date
                        let date = commDict["date"] as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                        
                        commentDate = dateFormatter.date(from: date)!
                        
                        let commentContent = commDict["content"] as! String
                        
                        let newComment = Comment(id: comment.key, creator: user!, dateCreated: commentDate, content: commentContent)
                        gameComments.append(newComment)
                        dispatchGroup.leave()
                    })
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                game.comments = gameComments
                completionHandler(true)
            })
        }
        
    }
    
    static func add(gameID: String, toList list: String, completionHandler: @escaping(Error?) -> Void) {
        let usersRef = ref.child("users")
        usersRef.child(MainUser.shared!.username).child("gameList").child(gameID).setValue(list) { (error, _) in
            guard (error == nil) else {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
    
    static func remove(gameID: String, toList list: String, completionHandler: @escaping(Error?) -> Void) {
        let usersRef = ref.child("users")
        usersRef.child(MainUser.shared!.username).child("gameList").child(gameID).removeValue() { (error, _) in
            guard (error == nil) else {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
    
    static func addComment(fromUser user: User, content:String, toGame game:Game, completionHandler: @escaping(Error?, Comment?)->Void) {
        
        let dateCreated = Date()
        
        let dateString = String(describing:dateCreated)
        
        let commentsRef = ref.child("games").child(game.id).child("comments").childByAutoId()
        
        let commentDict: [String : Any] = [
            "content": content,
            "username": user.username,
            "date": dateString,
            ]
        
        
        
        let newComment = Comment(id: commentsRef.key, creator: user, dateCreated: dateCreated, content: content)
        
        commentsRef.setValue(commentDict) { (error, _) in
            guard (error == nil) else {
                completionHandler(error, nil)
                return
            }
            completionHandler(nil, newComment)
        }
    }
    
    static func update(profilePictureURL:String, forUser user:User, completionHandler: @escaping(Error?)->Void){
        let picUrlRef = ref.child("users").child(user.username).child("profilePictureURL")
        picUrlRef.setValue(profilePictureURL) { (error, _) in
            if error != nil {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
    
    static func report(comment:Comment, onGame game:Game, blacklisted:Bool, completionHandler:@escaping(Error?)->Void) {
        
        let reportRef = ref.child("reportedComments").child(game.id).child(comment.id).child("usersWhoReported")
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        reportRef.childByAutoId().setValue((MainUser.shared?.username ?? "") as AnyObject) { (error, _) in
            if error != nil {
                completionHandler(error)
            }
            dispatchGroup.leave()
        }
        
        if let mainUser = MainUser.shared {
            if blacklisted {
                let userRef = ref.child("users").child(mainUser.username)
                dispatchGroup.enter()
                userRef.child("blacklist").child(comment.creator.username).setValue("true", withCompletionBlock: { (error, _) in
                    if error != nil {
                        completionHandler(error)
                    } else {
                        mainUser.blacklistedUsers.append(comment.creator.username)
                    }
                    dispatchGroup.leave()
                })
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandler(nil)
            return
        }
        
    }
    
}
