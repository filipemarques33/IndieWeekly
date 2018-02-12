//
//  AppErrors.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 25/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

public enum LoginServicesError: Error {
    case fieldFilling
    case usernameTaken
    case confirmationDifferent
    case invalidCharacter
}

extension LoginServicesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fieldFilling:
            return NSLocalizedString("Fill all fields to proceed.", comment: "")
        case .usernameTaken:
            return NSLocalizedString("Username already taken.", comment: "")
        case .confirmationDifferent:
            return NSLocalizedString("Password doesn't match confirmation.", comment: "")
        case .invalidCharacter:
            return NSLocalizedString("Username cannot contain the following characters: . $ [ ] # / ", comment: "")
        }
    }
}
