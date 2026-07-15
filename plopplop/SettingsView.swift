//
//  SettingsView.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import SwiftUI
import SwiftData

struct SettingsView: View {

    @Query
    private var settings: [DeviceSettings]

    var body: some View {

        NavigationStack {

            Form {

                if let settings = settings.first {

                    Section("Profile") {

                        TextField(
                            "Nickname",
                            text: Bindable(settings).nickname
                        )
                    }

                    Section("Discovery") {

                        Toggle(
                            "Discoverable",
                            isOn: Bindable(settings).isDiscoverable
                        )
                    }
                }
            }

            .navigationTitle("Settings")
        }
    }
}