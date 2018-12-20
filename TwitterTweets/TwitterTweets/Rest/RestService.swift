//
//  RestService.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON

class RestService: NSObject {
    let baseURL = "https://api.twitter.com/1.1/search/tweets.json"
    let twitterSearchKey = "q"
    let twitterConsumerKey = "DGZVogdlxWk7RTQoUrxlrEDqj"
    let twitterConsumerSecret = "GLL7OkqfUjMrpj72Y8VsqqCs0icibTEYDF7blLrY7pM7d1JYlZ"
    
    static let shared = RestService()
    
    func getTweetsWith(searchString: String, onSuccess: @escaping([Tweet]) -> Void, onFailure: @escaping(Error) -> Void){
        
        let oauthswift = OAuth1Swift(
            consumerKey:    twitterConsumerKey,
            consumerSecret: twitterConsumerSecret
        )
        
        _ = oauthswift.client.get(baseURL,
                                  parameters:[twitterSearchKey:searchString],
                                  success: { response in
                                    let jsonData = response.string?.data(using: .utf8)!
                                    let tweets = try? JSONDecoder().decode([Tweet].self,
                                                                           from: jsonData!, keyPath:"statuses")
                                    
                                    onSuccess(tweets ?? [])
        },
                                  failure: { error in
                                    onFailure(error)
        })
        
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
        let toplevel = try JSONSerialization.jsonObject(with: data)
        if let nestedJson = (toplevel as AnyObject).value(forKeyPath: keyPath) {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
            return try decode(type, from: nestedJsonData)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nested json not found for key path \"\(keyPath)\""))
        }
    }
}
