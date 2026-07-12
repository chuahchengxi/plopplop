//
//  SettingsView.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: DeviceSettings
    @EnvironmentObject private var peerManager: PeerManager
    @State private var nickname = ""
    @FocusState private var nicknameFocused: Bool
@State private var showingValidationAlert = false
    @State private var validationMessage = ""
    var body: some View {
        NavigationStack {
            Form {
                deviceSection
                informationSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .alert(
                "Unable to Save",
                isPresented: $showingValidationAlert
            ) {

                Button("OK") { }

            } message: {

                Text(validationMessage)

            }
            .onAppear {

                nickname = settings.nickname

            }

        }

    }

}
private extension SettingsView {

    var deviceSection: some View {

        Section("Device Nickname") {

            TextField(
                "Nickname",
                text: $nickname
            )
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)
            .focused($nicknameFocused)

            Text("""
This name is shown to nearby devices when discovering and sending notes.
""")
            .font(.footnote)
            .foregroundStyle(.secondary)

        }

    }

}

private extension SettingsView {

    var informationSection: some View {

        Section("Information") {

            LabeledContent(
                "Version",
                value: "1.0"
            )

            LabeledContent(
                "Nearby Sharing",
                value: "MultipeerConnectivity"
            )

            LabeledContent(
                "Storage",
                value: "Local JSON"
            )

        }

    }

}
private extension SettingsView {
    func save() {
        let trimmed = nickname.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmed.isEmpty else {
            validationMessage = "Please enter a nickname."
            showingValidationAlert = true
            return
        }
        guard trimmed.count <= 30 else {
            validationMessage = "Nickname must be 30 characters or fewer."
            showingValidationAlert = true
            return
        }
        settings.saveNickname(trimmed)
        peerManager.refreshNickname()
        dismiss()
    }
}
