//
//  ImageCacheManager.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/20/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

/*
 Discussion:
 
 Util - manage caching of images' data
 Purposes: save the image' data for cards' images on the disk
 
 
 Info.plist preparation:
 Adding one object into the application Info.plist
 
 NSAppTransportSecurity: Dictionary containing one object
 NSAllowsArbitraryLoads bool value set to YES
 
 This is allowing us to download data from 'unsafe'-considered places.
 
 
 Functionalities:
 *) wake up cache -> void
 *) cache image for request with url -> void
 *) get image from cache for request with url, instead of downloading it -> uiimage
 *) checks if data from request with url is cached on the disk -> bool
 *) complex method - takes imageURLString & imageView for displaying the image as arguments - trying to get cached image if any or download and cache new images
 */

import UIKit
/*
 Discussion:
 
 Use ImageViewWithURLString instead of UIImageView when downloading data from within TableViewCell
 
 How to use:
 *)You may set different placeholderImage using:         < cell_instance_name.image_view_with_url_string_instance_name.placeholderImage > method
 *)Get the image for the imageView by calling: imageURLString
 
 E.G. < cell_instance_name.image_view_with_url_string_instance_name.imageURLString = image_url_string >
 */

public let PLACEHOLDER_IMAGE = UIImage(named: "twitter_iphone_blue_image")

@objc public protocol ImageCacheManagerDelegate {
    func downloadImageSuccessfull(_ image: UIImage?,row:Int )
}

final class CacheManager {
    
    var cachedImages:[String:UIImage] = [:]
    
    static let sharedInstance = CacheManager()
    
}

open class ImageCacheManager {
    
    /**
     return image from cache or download it if not cached
     */
    class func getCachedImageWithURLString(_ imageURLString: String?, andSetItToImageView imageView:UIImageView?) {
        
        if let savedImage = CacheManager.sharedInstance.cachedImages[imageURLString!]{
            imageView?.image = savedImage
            return
        }
        
        //check if imageURLString input parameter is actual working string/urlString
        if ImageCacheManager.isValidInputImageURLString(imageURLString) == false {
            return
        }
        
        //check if imageView exists
        if imageView == nil {
            /*
             Discussion:
             
             1) the imageView does not exist, so there is no need to update the UI
             2) may still continue with the download & caching of the image
             */
            
            return
        }
        
        //create request with the string url
        let request = ImageCacheManager.createURLRequestForURLString(imageURLString!)
        
        //check in cache - try to get cached image
        ImageCacheManager.getCachedImageForRequest(request ,completion: {cachedImage in
            
            if cachedImage != nil {
                CacheManager.sharedInstance.cachedImages[imageURLString!] = cachedImage
                //set cached image to imageView
                DispatchQueue.main.async { [weak imageView] in
                    imageView?.image = cachedImage
                }
            }
            else {
                if let imageViewWithURLString = imageView as? ImageViewWithURLString {
                    if imageViewWithURLString.showLoading {
                        DispatchQueue.main.async { [weak imageViewWithURLString] in
                            imageViewWithURLString?.image = imageViewWithURLString?.placeholderImage
                        }
                    }
                }
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if(data != nil && response != nil){
                        URLCache.shared.storeCachedResponse(CachedURLResponse(response: response!, data: data!) , for: request)
                    }
                    //update the UI in the main thread
                    DispatchQueue.main.async { [weak imageView] in
                        
                        //take the image from the data. otherwise the image is not always cached at the time the block is called and the app might crash
                        guard let data = data else {
                            imageView?.image = nil
                            return
                        }
                        
                        guard let image = UIImage(data: data) else {
                            imageView?.image = nil
                            return
                        }
                        
                        
                        //check for tableViewCell custom imageView with urlString
                        if let imageViewWithURLString = imageView as? ImageViewWithURLString {
                            CacheManager.sharedInstance.cachedImages[imageURLString!] = image
                            imageViewWithURLString.setImage(image, forImageURLString: imageURLString!)
                        }
                        else {
                            //standart imageView
                            imageView?.image = image
                        }
                    }
                }).resume()
            }
        })
    }
    
    
    
    /**
     need to wake up the cache on application start, so the the cache will be ready to cache data on demand
     */
    public class func wakeUpCache(_ capacityParameters: (memoryCapacity:Int, diskCapacity: Int)? = nil) {
        if let cacheCapacities = capacityParameters {
            //create new URLCache if needed and set it as SharedUrlCache
            if URLCache.shared.diskCapacity != cacheCapacities.diskCapacity ||
                URLCache.shared.memoryCapacity != cacheCapacities.memoryCapacity {
                
                let sharedCache = URLCache.init(memoryCapacity:cacheCapacities.memoryCapacity,
                                                diskCapacity:cacheCapacities.diskCapacity,
                                                diskPath:"nsurlcache")
                URLCache.shared = sharedCache
            }
        }
        else {
            //wake up cache - call sharedCache instance
            let _ = URLCache.shared
        }
        
        //sleep the main thread for a second to give enough time for the sharedCache to init
        sleep(1)
    }
    
    /**
     cache image located on URL with string
     */
    class func cacheImageWithURLString(_ imageURLString: String?) {
        
        //check if imageURLString input parameter is actual working string/urlString
        if ImageCacheManager.isValidInputImageURLString(imageURLString) == false {
            return
        }
        
        //init a reuqest to get the remote resource(image)
        let request = ImageCacheManager.createURLRequestForURLString(imageURLString!)
        
        //check in cache
        if ImageCacheManager.isDataCachedForRequest(request) == false {
            //save to cache
            //ImageCacheManager.cacheImageDataFromRequest(request)
        }
        
    }
    
    /**
     check if data is cached for request with url string
     */
    class func isImageCachedForRequestWithURLString(_ imageURLString: String?) -> Bool {
        let request = ImageCacheManager.createURLRequestForURLString(imageURLString!)
        
        return ImageCacheManager.isDataCachedForRequest(request)
    }
    
    
    
    //create request for url with string
    fileprivate class func createURLRequestForURLString(_ string: String) -> URLRequest {
        return URLRequest(url: URL(string: string)!)
    }
    
    //check the cache for cachedResponse - if it is already cached
    fileprivate class func isDataCachedForRequest(_ request: URLRequest) -> Bool {
        
        if let _ = URLCache.shared.cachedResponse(for: request) {
            print("cahced response found!")
            //handle case when cached response is found
            return true
        }
        
        //no cahcedResponse is found
        return false
    }
    
    //get image data from cache and return UIImage from it
    fileprivate class func getCachedImageForRequest(_ request: URLRequest, completion:@escaping ((UIImage?) -> Void)){
        DispatchQueue.global(qos: .background).async {
            //check for available data - crash when trying to unwrap data for request when no internet connection is available
            if (URLCache.shared.cachedResponse(for: request)?.data) != nil {
                completion(UIImage(data: (URLCache.shared.cachedResponse(for: request)?.data)!))
            }
            
            completion(nil)
        }
    }
    
    /*
     Analog of the upper code with NSURLConnection
     NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
     
     May also use dataTaskWIthRequest(<#T##request: NSURLRequest##NSURLRequest#>) func if we do not care about possible errors/ response additional information or further response data management
     */
    //save to cache
    fileprivate class func cacheImageDataFromRequest(_ request: URLRequest) {
        //may do some preparation before cache the image
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            //error -> check for possible error
            if error != nil {
                print("Error caching image data request: \(error?.localizedDescription ?? "default value")")
            }
            
            //response -> detail information about the response object
            //data -> uiimage as nsdata; use UIImage.init(data:) initializer to get the actual image
            
            /*
             Discussion:
             
             Use:
             getCachedImageWithURLString(imageURLString: String, andSetItToImageView imageView:UIImageView)
             method instead of the following work-flow.
             
             Do NOT use the following work-flow:
             imgUrl - imageURLString
             
             Sender ViewController tries to cache and image - either if an image is downloaded or not
             E.G.
             ImageCacheManager.cacheImageWithURLString(imgUrl)
             
             Inform the sender ViewController that the image is downloaded.
             The way to do is:
             E.G.
             NSNotificationCenter.defaultCenter().postNotificationName("image downloaded", object: self)
             
             The sender ViewController should register as observer:
             E.G.
             NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage", name: "image downloaded", object: nil)
             
             and the sender ViewController should handle the updating of the imageView with the downloaded image in the MAIN THREAD
             E.G.
             func updateImage() {
             dispatch_async(dispatch_get_main_queue()) { [weak self] in
             self?.imgView.image = ImageCacheManager.getCachedImageWithURLString((self?.imgUrl)!)
             }
             }
             */
            
        }) .resume()
        //resuming this task will download and cache the image for us
    }
    
    //check if the address of the remote resource is valid
    fileprivate class func isValidInputImageURLString(_ imageURLString: String?) -> Bool {
        
        if imageURLString == nil {
            return false
        }
        else if imageURLString!.isEmpty {
            /*
             Discussion:
             
             If the image address is not valid - there is no need to continue with this method
             */
            
            return false
        }
        
        return true
    }
    
}
