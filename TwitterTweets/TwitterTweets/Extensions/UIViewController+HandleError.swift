//
//  UIViewController+HandleError.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/20/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Present alert to the user with description message.
    /// If no `message` is set, try to take error's description and
    /// if no such description is available show default error message.
    func handleError(_ error: Error?, message: String? = nil) {
        let errorMessage = self.errorMessage(for: error, message: message)
        let alert = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func errorMessage(for error: Error?, message: String?) -> String {
        let errorMessage: String
        if let message = message {
            errorMessage = message
        } else if let message = error?.localizedDescription, !message.isEmpty {
            errorMessage = message
        } else {
            errorMessage = "Something went wrong"
        }
        return errorMessage
    }
}
