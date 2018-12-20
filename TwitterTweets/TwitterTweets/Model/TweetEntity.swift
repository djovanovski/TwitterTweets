//
//  TweetEntity.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

class TweetEntity:Codable {
    let media:[TweetMedia]?
    
    private enum CodingKeys: String, CodingKey {
        case media
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let media = try container.decodeIfPresent([TweetMedia].self, forKey: .media) {
            self.media = media
        }
        else{
            media = []
        }
    }
}
