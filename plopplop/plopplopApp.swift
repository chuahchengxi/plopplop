//
//  plopplopApp.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//

import SwiftUI

@main
struct plopplopApp: App {
    @State private var manager = MultipeerManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
