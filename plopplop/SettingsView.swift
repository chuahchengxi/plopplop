//
//  SettingsView.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import SwiftUI
import MultipeerConnectivity

struct SettingsView: View {
    @FocusState
    private var nicknameFocused: Bool
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
                pairingSection

                connectedDevicesSection
                
                disconnectSection

            }
            .navigationTitle("Settings")
            .onAppear {

                nickname = settings.nickname

            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        nicknameFocused = false
                    }
                }
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
            .focused($nicknameFocused)
            .onSubmit {
                saveNickname()
            }

            Button("Save Nickname") {

                nicknameFocused = false

                print("🔥 Button pressed")

                saveNickname()

            }

        }

    }

    func saveNickname() {

        print("1️⃣ saveNickname() called")

        let trimmed = nickname
            .trimmingCharacters(in: .whitespacesAndNewlines)

        print("2️⃣ Trimmed:", trimmed)

        guard !trimmed.isEmpty else {
            print("❌ Empty nickname")
            return
        }

        settings.saveNickname(trimmed)

        print("3️⃣ settings.nickname =", settings.nickname)

        peerManager.refreshNickname()

        print("4️⃣ refreshNickname() finished")
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

    var pairingSection: some View {

        Group {

            if peerManager.isWaitingForPairing {

                Section("Waiting for Verification") {

                    VStack(spacing: 16) {

                        Text("Ask the other device to enter this code.")

                        Text(peerManager.currentPairingCode ?? "")
                            .font(.system(
                                size: 42,
                                weight: .bold,
                                design: .monospaced
                            ))

                        ProgressView()

                    }
                    .frame(maxWidth: .infinity)

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
            .disabled(peerManager.connectionStatus == "Disconnecting...")
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
