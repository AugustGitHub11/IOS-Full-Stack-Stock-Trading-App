//
//  apiService.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 4/11/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON

class GetSearchAPI {
    var searchUrl: String
    
    init(searchUrl: String) {
        self.searchUrl = searchUrl
    }
    
    func getSearch(callback: @escaping (_ stockCandidates: [stockSearch]) -> ()) {
        var stockCandidates: [stockSearch] = []
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockCandidates = json.to(type: stockSearch.self) as! [stockSearch]
                    callback(stockCandidates)
                }
            }
        }
    }
    
    func getDescription(callback: @escaping (_ stockDescription: Description) -> ()) {
        var stockDescription: Description? = nil
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockDescription = json.to(type: Description.self) as! Description
                    callback(stockDescription!)
                }
            }
        }
    }
    
    func getLatestPrice(callback: @escaping (_ stockLatestPrice: LatestPrice) -> ()) {
        var stockLatestPrice: LatestPrice? = nil
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockLatestPrice = json.to(type: LatestPrice.self) as! LatestPrice
                    callback(stockLatestPrice!)
                }
            }
        }
    }
    
    func getPeers(callback: @escaping (_ stockPeers: [peers]) -> ()) {
        var stockPeers: [peers] = []
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockPeers = json.to(type: peers.self) as! [peers]
                    callback(stockPeers)
                }
            }
        }
    }
    
    func getSocialSentiments(callback: @escaping (_ stockSocialSentiments: SocialSentiments) -> ()) {
        var stockSocialSentiments: SocialSentiments? = nil
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockSocialSentiments = json.to(type: SocialSentiments.self) as! SocialSentiments
                    callback(stockSocialSentiments!)
                }
            }
        }
    }
    
    func getNews(callback: @escaping (_ stockNews: [news]) -> ()) {
        var stockNews: [news] = []
        
        if let searchUrl = URL(string: (searchUrl)) {
            AF.request(searchUrl).validate().responseJSON { (response) in
                if let data = response.data {
                    let json = JSON(data)
                    stockNews = json.to(type: news.self) as! [news]
                    callback(stockNews)
                }
            }
        }
    }
}
