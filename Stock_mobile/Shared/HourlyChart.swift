//
//  HourlyChart.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 4/16/22.
//

import SwiftUI
import UIKit
import WebKit

struct HourlyChartWebView: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    var ticker: String
    var endTime: String
    var lineColor: String

    func makeCoordinator() -> HourlyChartWebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.evaluateJavaScript("getHourlyChart('\(ticker)', '\(endTime)', '\(lineColor)');")
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: HourlyChartWebView

        init(_ parent: HourlyChartWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct HourlyView: View {
    @State var title: String = ""
    @State var error: Error? = nil
    
    var ticker: String
    var endTime: String
    var lineColor: String
    
    var body: some View {
        NavigationView {
            HourlyChartWebView(title: $title, url: Bundle.main.url(forResource: "HourlyChart", withExtension: "html")!, ticker: ticker, endTime: endTime, lineColor: lineColor)
                .onLoadStatusChanged { loading, error in
                    if loading {
                        print("Loading started")
                        self.title = "Loading…"
                    }
                    else {
                        print("Done loading.")
                        if let error = error {
                            self.error = error
                            if self.title.isEmpty {
                                self.title = "Error"
                            }
                        }
                        else if self.title.isEmpty {
                            self.title = "Some Place"
                        }
                    }
            }
            .navigationBarTitle(title)
            .navigationBarHidden(true)
        }
    }
}

struct HourlyView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyView(ticker: "", endTime: "", lineColor: "")
    }
}
