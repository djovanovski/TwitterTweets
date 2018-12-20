//
//  UIColor+Custom.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

extension UIColor {
    
    //MARK: - All Colors
    static let twitterColor = UIColor.color(withRed: 56, green: 161, blue: 243, alpha: 1)
    static let grayScale = UIColor.color(withRed: 92, green: 102, blue: 110, alpha: 1)

    
    //MARK: -
    static func color(withRed red: CGFloat,
                      green: CGFloat,
                      blue: CGFloat,
                      alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
