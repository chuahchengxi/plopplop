//
//  MultipeerManager.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import Foundation
import Combine
import MultipeerConnectivity
import UIKit

class MultipeerManager: NSObject, ObservableObject {
    @Published var receivedNote: Note?
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID] = []

    private let serviceType = "noteshare"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)

    private lazy var session: MCSession = {
        let session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        return session
    }()

    private lazy var advertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser.delegate = self
        return advertiser
    }()

    private lazy var browser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )
        browser.delegate = self
        return browser
    }()

    override init() {
        super.init()
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    func connect(to peer: MCPeerID) {
        browser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 20
        )
    }

    func send(note: Note) {
        guard !session.connectedPeers.isEmpty else {
            return
        }

        do {
            let data = try JSONEncoder().encode(note)
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )
        } catch {
            print("MultipeerManager: send failed —", error)
        }
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        guard let note = try? JSONDecoder().decode(Note.self, from: data) else {
            return
        }

        DispatchQueue.main.async {
            self.receivedNote = note
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
        }
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }
}
