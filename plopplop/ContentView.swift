 //
//  ContentView.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SendView()
                .tabItem {
                    Label(
                        "Send",
                        systemImage: "paperplane"
                    )
                }
            ReceiveView()
                .tabItem {
                    Label(
                        "Receive",
                        systemImage: "tray"
                    )
                }
        }

    }

}
#Preview {
    ContentView()
}
