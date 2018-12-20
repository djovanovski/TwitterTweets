//
//  TweetsTableViewCell.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/20/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit
import Kingfisher

class TweetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageAvatar: ImageViewWithURLString!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imageTweet: ImageViewWithURLString!
    @IBOutlet weak var imageTweetHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTweetWidthConstraint: NSLayoutConstraint!
    
    
    class func reuseIdentifier() -> String {
        return "TweetsTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageAvatar.layer.cornerRadius = self.imageAvatar.frame.width/2
    }
    
    func populateCellWith(tweet: Tweet){
        
        self.imageTweet.image = UIImage()
        self.imageAvatar.imageURLString = tweet.user?.profile_image_url_https

        self.labelDescription.text = tweet.text
        self.labelUsername.text = tweet.user?.name
        
        let date = tweet.created_at?.split(separator: "+").first
        self.labelDate.text = String(date ?? "")
        self.labelDate.textColor = .twitterColor
        

        if let media = tweet.entities?.media, media.count > 0 {
            
            if let imageUrl = media[0].media_url_https, !imageUrl.isEmpty {
                
                self.imageTweet.imageURLString = imageUrl
        
                if let size = imageTweet.image?.size{
                    let constant = labelDescription.frame.width / size.width
                    
                    self.imageTweetWidthConstraint.constant = size.width > labelDescription.frame.width ? constant * size.width : size.width
                    self.imageTweetHeightConstraint.constant = size.width > labelDescription.frame.height ? constant * size.height : size.height
                }
            }
        }
        else{
            self.imageTweetWidthConstraint.constant = 0
            self.imageTweetHeightConstraint.constant = 0
        }
        
        //TODO: Use library for fetching downlaoded image i.e Kingfisher and update cell layout when image is fetched
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
