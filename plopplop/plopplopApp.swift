//
//  plopplopApp.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import SwiftUI

@main
struct plopplopApp: App {

    @StateObject
    private var deviceSettings = DeviceSettings()
    @StateObject
    private var notesStore = NotesStore()
    @StateObject
    private var peerManager: PeerManager
//Initialise the settings

    init() {

        let settings = DeviceSettings()
        let store = NotesStore()

        _deviceSettings = StateObject(
            wrappedValue: settings
        )

        _notesStore = StateObject(
            wrappedValue: store
        )

        _peerManager = StateObject(
            wrappedValue: PeerManager(
                settings: settings,
                notesStore: store
            )
        )

    }


    var body: some Scene {

        WindowGroup {

            ContentView()
                .environmentObject(deviceSettings)
                .environmentObject(notesStore)
                .environmentObject(peerManager)

        }

    }

}
