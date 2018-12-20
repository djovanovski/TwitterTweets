//
//  ImageViewWithUrlString.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/20/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

private let ACTIVITY_INDICATOR_TAG_WHOLE_SCREEN  = 100
private let ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW = 101

open class ImageViewWithURLString: UIImageView {
    
    
    var row:Int?
    @IBOutlet public weak var delegate:ImageCacheManagerDelegate?
    
    /**
     Flag if we should set placeholderImage and show loading indicator on every download of new imageURLString
     
     Discussion: You might need to download sample smaller image fast for some imageViews, and after a time you might need to download bigger resolution image for the same imageView. Then you do NOT need to set placeholderImage again, but to keep the previously downloaded sample image. So you need to set this flag to `true`
     */
    @IBInspectable public var showLoading:Bool = true
    
    fileprivate let ACTIVITY_INDICATOR_TAG = 678
    
    /**
     set placeholder image while downloading image
     */
    public var placeholderImage: UIImage? = PLACEHOLDER_IMAGE{
        didSet {
            if self.placeholderImage == nil {
                self.placeholderImage = PLACEHOLDER_IMAGE
            }
        }
    }
    
    /**
     try to get cached image for url string
     */
    public var imageURLString: String? {
        didSet {
            //default image
            if showLoading {
                image = placeholderImage
            }
            
            //get the actual image
            if imageURLString != nil {
                ImageCacheManager.getCachedImageWithURLString(imageURLString, andSetItToImageView: self)
            }
        }
    }
    
    /**
     set cached image to imageView for imageURLString
     */
    public func setImage(_ image: UIImage?, forImageURLString imageURLString: String?) {
        if (self.imageURLString == imageURLString &&
            image != nil &&
            imageURLString != nil) {
            self.image = image
        }
    }
    
    override open var image: UIImage? {
        didSet {
            if image == placeholderImage {
                if showLoading {
                    ImageViewWithURLString.startActivityIndicator(self.activityIndicatorViewStyle, inView: self)
                }
            }
            else{
                if let imageDelegate = self.delegate{
                    imageDelegate.downloadImageSuccessfull(image,row: self.row ?? -1)
                }
                ImageViewWithURLString.stopActivityIndicator(inView: self)
            }
        }
    }
    
    /**
     Set activity indicator style (color). Default value is `.White`.
     */
    public var activityIndicatorViewStyle = UIActivityIndicatorView.Style.white
    
    //public methods - class methods
    // start/stop activity indicator in view
    class func startActivityIndicator(_ activityIndicatorStyle:UIActivityIndicatorView.Style, inView view: UIView) {
        
        //is there view with this tag
        if let subview = view.viewWithTag(ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW) {
            //is this view self.activityIndicator
            if let _ = subview as? UIActivityIndicatorView {
                //do NOT add second activityIndicator to view that already have subview activityIndicator
                return
            }
        }
        
        let customActivityIndicator = UIActivityIndicatorView()
        customActivityIndicator.style = activityIndicatorStyle
        customActivityIndicator.startAnimating()
        customActivityIndicator.tag = ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW
        
        view.addSubview(customActivityIndicator)
        customActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        ImageViewWithURLString.addConstraintsFillInView(viewToFillIn: view, withActivityIndicatorView: customActivityIndicator)
    }
    
    class func stopActivityIndicator(inView view:UIView) {
        if let subview = view.viewWithTag(ACTIVITY_INDICATOR_TAG_SPECIFIC_VIEW) {
            if let customActivityIndicator = subview as? UIActivityIndicatorView {
                customActivityIndicator.stopAnimating()
                customActivityIndicator.removeFromSuperview()
            }
        }
    }
    
    class private func addConstraintsFillInView(viewToFillIn superview:UIView, withActivityIndicatorView activityIndicator:UIActivityIndicatorView) {
        ImageViewWithURLString.addConstraint(item: activityIndicator, attibute: .top, toItem: superview)
        ImageViewWithURLString.addConstraint(item: activityIndicator, attibute: .bottom, toItem: superview)
        ImageViewWithURLString.addConstraint(item: activityIndicator, attibute: .left, toItem: superview)
        ImageViewWithURLString.addConstraint(item: activityIndicator, attibute: .right, toItem: superview)
    }
    
    class private func addConstraint(item activityIndicator: UIActivityIndicatorView, attibute: NSLayoutConstraint.Attribute, toItem superview: UIView) {
        superview.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: attibute, relatedBy: .equal, toItem: superview, attribute: attibute, multiplier: 1, constant: 0))
    }
}
