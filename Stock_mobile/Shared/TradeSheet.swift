//
//  TradeSheet.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 5/3/22.
//

import SwiftUI

struct TradeSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var share: String = ""
    @State private var showingBuySheet = false
    @State private var showingSellSheet = false
    
    var company: String
    var price: String
    var ticker: String
    
    @AppStorage("myPortfolio") var PortfoliosData: Data = Data()
    @AppStorage("myMoney") var MoneyData: Data = Data()
    
    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }) {
                Text("\(Image(systemName:"xmark"))").foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.leading, 360)
            
            Text("Trade \(company) shares").fontWeight(.bold).padding(.top, 10)
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline) {
                TextField("0", text: $share).font(.system(size: 100)).padding(.leading, 10).keyboardType(.numberPad)
                if share == "" || share == "1" {
                    Text("Share").font(.system(size: 50)).padding(.trailing, 10)
                } else {
                    Text("Shares").font(.system(size: 50)).padding(.trailing, 10)
                }
            }
            HStack {
                Spacer()
                Text("x $\(price)/share = $\(String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0))))").font(.system(size: 25)).padding(.trailing, 10)
            }
            
            Spacer()
            
            if let money = try? JSONDecoder().decode(money.self, from: MoneyData) {
                Text("$\(money.balance) available to buy \(ticker)").font(.system(size: 15)).foregroundColor(.gray)
            } else {
                Text("$25000.00 available to buy \(ticker)").font(.system(size: 15)).foregroundColor(.gray)
            }
                
            HStack {
                Button(action: {
                    if var portfolios = try? JSONDecoder().decode([PortfolioItem].self, from: PortfoliosData) {
                        let Money = try? JSONDecoder().decode(money.self, from: MoneyData)
                            
                        if let filtered = portfolios.first(where: { $0.ticker == ticker }) {
                            let newShares = String(format: "%.2f", ((Float(share) ?? 0) + (Float(filtered.shares) ?? 0)))
                            let newTotalCost = String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0) + (Float(filtered.totalCost) ?? 0)))
                            let newMarketValue = String(format: "%.2f", ((Float(newShares) ?? 0) * (Float(price) ?? 0)))
                            let newChange = String(format: "%.2f", ((Float(newMarketValue) ?? 0) - (Float(newTotalCost) ?? 0)))
                            let newChangePercent = String(format: "%.2f", ((Float(newChange) ?? 0) / (Float(newTotalCost) ?? 0) * 100))
                            let newBalance = String(format: "%.2f", ((Float(Money!.balance) ?? 0) - (Float(share) ?? 0) * (Float(price) ?? 0)))
                            let newWorth = String(format: "%.2f", ((Float(newBalance) ?? 0) + (Float(newMarketValue) ?? 0)))
                            
                            let portfolioItem = PortfolioItem(ticker: ticker, shares: newShares, totalCost: newTotalCost, marketValue: newMarketValue, change: newChange, changePercent: newChangePercent)
                            let moneyItem = money(worth: newWorth, balance: newBalance)
                            
                            portfolios = portfolios.filter { $0.ticker != ticker }
                            portfolios.append(portfolioItem)
                            guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                            self.PortfoliosData = PortfoliosData
                            guard let MoneyData = try? JSONEncoder().encode(moneyItem) else { return }
                            self.MoneyData = MoneyData
                        } else {
                            let portfolioItem = PortfolioItem(ticker: ticker, shares: share, totalCost: String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0))), marketValue: String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0))), change: "0.00", changePercent: "0.00")
                            let newBalance = String(format: "%.2f", ((Float(Money?.balance ?? "25000.00") ?? 0) - (Float(share) ?? 0) * (Float(price) ?? 0)))
                            let newWorth = String(format: "%.2f", ((Float(newBalance) ?? 0) + (Float(share) ?? 0) * (Float(price) ?? 0)))
                            let moneyItem = money(worth: newWorth, balance: newBalance)
                            
                            portfolios.append(portfolioItem)
                            guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                            self.PortfoliosData = PortfoliosData
                            guard let MoneyData = try? JSONEncoder().encode(moneyItem) else { return }
                            self.MoneyData = MoneyData
                        }
                    } else {
                        let portfolioItem = PortfolioItem(ticker: ticker, shares: share, totalCost: String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0))), marketValue: String(format: "%.2f", ((Float(share) ?? 0) * (Float(price) ?? 0))), change: "0.00", changePercent: "0.00")
                        let newBalance = String(format: "%.2f", (25000.00 - (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let newWorth = String(format: "%.2f", ((Float(newBalance) ?? 0) + (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let moneyItem = money(worth: newWorth, balance: newBalance)
                        
                        let portfolios = [portfolioItem]
                        guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                        self.PortfoliosData = PortfoliosData
                        guard let MoneyData = try? JSONEncoder().encode(moneyItem) else { return }
                        self.MoneyData = MoneyData
                    }
                    
                    showingBuySheet.toggle()
                }) {
                    Text("Buy")
                        .fontWeight(.bold)
                        .frame(minWidth: 150)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(40)
                }
                .sheet(isPresented: $showingBuySheet) {
                    BuySheetView(share: share, ticker: ticker)
                }
                Button(action: {
                    var portfolios = try? JSONDecoder().decode([PortfolioItem].self, from: PortfoliosData)
                    let Money = try? JSONDecoder().decode(money.self, from: MoneyData)
                    let filtered = portfolios!.first(where: { $0.ticker == ticker })
                    if Float(filtered!.shares) ?? 0 == Float(share) ?? 0 {
                        let newBalance = String(format: "%.2f", ((Float(Money!.balance) ?? 0) + (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let newWorth = String(format: "%.2f", ((Float(newBalance) ?? 0) - (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let moneyItem = money(worth: newWorth, balance: newBalance)
                        
                        portfolios = portfolios!.filter { $0.ticker != ticker }
                        guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                        self.PortfoliosData = PortfoliosData
                        guard let MoneyData = try? JSONEncoder().encode(moneyItem) else { return }
                        self.MoneyData = MoneyData
                    } else {
                        let newShares = String(format: "%.2f", ((Float(filtered!.shares) ?? 0) - (Float(share) ?? 0)))
                        let newTotalCost = String(format: "%.2f", ((Float(filtered!.totalCost) ?? 0) - (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let newMarketValue = String(format: "%.2f", ((Float(newShares) ?? 0) * (Float(price) ?? 0)))
                        let newChange = String(format: "%.2f", ((Float(newMarketValue) ?? 0) - (Float(newTotalCost) ?? 0)))
                        let newChangePercent = String(format: "%.2f", ((Float(newChange) ?? 0) / (Float(newTotalCost) ?? 0) * 100))
                        let newBalance = String(format: "%.2f", ((Float(Money!.balance) ?? 0) + (Float(share) ?? 0) * (Float(price) ?? 0)))
                        let newWorth = String(format: "%.2f", ((Float(newBalance) ?? 0) - (Float(share) ?? 0) * (Float(price) ?? 0)))
                        
                        let portfolioItem = PortfolioItem(ticker: ticker, shares: newShares, totalCost: newTotalCost, marketValue: newMarketValue, change: newChange, changePercent: newChangePercent)
                        let moneyItem = money(worth: newWorth, balance: newBalance)
                        
                        portfolios = portfolios!.filter { $0.ticker != ticker }
                        portfolios!.append(portfolioItem)
                        guard let PortfoliosData = try? JSONEncoder().encode(portfolios) else { return }
                        self.PortfoliosData = PortfoliosData
                        guard let MoneyData = try? JSONEncoder().encode(moneyItem) else { return }
                        self.MoneyData = MoneyData
                    }
                    
                    showingSellSheet.toggle()
                }) {
                    Text("Sell")
                        .fontWeight(.bold)
                        .frame(minWidth: 150)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(40)
                }
                .sheet(isPresented: $showingSellSheet) {
                    SellSheetView(share: share, ticker: ticker)
                }
            }
        }
    }
}

struct TradeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TradeSheetView(share: "", company: "", price: "", ticker: "")
    }
}
