//
//  ConnectionRequestSheet.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//


import SwiftUI

struct ConnectionRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var peerManager: PeerManager
    @State private var enteredCode = ""

    @State private var incorrectCode = false

    var body: some View {

        NavigationStack {

            Group {

                if let request = peerManager.incomingRequest {

                    requestView(request)

                } else {

                    ContentUnavailableView(
                        "No Connection Request",
                        systemImage: "wifi.slash",
                        description: Text(
                            "There are currently no incoming pairing requests."
                        )
                    )

                }

            }
            .navigationTitle("Connection Request")
            .navigationBarTitleDisplayMode(.inline)

        }

    }

}

private extension ConnectionRequestSheet {

    @ViewBuilder
    func requestView(
        _ request: ConnectionRequest
    ) -> some View {

        VStack(spacing: 32) {

            Spacer()

            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {

                Text(request.nickname)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("wants to connect to this device.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

            }
            VStack(spacing: 12) {

                Text("Enter Verification Code")
                    .font(.headline)

                TextField(
                    "123456",
                    text: $enteredCode
                )
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)

                if incorrectCode {

                    Text("Incorrect pairing code")
                        .foregroundStyle(.red)
                        .font(.caption)

                }

            }

            Text("""
Enter the six-digit code displayed on the sender's device.
""")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {

                Button {

                    if enteredCode == request.pairingCode {

                        peerManager.acceptIncomingRequest()

                        dismiss()

                    } else {

                        incorrectCode = true

                    }

                } label: {

                    Text("Verify")
                        .frame(maxWidth: .infinity)

                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(role: .destructive) {

                    peerManager.declineIncomingRequest()

                    dismiss()

                } label: {

                    Text("Decline")
                        .frame(maxWidth: .infinity)

                }
                .buttonStyle(.bordered)

            }

        }
        .padding()

    }

}
