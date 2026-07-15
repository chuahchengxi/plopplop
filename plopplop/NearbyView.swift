//
//  NearbyView.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import SwiftUI
import MultipeerConnectivity
struct NearbyView: View {

    @EnvironmentObject
    private var peerManager: PeerManager

    var body: some View {

        NavigationStack {

            List {

                Section("Connected") {

                    if peerManager.connectedPeers.isEmpty {

                        Text("No connected peers")
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
                        }
                    }
                }

                Section("Nearby") {

                    if peerManager.discoveredPeers.isEmpty {

                        Text("Searching...")
                            .foregroundStyle(.secondary)

                    } else {

                        ForEach(
                            peerManager.discoveredPeers,
                            id: \.self
                        ) { peer in

                            HStack {

                                Text(peer.displayName)

                                Spacer()

                                Button("Connect") {

                                    peerManager.invite(
                                        peer: peer
                                    )
                                }
                            }
                        }
                    }
                }
            }

            .navigationTitle("Nearby")
        }
    }
}
