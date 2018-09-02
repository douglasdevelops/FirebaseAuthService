//
//  AuthService.swift
//

import Foundation
import Firebase

//Costants Should Be Moved To Seperate File
let FIREBASEAUTHERROR_INVALID_EMAIL_ADDRESS = "Invalid Email Address"
let FIREBASEAUTHERROR_INVALID_GENERAL_ERROR = "General Error"
let FIREBASEAUTHERROR_INVALID_INCORRECT_PASSWORD = "Incorrect Password"
let FIREBASEAUTHERROR_INVALID_EMAIL_IN_USE = "Email Already In Use"
let FIREBASEAUTHERROR_INVALID_EMAIL_EXSISTS_WITH_DIFFERENT_CREDENTIAL = "Email Already In Use, With A Different Credential Set"




class AuthService {
    private static let _instance = AuthService()
    
    typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void
    
    static var instance: AuthService {
        return _instance
    }
    
    func SignUpUser(email: String, password: String, firstname: String, lastname: String, username: String, onComplete: @escaping Completion) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
            if err != nil {
                self.FireBaseErrorHandler(error: err! as NSError, onComplete: onComplete)
            }
            else {
                if user?.user.uid != nil {
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            self.FireBaseErrorHandler(error: error! as NSError, onComplete: onComplete)
                        } else {
                            onComplete(nil,user)
                        }
                    })
                }
            }
        })
    }
    func login(email: String, password: String, onComplete: @escaping Completion) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    if errorCode == AuthErrorCode.userNotFound {
                        self.FireBaseErrorHandler(error: error! as NSError, onComplete: onComplete)
                    }
                } else { // all other erros
                    self.FireBaseErrorHandler(error: error! as NSError, onComplete: onComplete)
                }
            } else {
                debugPrint("Logged In...")
            }
        })
    }
    
    func FireBaseErrorHandler(error: NSError, onComplete: Completion?) {
        if  let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .invalidEmail:
                onComplete?(FIREBASEAUTHERROR_INVALID_EMAIL_ADDRESS, nil)
                break;
            case .wrongPassword:
                onComplete?(FIREBASEAUTHERROR_INVALID_INCORRECT_PASSWORD, nil)
                break;
            case .emailAlreadyInUse:
                onComplete?(FIREBASEAUTHERROR_INVALID_EMAIL_IN_USE, nil)
                break;
            case .accountExistsWithDifferentCredential:
                onComplete?(FIREBASEAUTHERROR_INVALID_EMAIL_EXSISTS_WITH_DIFFERENT_CREDENTIAL, nil)
                break;
            default:
                onComplete?(FIREBASEAUTHERROR_INVALID_GENERAL_ERROR, nil)
            }
        }
    }
}
