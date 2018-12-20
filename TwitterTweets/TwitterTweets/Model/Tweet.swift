//
//  Tweet.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

class Tweet: Codable {
    let text:String?
    let created_at:String?
    var entities:TweetEntity?
    var user:TweetUser?
    
    private enum CodingKeys: String, CodingKey {
        case entities
        case text
        case created_at
        case user
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        created_at = try container.decode(String.self, forKey: .created_at)
        if let entities = try container.decodeIfPresent(TweetEntity.self, forKey: .entities) {
            self.entities = entities
        }
        else{
            self.entities = nil
        }
        if let user = try container.decodeIfPresent(TweetUser.self, forKey: .user) {
            self.user = user
        }
        else{
            self.user = nil
        }
    }
}
