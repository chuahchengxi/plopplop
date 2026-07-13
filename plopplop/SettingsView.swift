//
//  SettingsView.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import SwiftUI
import MultipeerConnectivity

struct SettingsView: View {

    @EnvironmentObject
    private var settings: DeviceSettings

    @EnvironmentObject
    private var peerManager: PeerManager

    @State
    private var nickname: String = ""

    var body: some View {

        NavigationStack {

            Form {

                profileSection

                connectionStatusSection

                nearbyDevicesSection

                connectedDevicesSection

                disconnectSection

            }
            .navigationTitle("Settings")
            .onAppear {

                nickname = settings.nickname

            }

        }

    }

}

private extension SettingsView {
    var profileSection: some View {
        Section("Profile") {
            TextField(
                "Nickname",
                text: $nickname
            )
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)
            .onSubmit {
                saveNickname()
            }

            Button("Save Nickname") {

                saveNickname()

            }

        }

    }

    func saveNickname() {

        let trimmed = nickname
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmed.isEmpty else {
            return
        }

        settings.saveNickname(trimmed)

        peerManager.refreshNickname()

    }

}
private extension SettingsView {

    var connectionStatusSection: some View {

        Section("Connection") {

            HStack {

                Text("Status")

                Spacer()

                Text(peerManager.connectionStatus)
                    .foregroundStyle(
                        peerManager.isConnected
                        ? .green
                        : .red
                    )

            }

            HStack {

                Text("Connected Devices")

                Spacer()

                Text("\(peerManager.peerCount)")

            }

        }

    }

}

// MARK: - Nearby Devices

private extension SettingsView {

    var nearbyDevicesSection: some View {

        Section("Nearby Devices") {

            if peerManager.nearbyPeers.isEmpty {

                ContentUnavailableView(
                    "No Nearby Devices",
                    systemImage: "antenna.radiowaves.left.and.right"
                )

            } else {

                ForEach(
                    peerManager.nearbyPeers,
                    id: \.self
                ) { peer in

                    HStack {

                        VStack(
                            alignment: .leading
                        ) {

                            Text(peer.displayName)

                            Text("Available")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        }

                        Spacer()

                        Button("Connect") {

                            peerManager.connect(
                                to: peer
                            )

                        }
                        .buttonStyle(.borderedProminent)

                    }

                }

            }

        }

    }

}


private extension SettingsView {

    var connectedDevicesSection: some View {

        Section("Connected Devices") {

            if peerManager.connectedPeers.isEmpty {

                Text("No connected devices.")
                    .foregroundStyle(.secondary)

            } else {

                ForEach(
                    peerManager.connectedPeers,
                    id: \.self
                ) { peer in

                    Label(
                        peer.displayName,
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)

                }

            }

        }

    }

}

private extension SettingsView {

    var disconnectSection: some View {

        Section {

            Button(
                role: .destructive
            ) {

                peerManager.disconnectAndReset()

            } label: {

                HStack {

                    Spacer()

                    Label(
                        "Disconnect",
                        systemImage: "wifi.slash"
                    )
                    .foregroundStyle(.red)
                    Spacer()

                }

            }
            .disabled(
                !peerManager.isConnected
            )

        }

    }

}

#Preview {

    SettingsView()
        .environmentObject(DeviceSettings())
        .environmentObject(NotesStore())
        .environmentObject(
            PeerManager(
                settings: DeviceSettings(),
                notesStore: NotesStore()
            )
        )

}
