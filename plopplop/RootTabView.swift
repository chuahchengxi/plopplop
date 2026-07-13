//
//  RootTabView.swift
//  plopplop
//
//  Created by cheng xi on 13/7/26.
//
import SwiftUI
struct RootTabView: View {
    var body: some View {
        TabView {

            NotesView()
                .tabItem {
                    Label(
                        "Notes",
                        systemImage: "note.text"
                    )
                }
            SettingsView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: "gearshape.fill"
                    )
                }
        }
    }
}


#Preview {
    RootTabView()
        .environmentObject(DeviceSettings())
        .environmentObject(NotesStore())
        .environmentObject(
            PeerManager(
                settings: DeviceSettings(),
                notesStore: NotesStore()
            )
        )
}
