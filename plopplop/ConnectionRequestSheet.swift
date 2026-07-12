//
//  ConnectionRequestSheet.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//


import SwiftUI

struct ConnectionRequestSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject
    private var peerManager: PeerManager

    // MARK: - Body

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

// MARK: - View Builder

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

                Text("Verification Code")
                    .font(.headline)

                Text(request.pairingCode)
                    .font(.system(
                        size: 40,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            }

            Text("""
Verify that the six-digit code matches the code shown on the sender's device before accepting.
""")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {

                Button {

                    peerManager.acceptIncomingRequest()

                    dismiss()

                } label: {

                    Text("Accept")
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
