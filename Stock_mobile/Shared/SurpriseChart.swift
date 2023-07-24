//
//  SurpriseChart.swift
//  Stock_mobile (iOS)
//
//  Created by August Chang on 4/22/22.
//

import SwiftUI
import UIKit
import WebKit

struct SurpriseChartWebView: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    var ticker: String

    func makeCoordinator() -> SurpriseChartWebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.evaluateJavaScript("getSurpriseChart('\(ticker)');")
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: SurpriseChartWebView

        init(_ parent: SurpriseChartWebView) {
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

struct SurpriseView: View {
    @State var title: String = ""
    @State var error: Error? = nil
    
    var ticker: String
    
    var body: some View {
        NavigationView {
            SurpriseChartWebView(title: $title, url: Bundle.main.url(forResource: "SurpriseChart", withExtension: "html")!, ticker: ticker)
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

struct SurpriseView_Previews: PreviewProvider {
    static var previews: some View {
        SurpriseView(ticker: "")
    }
}

