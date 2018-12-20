//
//  TweetsViewController.swift
//  TwitterTweets
//
//  Created by Darko Jovanovski on 12/19/18.
//  Copyright © 2018 Darko Jovanovski. All rights reserved.
//

import UIKit

let SEARCH_BAR_CORNER_RADIUS:CGFloat = 10
let SEARCH_BAR_SEARCH_FIELD_KEY:String = "searchField"
let SEARCH_BAR_SEARCH_FIELD_PLACEHOLDER:String = "Search Tweets"

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let searchController = UISearchController(searchResultsController: nil)
    private var dataSource:[Tweet] = []
    
    //MARK: - ViewController Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: - Private functions
    private func setup() {
        self.tableView.register(UINib(nibName:TweetsTableViewCell.reuseIdentifier(),bundle: nil), forCellReuseIdentifier: TweetsTableViewCell.reuseIdentifier())
        self.tableView.backgroundColor = .grayScale
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = SEARCH_BAR_SEARCH_FIELD_PLACEHOLDER

        self.searchController.searchBar.barTintColor = UIColor.lightText
        self.searchController.searchBar.tintColor = .white
        self.definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.searchController.searchResultsUpdater = self
            self.searchController.searchBar.tintColor = UIColor.white
            self.searchController.searchBar.barTintColor = UIColor.white
            self.searchController.searchBar.clipsToBounds = true
        } else {
            // Just in case if someone changes the build target to be < 11.0
            self.searchController.searchBar.tintColor = UIColor.white
            self.searchController.searchBar.barTintColor = .twitterColor
            self.searchController.searchBar.clipsToBounds = true
            self.searchController.hidesNavigationBarDuringPresentation = false
            self.searchController.dimsBackgroundDuringPresentation = false
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
            self.searchController.searchBar.sizeToFit()
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        
        if let textfield = self.searchController.searchBar.value(forKey: SEARCH_BAR_SEARCH_FIELD_KEY) as? UITextField {
            if let backgroundview = textfield.subviews.first {
                
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = SEARCH_BAR_CORNER_RADIUS;
                backgroundview.clipsToBounds = true;
            }
        }
        
        searchController.searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetsTableViewCell.reuseIdentifier(), for: indexPath) as! TweetsTableViewCell
        cell.populateCellWith(tweet: self.dataSource[indexPath.row])
        
        return cell
    }
}

extension TweetsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.activityIndicator.startAnimating()
        RestService.shared.getTweetsWith(searchString: searchBar.text ?? "", onSuccess: {[weak self] tweets in
            self?.activityIndicator.stopAnimating()
            self?.dataSource = tweets
            self?.tableView.reloadData()
            }, onFailure: { [weak self] error in
                self?.activityIndicator.stopAnimating()
                self?.handleError(error)
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
    
    func updateSearchResults(for searchController: UISearchController) {}
}
