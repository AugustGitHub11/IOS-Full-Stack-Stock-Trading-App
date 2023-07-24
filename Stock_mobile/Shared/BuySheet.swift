//
//  BuySheet.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 5/3/22.
//

import SwiftUI

struct BuySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var share: String
    var ticker: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Congratulations!").foregroundColor(.white).fontWeight(.bold).font(.system(size: 40))
            if share == "1" {
                Text("You have successfully bought \(share) share of \(ticker)").foregroundColor(.white).font(.system(size: 20)).multilineTextAlignment(.center).padding(.top, 10)
            } else {
                Text("You have successfully bought \(share) shares of \(ticker)").foregroundColor(.white).font(.system(size: 20)).multilineTextAlignment(.center).padding(.top, 10)
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .fontWeight(.bold)
                    .frame(minWidth: 320)
                    .padding()
                    .foregroundColor(.green)
                    .background(Color.white)
                    .cornerRadius(40)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.green)
    }
}

struct BuySheetView_Previews: PreviewProvider {
    static var previews: some View {
        BuySheetView(share: "", ticker: "")
    }
}
