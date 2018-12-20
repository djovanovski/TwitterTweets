//
//  UINavigationController+statusBar.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
