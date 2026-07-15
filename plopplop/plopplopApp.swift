//
//  plopplopApp.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import SwiftUI
import SwiftData

@main
struct PlopPlopApp: App {
    @StateObject private var peerManager = PeerManager()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(peerManager)
        }
        .modelContainer(
            for: [
                Draft.self,
                DeviceSettings.self,
                PeerRecord.self,
                ChatMessage.self
            ]
        )
    }
}
