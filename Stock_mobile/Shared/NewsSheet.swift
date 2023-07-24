//
//  NewsSheet.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 5/1/22.
//

import SwiftUI

func formatDate() -> String {

        let date = NSDate()
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMMM dd, yyyy"

        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
}

func getDateFromTimeStamp(timeStamp : Double) -> String {

        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMMM dd, yyyy"

        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
}

func getTimeInterval(from: Double) -> String {
    let endDate = NSDate()
    let startDate = NSDate(timeIntervalSince1970: from)
    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate as Date, to: endDate as Date)
    let hours = diffComponents.hour
    let minutes = diffComponents.minute
    let intervalString = "\(hours!) hr, \(minutes!) min"
    return intervalString
}

struct NewsSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var targetNews: news 

    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }) {
                Text("\(Image(systemName:"xmark"))").foregroundColor(.black)
            }
            .padding(.top, 10)
            .padding(.leading, 360)
            
            VStack(alignment: .leading) {
                Text("\(targetNews.source)").font(.system(size: 30)).fontWeight(.bold)
                Text("\(getDateFromTimeStamp(timeStamp: Double(targetNews.datetime) ?? 0))").font(.system(size: 18)).foregroundColor(.gray)
            }
            .padding(.top, 20)
            .padding(.leading, -180)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("\(targetNews.headLine)").font(.system(size: 22)).fontWeight(.bold).frame(width: 360, alignment: .leading)
                Text("\(targetNews.summary)").font(.system(size: 15)).frame(width: 360, alignment: .leading)
                HStack {
                    Text("For more details click ").font(.system(size: 15)).foregroundColor(.gray)
                    Link("here", destination: URL(string: "\(targetNews.url)")!).font(.system(size: 15))
                }
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            
            HStack {
                Link(destination: URL(string: "https://twitter.com/intent/tweet?text=\(targetNews.headLine.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&url=\(targetNews.url)")!, label: {
                    Image("twitter").resizable().frame(width: 60, height: 60)
                })
                Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(targetNews.url)&src=sdkpreparse")!, label: {
                    Image("facebook").resizable().frame(width: 60, height: 60)
                })
            }
            .padding(.top, 10)
            .padding(.leading, -180)
            Spacer()
        }
    }
}

struct NewsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NewsSheetView(targetNews: news(parameter: ""))
    }
}
