//
//  SendView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI
import SwiftData

struct RootView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var peerManager: PeerManager
    @Query private var settings: [DeviceSettings]
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "house"
                    )
                }
            DraftView()
                .tabItem {
                    Label(
                        "Draft",
                        systemImage: "square.and.pencil"
                    )
                }
            NearbyView()
                .tabItem {
                    Label(
                        "Nearby",
                        systemImage: "person.2"
                    )
                }
            SettingsView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: "gear"
                    )
                }
            CanvasTestView()
                .tabItem{
                    Label("Test",systemImage: "gear")
                }
        }

        .task {

            setup()
        }
    }
    private func setup() {
        if settings.isEmpty {
            let settings = DeviceSettings()
            modelContext.insert(settings)
        }
        peerManager.configure(
            modelContext: modelContext
        )
        peerManager.start()
    }
}
