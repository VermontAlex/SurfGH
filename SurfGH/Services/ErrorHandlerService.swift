//
//  ErrorHandlerService.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

class TestError: Error {
    
}

enum ErrorHandlerService {
    
    struct AlertConstants {
        static let unknownedError = "Unknowned Error"
        static let defaultError = "Error"
        static let defaultMessage = "Something went wrong, please try again later"
    }
    
    case error(Error)
    case errorString(String)
    case errorKeyChain(OSStatus)
    case unknownedError(Error? = nil)
    
    func handleErrorWithUI() -> UIAlertController? {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        switch self {
        case .error(let error):
            alert.title = AlertConstants.defaultError
            alert.message = error.localizedDescription
        case .unknownedError:
            alert.title = AlertConstants.unknownedError
            alert.message = AlertConstants.defaultMessage
            return alert
        case .errorString(let str):
            alert.title = AlertConstants.defaultError
            alert.message = str
            return alert
        default:
            break
        }
        return nil
    }
    
    func handleErrorWithDB() {
        //  Should be implemented when backend done.
    }
}
