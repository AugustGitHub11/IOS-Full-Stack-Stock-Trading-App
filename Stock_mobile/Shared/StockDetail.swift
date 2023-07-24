//
//  StockDetail.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 4/14/22.
//

import SwiftUI
import SwiftyJSON
import Kingfisher
import UIKit
import WebKit

let descriptionUrl = "https://csci-hw8-server.wl.r.appspot.com/api/description/"
let latestPriceUrl = "https://csci-hw8-server.wl.r.appspot.com/api/latestPrice/"
let peersUrl = "https://csci-hw8-server.wl.r.appspot.com/api/peers/"
let socialSentimentsUrl = "https://csci-hw8-server.wl.r.appspot.com/api/socialSentiment/"
let newsUrl = "https://csci-hw8-server.wl.r.appspot.com/api/news/"

class Description: Identifiable, JSONable {
    let name: String
    let logo: String
    let ipo: String
    let finnhubIndustry: String
    let weburl: String

    required init(parameter: JSON) {
        name = parameter["name"].stringValue
        logo = parameter["logo"].stringValue
        ipo = parameter["ipo"].stringValue
        finnhubIndustry = parameter["finnhubIndustry"].stringValue
        weburl = parameter["weburl"].stringValue
    }
}

class LatestPrice: Identifiable, JSONable {
    let c: String
    let d: String
    let dp: String
    let t: String
    let h: String
    let l: String
    let o: String
    let pc: String

    required init(parameter: JSON) {
        c = String(format: "%.2f", Float(parameter["c"].stringValue) ?? 0)
        d = String(format: "%.2f", Float(parameter["d"].stringValue) ?? 0)
        dp = String(format: "%.2f", Float(parameter["dp"].stringValue) ?? 0)
        t = parameter["t"].stringValue
        h = String(format: "%.2f", Float(parameter["h"].stringValue) ?? 0)
        l = String(format: "%.2f", Float(parameter["l"].stringValue) ?? 0)
        o = String(format: "%.2f", Float(parameter["o"].stringValue) ?? 0)
        pc = String(format: "%.2f", Float(parameter["pc"].stringValue) ?? 0)
    }
}

class peers: Identifiable, Decodable, JSONable {
    let peer: String

    required init(parameter: JSON) {
        peer = parameter.stringValue
    }
}

class SocialSentiments: Identifiable, JSONable {
    let redditM: String
    let redditPM: String
    let redditNM: String
    let twitterM: String
    let twitterPM: String
    let twitterNM: String

    required init(parameter: JSON) {
        redditM = parameter["redditM"].stringValue
        redditPM = parameter["redditPM"].stringValue
        redditNM = parameter["redditNM"].stringValue
        twitterM = parameter["twitterM"].stringValue
        twitterPM = parameter["twitterPM"].stringValue
        twitterNM = parameter["twitterNM"].stringValue
    }
}

class news: Identifiable, JSONable {
    let source: String
    let datetime: String
    let image: String
    let headLine: String
    let summary: String
    let url: String

    required init(parameter: JSON) {
        source = parameter["source"].stringValue
        datetime = parameter["datetime"].stringValue
        image = parameter["image"].stringValue
        headLine = parameter["headline"].stringValue
        summary = parameter["summary"].stringValue
        url = parameter["url"].stringValue
    }
}

class DetailModel: ObservableObject {
    @Published var ticker: String = ""
    @Published var descriptionResult: Description? = nil
    @Published var latestPriceResult: LatestPrice? = nil
    @Published var peersResult: [peers] = []
    @Published var socialSentimentResult: SocialSentiments? = nil
    @Published var firstNews: news? = nil
    @Published var newsResult: [news] = []
    
    func getAPIData(tickerSymbol: String) {
        self.ticker = tickerSymbol
        GetSearchAPI(searchUrl: descriptionUrl + tickerSymbol).getDescription(callback: { stockDescription in
            self.descriptionResult = stockDescription
        })
        GetSearchAPI(searchUrl: latestPriceUrl + tickerSymbol).getLatestPrice(callback: { stockLatestPrice in
            self.latestPriceResult = stockLatestPrice
        })
        GetSearchAPI(searchUrl: peersUrl + tickerSymbol).getPeers(callback: { stockPeers in
            self.peersResult = stockPeers
        })
        GetSearchAPI(searchUrl: socialSentimentsUrl + tickerSymbol).getSocialSentiments(callback: { stockSocialSentiments in
            self.socialSentimentResult = stockSocialSentiments
        })
        GetSearchAPI(searchUrl: newsUrl + tickerSymbol).getNews(callback: { stockNews in
            self.firstNews = stockNews[0]
            self.newsResult = stockNews
            self.newsResult.remove(at: 0)
        })
    }
    
    func clearAPIData() {
        self.descriptionResult = nil
        self.latestPriceResult = nil
        self.peersResult = []
        self.socialSentimentResult = nil
        self.firstNews = nil
        self.newsResult = []
    }
}

struct FavoriteItem: Codable {
    let id = UUID()
    var ticker: String
    var company: String
    var cost: String
    var change: String
    var changePercent: String
}

struct PortfolioItem: Codable {
    let id = UUID()
    var ticker: String
    var shares: String
    var totalCost: String
    var marketValue: String
    var change: String
    var changePercent: String
}

struct DetailView: View {
    var ticker: String
    
    @EnvironmentObject var DetailM: DetailModel
    
    @State private var showingNewsSheet = false
    @State private var showingTradeSheet = false
    @State var showToast: Bool = false
    
    @AppStorage("myFavorite") var favoritesData: Data = Data()
    @AppStorage("myPortfolio") var PortfoliosData: Data = Data()
    
    var body: some View {
        if DetailM.descriptionResult == nil || DetailM.latestPriceResult == nil || DetailM.peersResult.isEmpty || DetailM.socialSentimentResult == nil || DetailM.firstNews == nil || DetailM.newsResult.isEmpty || ticker != DetailM.ticker {
            ProgressView("Fetching Data...")
                .onAppear {
                    DetailM.getAPIData(tickerSymbol: ticker)
                }
        } else {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(DetailM.descriptionResult!.name).foregroundColor(.gray)
                    KFImage(URL(string: DetailM.descriptionResult!.logo)!).resizable().frame(width: 50, height: 50).padding(.leading, 230)
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(DetailM.latestPriceResult!.c)").font(.system(size: 35)).fontWeight(.bold)
                    if (Float(DetailM.latestPriceResult!.d) ?? 0) < 0 {
                        Text("\(Image(systemName:"arrow.down.right")) $\(DetailM.latestPriceResult!.d) (\(DetailM.latestPriceResult!.dp)%)").font(.system(size: 22)).foregroundColor(.red).padding(.leading, 5)
                    } else {
                        Text("\(Image(systemName:"arrow.up.right")) $\(DetailM.latestPriceResult!.d) (\(DetailM.latestPriceResult!.dp)%)").font(.system(size: 22)).foregroundColor(.green).padding(.leading, 5)
                    }
                }
            }
            .navigationTitle(ticker)
            .navigationBarItems(trailing: Group {
                                    if var favorites = try? JSONDecoder().decode([FavoriteItem].self, from: favoritesData) {
                                        if let filtered = favorites.first { $0.ticker == ticker } {
                                            Button {
                                                favorites = favorites.filter { $0.ticker != ticker }
                                                guard let favoritesData = try? JSONEncoder().encode(favorites) else { return }
                                                self.favoritesData = favoritesData
                                            } label: {
                                                Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                                            }
                                        } else {
                                            Button {
                                                let favoriteItem = FavoriteItem(ticker: ticker, company: DetailM.descriptionResult!.name, cost: DetailM.latestPriceResult!.c, change: DetailM.latestPriceResult!.d, changePercent: DetailM.latestPriceResult!.dp)

                                                favorites.append(favoriteItem)
                                                guard let favoritesData = try? JSONEncoder().encode(favorites) else { return }
                                                self.favoritesData = favoritesData
                                            } label: {
                                                Image(systemName: "plus.circle").foregroundColor(.blue)
                                            }
                                        }
                                    } else {
                                        Button {
                                            let favoriteItem = FavoriteItem(ticker: ticker, company: DetailM.descriptionResult!.name, cost: DetailM.latestPriceResult!.c, change: DetailM.latestPriceResult!.d, changePercent: DetailM.latestPriceResult!.dp)
                                            
                                            let favorites = [favoriteItem]
                                            guard let favoritesData = try? JSONEncoder().encode(favorites) else { return }
                                            self.favoritesData = favoritesData
                                        } label: {
                                            Image(systemName: "plus.circle").foregroundColor(.blue)
                                        }
                                    }
            })
            
            TabView {
                if (Float(DetailM.latestPriceResult!.d) ?? 0) < 0 {
                    HourlyView(ticker: ticker, endTime: DetailM.latestPriceResult!.t, lineColor: "red")
                        .tabItem {
                            Label("Hourly", systemImage: "chart.xyaxis.line")
                        }
                } else {
                    HourlyView(ticker: ticker, endTime: DetailM.latestPriceResult!.t, lineColor: "green")
                        .tabItem {
                            Label("Hourly", systemImage: "chart.xyaxis.line")
                        }
                }
                
                HistoricalView(ticker: ticker)
                    .tabItem {
                        Label("Historical", systemImage: "clock.fill")
                    }
            }
            .frame(minHeight: 450)
            
            VStack {
                HStack {
                    Text("Portfolio").font(.system(size: 25)).padding(.leading, -180)
                }
                HStack {
                    VStack(alignment: .leading) {
                        if let portfolios = try? JSONDecoder().decode([PortfolioItem].self, from: PortfoliosData) {
                            if let filtered = portfolios.first { $0.ticker == ticker } {
                                HStack {
                                    Text("Shares Owned: ").font(.system(size: 14)).fontWeight(.bold)
                                    Text(String(format: "%.0f", Float(filtered.shares) ?? 0)).font(.system(size: 14))
                                }
                                HStack {
                                    Text("Avg.Cost / Share: ").font(.system(size: 14)).fontWeight(.bold)
                                    Text("$\(String(format: "%.2f", ((Float(filtered.totalCost) ?? 0) / (Float(filtered.shares) ?? 0))))").font(.system(size: 14))
                                }
                                .padding(.top, 5)
                                HStack {
                                    Text("Total Cost: ").font(.system(size: 14)).fontWeight(.bold)
                                    Text("$\(filtered.totalCost)").font(.system(size: 14))
                                }
                                .padding(.top, 5)
                                if Float(filtered.change) ?? 0 > 0 {
                                    HStack {
                                        Text("Change: ").font(.system(size: 14)).fontWeight(.bold)
                                        Text("$\(filtered.change)").font(.system(size: 14)).foregroundColor(.green)
                                    }
                                    .padding(.top, 5)
                                    HStack {
                                        Text("Market Value: ").font(.system(size: 14))
                                        Text("$\(filtered.marketValue)").font(.system(size: 14)).foregroundColor(.green)
                                    }
                                    .padding(.top, 5)
                                } else {
                                    if Float(filtered.change) ?? 0 < 0 {
                                        HStack {
                                            Text("Change: ").font(.system(size: 14)).fontWeight(.bold)
                                            Text("$\(filtered.change)").font(.system(size: 14)).foregroundColor(.red)
                                        }
                                        .padding(.top, 5)
                                        HStack {
                                            Text("Market Value: ").font(.system(size: 14)).fontWeight(.bold)
                                            Text("$\(filtered.marketValue)").font(.system(size: 14)).foregroundColor(.red)
                                        }
                                        .padding(.top, 5)
                                    } else {
                                        HStack {
                                            Text("Change: ").font(.system(size: 14)).fontWeight(.bold)
                                            Text("$\(filtered.change)").font(.system(size: 14))
                                        }
                                        .padding(.top, 5)
                                        HStack {
                                            Text("Market Value: ").font(.system(size: 14)).fontWeight(.bold)
                                            Text("$\(filtered.marketValue)").font(.system(size: 14))
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                            } else {
                                Text("You have 0 shares of \(ticker).").font(.system(size: 14))
                                Text("Start trading!").font(.system(size: 14))
                            }
                        } else {
                            Text("You have 0 shares of \(ticker).").font(.system(size: 14))
                            Text("Start trading!").font(.system(size: 14))
                        }
                    }
                    Button(action: {
                        showingTradeSheet.toggle()
                    }) {
                        Text("Trade")
                            .fontWeight(.bold)
                            .frame(minWidth: 115)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(40)
                    }
                    .padding(.leading, 25)
                    .sheet(isPresented: $showingTradeSheet) {
                        TradeSheetView(share: "", company: DetailM.descriptionResult!.name, price: DetailM.latestPriceResult!.c, ticker: ticker)
                    }
                }
            }
            
            VStack {
                HStack {
                    Text("Stats").font(.system(size: 25)).padding(.leading, -180)
                }
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("High Price: ").font(.system(size: 13)).fontWeight(.bold)
                            Text("\(DetailM.latestPriceResult!.h)").font(.system(size: 13))
                        }
                        HStack {
                            Text("Low Price: ").font(.system(size: 13)).fontWeight(.bold)
                            Text("\(DetailM.latestPriceResult!.l)").font(.system(size: 13))
                        }
                        .padding(.top, 5)
                    }
                    .padding(.leading, -70)
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Open Price: ").font(.system(size: 13)).fontWeight(.bold)
                            Text("\(DetailM.latestPriceResult!.o)").font(.system(size: 13))
                        }
                        HStack {
                            Text("Prev. Close: ").font(.system(size: 13)).fontWeight(.bold)
                            Text("\(DetailM.latestPriceResult!.pc)").font(.system(size: 13))
                        }
                        .padding(.top, 5)
                    }
                    .padding(.leading, 30)
                }
                .padding(.top, 5)
            }
            
            VStack {
                HStack {
                    Text("About").font(.system(size: 25)).padding(.leading, -180)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("IPO Start Date:").font(.system(size: 13)).fontWeight(.bold)
                        Text("Industry:").font(.system(size: 13)).fontWeight(.bold).padding(.top, 5)
                        Text("Webpage:").font(.system(size: 13)).fontWeight(.bold).padding(.top, 5)
                        Text("Company Peers:").font(.system(size: 13)).fontWeight(.bold).padding(.top, 5)
                    }
                    .padding(.leading, 15)
                    VStack(alignment: .leading) {
                        Text("\(DetailM.descriptionResult!.ipo)").font(.system(size: 13))
                        Text("\(DetailM.descriptionResult!.finnhubIndustry)").font(.system(size: 13)).padding(.top, 5)
                        Link("\(DetailM.descriptionResult!.weburl)", destination: URL(string: "\(DetailM.descriptionResult!.weburl)")!).font(.system(size: 13)).padding(.top, 5)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(DetailM.peersResult) { eachPeer in
                                    NavigationLink (destination: DetailView(ticker: eachPeer.peer)) {
                                        Text("\(eachPeer.peer),").font(.system(size: 13)).padding(.top, 5)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.leading, 50)
                }
                .padding(.top, 5)
            }
            .padding(.top, 7)
            
            VStack {
                HStack {
                    Text("Insights").font(.system(size: 25)).padding(.leading, -180)
                }
                HStack {
                    Text("Social Sentiments").font(.system(size: 25))
                }
                .padding(.top, 2)
                HStack {
                    VStack(alignment: .leading) {
                        Divider().frame(width: 120)
                        Text("\(DetailM.descriptionResult!.name)").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120)
                        Text("Total\nMentions").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120)
                        Text("Positive\nMentions").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120)
                        Text("Negative\nMentions").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120)
                    }
                    .padding(.leading, 15)
                    VStack(alignment: .leading) {
                        Divider().frame(width: 120)
                        Text("Reddit").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.redditM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.redditPM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.redditNM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9)
                    }
                    VStack(alignment: .leading) {
                        Divider().frame(width: 120)
                        Text("Twitter").font(.system(size: 18)).fontWeight(.bold)
                        Divider().frame(width: 120).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.twitterM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.twitterPM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9).padding(.bottom, 12)
                        Text("\(DetailM.socialSentimentResult!.twitterNM)").font(.system(size: 18))
                        Divider().frame(width: 120).padding(.top, 9)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.top, 7)
            
            RecommendationView(ticker: ticker).frame(minHeight: 400).padding(.top, 30)
            
            SurpriseView(ticker: ticker).frame(minHeight: 400).padding(.top, 5)
            
            VStack {
                HStack {
                    Text("News").font(.system(size: 25)).padding(.leading, -180)
                }
                Button(action: {
                    showingNewsSheet.toggle()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            KFImage(URL(string: DetailM.firstNews!.image)!).resizable().scaledToFit().cornerRadius(15).frame(width: 360)
                            Text("\(DetailM.firstNews!.source)  \(getTimeInterval(from: Double(DetailM.firstNews!.datetime) ?? 0))").font(.system(size: 13)).foregroundColor(.gray).padding(.leading, 5).padding(.top, 10)
                            Text("\(DetailM.firstNews!.headLine)").font(.system(size: 20)).fontWeight(.bold).foregroundColor(.black).frame(width: 360, alignment: .leading).padding(.top, 5).padding(.leading, 5)
                        }
                    }
                }
                .sheet(isPresented: $showingNewsSheet) {
                    NewsSheetView(targetNews: DetailM.firstNews!)
                }
                Divider().frame(width: 360)
                VStack {
                    ForEach(DetailM.newsResult) { eachNews in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(eachNews.source)  \(getTimeInterval(from: Double(eachNews.datetime) ?? 0))").font(.system(size: 13)).foregroundColor(.gray)
                                Text("\(eachNews.headLine)").font(.system(size: 17)).fontWeight(.bold).padding(.top, 5)
                            }
                            .frame(width: 230, alignment: .leading)
                            .padding(.leading, 10)
                            VStack {
                                KFImage(URL(string: eachNews.image)!).resizable().scaledToFill().frame(width: 100, height: 100, alignment: .center).clipped().cornerRadius(15)
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(ticker: "")
    }
}
