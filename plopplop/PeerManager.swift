//
//  MultipeerManager.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import Foundation
import MultipeerConnectivity
import SwiftData
import Combine

@MainActor
final class PeerManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    }
    

    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published private(set) var discoveredPeers: [MCPeerID] = []

    private let serviceType = "plopplop"

    private let myPeerID: MCPeerID

    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    private var modelContext: ModelContext?

    override init() {

        let peerID = MCPeerID(
            displayName: UIDevice.current.name
        )

        self.myPeerID = peerID

        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        self.advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )

        self.browser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: serviceType
        )

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func configure(
        modelContext: ModelContext
    ) {
        self.modelContext = modelContext
    }

    func start() {

        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func stop() {

        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()

        session.disconnect()
    }

    func invite(
        peer: MCPeerID
    ) {

        browser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 30
        )
    }

    func send(
        payload: PeerPayload
    ) {

        guard !session.connectedPeers.isEmpty else {
            return
        }

        do {

            let data = try JSONEncoder().encode(payload)

            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )

        } catch {

            print("Failed to send data:", error)
        }
    }

    private func receive(
        data: Data
    ) {

        do {

            let payload = try JSONDecoder().decode(
                PeerPayload.self,
                from: data
            )

            handle(payload)

        } catch {

            print("Failed to decode payload:", error)
        }
    }

    private func handle(
        _ payload: PeerPayload
    ) {

        guard let modelContext else {
            return
        }

        switch payload {

        case .intro(let nickname):

            let message = ChatMessage(
                text: "Hello from \(nickname)",
                senderNickname: nickname,
                direction: .received
            )

            modelContext.insert(message)

        case .draft(
            let id,
            let title,
            let body
        ):

            let descriptor = FetchDescriptor<Draft>(
                predicate: #Predicate {
                    $0.id == id
                }
            )

            do {

                let existingDrafts = try modelContext.fetch(
                    descriptor
                )

                if let draft = existingDrafts.first {

                    draft.title = title
                    draft.body = body
                    draft.updatedAt = Date()

                } else {

                    let draft = Draft(
                        title: title,
                        body: body
                    )

                    modelContext.insert(draft)
                }

                try modelContext.save()

            } catch {

                print(
                    "Failed to save received draft:",
                    error
                )
            }

        case .message(
            let text,
            let senderNickname
        ):

            let message = ChatMessage(
                text: text,
                senderNickname: senderNickname,
                direction: .received
            )

            modelContext.insert(message)

            do {

                try modelContext.save()

            } catch {

                print(
                    "Failed to save message:",
                    error
                )
            }
        }
    }
}
extension PeerManager: MCSessionDelegate {

    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {

        Task { @MainActor in

            self.connectedPeers = session.connectedPeers
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {

        Task { @MainActor in

            self.receive(data: data)
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
    }

    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
    }

    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
    }
}
extension PeerManager: MCNearbyServiceBrowserDelegate {

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {

        Task { @MainActor in

            if !self.discoveredPeers.contains(peerID) {

                self.discoveredPeers.append(peerID)
            }
        }
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {

        Task { @MainActor in

            self.discoveredPeers.removeAll {
                $0 == peerID
            }
        }
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {

        print(
            "Browsing failed:",
            error
        )
    }
}
