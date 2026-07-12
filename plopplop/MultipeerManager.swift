//
//  MultipeerManager.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import Foundation
import MultipeerConnectivity
import SwiftUI
import Combine

class MultipeerManager: NSObject, ObservableObject {
    @Published var receivedNote: Note?
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID] = []
    private let serviceType = "noteshare"
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    lazy var session: MCSession = {
        let session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        return session
    }()
    lazy var advertiser: MCNearbyServiceAdvertiser = {
        
        let advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        
        advertiser.delegate = self
        
        return advertiser
        
    }()
    
    
    lazy var browser: MCNearbyServiceBrowser = {
        
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
    }
    
    func send(note: Note) {
        
        guard !session.connectedPeers.isEmpty else {
            
            print("No connected peers.")
            return
            
        }
        
        do {
            
            let data = try JSONEncoder().encode(note)
            
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )
            
            print("Note sent!")
            
        }
        catch {
            
            print(error)
            
        }
        
    }
    var isConnected: Bool {
        !session.connectedPeers.isEmpty
    }
    
    var connectedDeviceNames: [String] {
        session.connectedPeers.map(\.displayName)
    }
    func connect(to peer: MCPeerID) {

        browser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 20
        )

    }
    
}
extension MultipeerManager: MCSessionDelegate,
                            MCNearbyServiceAdvertiserDelegate,
                            MCNearbyServiceBrowserDelegate {
    
    //MCSessionDelegate
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
        switch state {
        case .connected:
            print("✅ Connected to \(peerID.displayName)")
        case .connecting:
            print("🟡 Connecting to \(peerID.displayName)")
        case .notConnected:
            print("🔴 Disconnected from \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        
        do {
            
            let note = try JSONDecoder().decode(Note.self, from: data)
            
            DispatchQueue.main.async {
                
                self.receivedNote = note
                
            }
            
            print("Received note from \(peerID.displayName)")
            
        }
        catch {
            
            print(error)
            
        }
        
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
    }
    
    //advertiser
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("Invitation received from \(peerID.displayName)")
        
        invitationHandler(true, session)
        
    }
    //browser
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        
        if !discoveredPeers.contains(peerID) {
            
            DispatchQueue.main.async {
                
                self.discoveredPeers.append(peerID)
                
            }
            
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {

        DispatchQueue.main.async {

            self.discoveredPeers.removeAll {

                $0 == peerID

            }

        }

    }
}
