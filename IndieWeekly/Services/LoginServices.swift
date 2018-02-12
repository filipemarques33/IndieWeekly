//
//  LoginServices.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 11/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import FirebaseAuth

class LoginServices {
    
    static func handleUserRegistration(username: String, email:String, password:String, passwordConfirmation:String, completionHandler: @escaping (Error?) -> Void) {
        
        if username == "" || email == "" || password == "" || passwordConfirmation == "" {
            let error:Error = LoginServicesError.fieldFilling
            completionHandler(error)
            return
        }
        
        let invalidCharacters = [".", "$", "[", "]", "#", "/"]
        
        for char in invalidCharacters {
            if username.contains(char){
                let error:Error = LoginServicesError.invalidCharacter
                completionHandler(error)
                return
            }
        }
        
        if password != passwordConfirmation {
            let error:Error = LoginServicesError.confirmationDifferent
            completionHandler(error)
            return
        }
        
        DatabaseManager.fetchUser(byUsername: username) {
            (userFetched) in
            if userFetched == nil {
                Auth.auth().createUser(withEmail: email, password: password) {
                    (user, error) in
                    if user != nil {
                        let newUser = MainUser(username: username, email: email)
                        DatabaseManager.add(user: newUser){
                            (dbError) in
                            if dbError != nil {
                                completionHandler(dbError)
                                return
                            } else {
                                MainUser.shared = newUser
                                print("Added to DB")
                                completionHandler(nil)
                            }
                        }
                        return
                    } else {
                        completionHandler(error)
                        return
                    }
                }
            } else {
                let error:Error = LoginServicesError.usernameTaken
                completionHandler(error)
                return
            }
        }
    }
    
    static func handleUserRegistration(username: String, email:String, password:String, completionHandler: @escaping (Error?) -> Void) {
        DatabaseManager.fetchUser(byUsername: username){
            (userFetched) in
            if userFetched == nil {
                Auth.auth().createUser(withEmail: email, password: password) {
                    (user, error) in
                    if user != nil {
                        let newUser = MainUser(username: username, email: email)
                        DatabaseManager.add(user: newUser){
                            (dbError) in
                            if dbError != nil {
                                completionHandler(dbError)
                                return
                            } else {
                                MainUser.shared = newUser
                                print("Added to DB")
                                completionHandler(nil)
                            }
                        }
                        return
                    } else {
                        completionHandler(error)
                        return
                    }
                }
            } else {
                print("User already on db")
                return
            }
        }
    }
    
    static func handleUserLoggedIn(email:String, password:String, completionHandler: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            if user != nil {
                DatabaseManager.fetchMainUser(byEmail: email) {
                    (userFetched) in
                    if userFetched != nil {
                        MainUser.shared = userFetched
                        completionHandler(true, nil)
                    } else {
                        print("Couldn't fetch user (\(email) from database")
                        completionHandler(false, nil)
                    }
                }
            } else if error != nil {
                completionHandler(false, error)
            }
        }
        
    }
    
    static func handleUserLoggedOut(){
        try! Auth.auth().signOut()
        MainUser.shared = nil
    }
    
    static func checkAndStartSession(completionHandler:@escaping (MainUser?)->Void) {
        if let user = Auth.auth().currentUser {
            DatabaseManager.fetchMainUser(byEmail: user.email!, completionHandler: { (fetchedUser) in
                completionHandler(fetchedUser)
            })
        } else {
            completionHandler(nil)
        }
    }
    
    static func setLoginScreenNeed(isNeeded: Bool) {
        UserDefaults.standard.set(isNeeded, forKey: "LoginScreenNeeded")
    }
    
    static func checkLoginScreenNeed() -> Bool? {
        if let isNeeded = UserDefaults.standard.object(forKey: "LoginScreenNeeded") as? Bool {
            return isNeeded
        }
        return nil
    }
}
