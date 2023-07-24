//
//  ContentView.swift
//  Shared
//
//  Created by August Chang on 4/9/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON

protocol JSONable {
    init?(parameter: JSON)
}

class stockSearch: Identifiable, JSONable {
    let description: String
    let symbol: String

    required init(parameter: JSON) {
        description = parameter["description"].stringValue
        symbol = parameter["symbol"].stringValue
    }
}

extension JSON {
    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []
                for obj in self.arrayValue {
                    let object = baseObj.init(parameter: obj)
                    arrObject.append(object!)
                }
                return arrObject
            } else {
                let object = baseObj.init(parameter: self)
                return object!
            }
        }
        return nil
    }
}

class searchModel: ObservableObject {
    let debouncer = Debouncer(delay: 1)
    
    var searchUrl: String
    var searchInstance: GetSearchAPI?
    
    @Published var userInput: String
    @Published var searchResult: [stockSearch] = []
    
    init() {
        userInput = ""
        searchUrl = "https://csci-hw8-server.wl.r.appspot.com/api/search/"
        searchInstance = nil
        searchResult = []
    }
}

struct money: Codable {
    var worth: String
    var balance: String
}

struct ContentView: View {
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @ObservedObject var searchM = searchModel()
    
    @StateObject var DetailM = DetailModel()
    
    @AppStorage("myFavorite") var favoritesData: Data = Data()
    @AppStorage("myPortfolio") var PortfoliosData: Data = Data()
    @AppStorage("myMoney") var MoneyData: Data = Data()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if !searchBar.text.isEmpty {
                        ForEach(searchM.searchResult) { eachStock in
                            NavigationLink (destination: DetailView(ticker: eachStock.symbol)){
                                VStack(alignment: .leading) {
                                    Text(eachStock.symbol).font(.system(size: 25)).fontWeight(.bold)
                                    Text(eachStock.description).foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    else {
                        Text("\(formatDate())").font(.system(size: 30)).fontWeight(.bold).foregroundColor(.gray)
                        
                        Section(header: Text("PORTFOLIO").font(.system(size: 15)).foregroundColor(.gray)){
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Net Worth").font(.system(size: 25))
                                    if let money = try? JSONDecoder().decode(money.self, from: MoneyData) {
                                        Text("$\(money.worth)").font(.system(size: 25)).fontWeight(.bold)
                                    } else {
                                        Text("$25000.00").font(.system(size: 25)).fontWeight(.bold)
                                    }
                                }
                                HStack {
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Cash Balance").font(.system(size: 25))
                                        if let money = try? JSONDecoder().decode(money.self, from: MoneyData) {
                                            Text("$\(money.balance)").font(.system(size: 25)).fontWeight(.bold)
                                        } else {
                                            Text("$25000.00").font(.system(size: 25)).fontWeight(.bold)
                                        }
                                    }
                                }
                            }
                            
                            if var portfolios = try? JSONDecoder().decode([PortfolioItem].self, from: PortfoliosData) {
                                ForEach(portfolios, id: \.id) { portfolio in
                                    NavigationLink (destination: DetailView(ticker: portfolio.ticker)){
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(portfolio.ticker).font(.system(size: 25)).fontWeight(.bold)
                                                Text("\(String(format: "%.0f", Float(portfolio.shares) ?? 0)) shares").foregroundColor(.gray)
                                            }
                                            HStack {
                                                Spacer()
                                                VStack(alignment: .trailing) {                                                Text("$\(portfolio.marketValue)").font(.system(size: 20)).fontWeight(.bold)
                                                    if (Float(portfolio.change) ?? 0) < 0 {
                                                        Text("\(Image(systemName:"arrow.down.right")) $\(portfolio.change) (\(portfolio.changePercent)%)").font(.system(size: 20)).foregroundColor(.red)
                                                    } else {
                                                        if (Float(portfolio.change) ?? 0) > 0 {
                                                            Text("\(Image(systemName:"arrow.up.right")) $\(portfolio.change) (\(portfolio.changePercent)%)").font(.system(size: 20)).foregroundColor(.green)
                                                        } else {
                                                            Text("-- $\(portfolio.change) (\(portfolio.changePercent)%)").font(.system(size: 20)).foregroundColor(.gray)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .onMove { from, to in
                                    portfolios.move(fromOffsets: from, toOffset: to)
                                    guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                                    self.PortfoliosData = PortfoliosData
                                }
                            }
                        }
                            
                        Section(header: Text("FAVORITES").font(.system(size: 15)).foregroundColor(.gray)){
                            if var favorites = try? JSONDecoder().decode([FavoriteItem].self, from: favoritesData) {
                                ForEach(favorites, id: \.id) { favorite in
                                    NavigationLink (destination: DetailView(ticker: favorite.ticker)){
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(favorite.ticker).font(.system(size: 25)).fontWeight(.bold)
                                                Text(favorite.company).foregroundColor(.gray)
                                            }
                                            HStack {
                                                Spacer()
                                                VStack(alignment: .trailing) {                                                Text("$\(favorite.cost)").font(.system(size: 20)).fontWeight(.bold)
                                                    if (Float(favorite.change) ?? 0) < 0 {
                                                        Text("\(Image(systemName:"arrow.down.right")) $\(favorite.change) (\(favorite.changePercent)%)").font(.system(size: 20)).foregroundColor(.red)
                                                    } else {
                                                        Text("\(Image(systemName:"arrow.up.right")) $\(favorite.change) (\(favorite.changePercent)%)").font(.system(size: 20)).foregroundColor(.green)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .onDelete { target in
                                    favorites.remove(atOffsets: target)
                                    guard let favoritesData = try? JSONEncoder().encode(favorites) else { return }
                                    self.favoritesData = favoritesData
                                }
                                .onMove { from, to in
                                    favorites.move(fromOffsets: from, toOffset: to)
                                    guard let favoritesData = try? JSONEncoder().encode(favorites) else { return }
                                    self.favoritesData = favoritesData
                                }
                            }
                        }
                        
                        Link("                    Powered by Finnhub.io", destination: URL(string: "https://finnhub.io")!).font(.system(size: 15)).foregroundColor(.gray)
                    }
                }
                .toolbar {
                    EditButton()
                }
            }
            .navigationBarTitle("Stocks")
            .add(self.searchBar)
            .onChange(of: searchBar.text) { _ in
                if !searchBar.text.isEmpty {
                    searchM.debouncer.run(action: {
                        searchM.userInput = searchBar.text
                        searchM.searchUrl = "https://csci-hw8-server.wl.r.appspot.com/api/search/\(searchM.userInput)"
                        searchM.searchInstance = GetSearchAPI(searchUrl: searchM.searchUrl)
                        searchM.searchInstance?.getSearch(callback: { stockCandidates in
                            searchM.searchResult = stockCandidates
                        })
                    })
                }
            }
        }
        .environmentObject(DetailM)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
