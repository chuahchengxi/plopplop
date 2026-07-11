//
//  MultipeerManager.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//


import MultipeerConnectivity
import SwiftUI
import Combine

class MultipeerManager: NSObject, ObservableObject {
    
    @Published var receivedNote: Note?
    
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    
    lazy var session = MCSession(
        peer: peerID,
        securityIdentity: nil,
        encryptionPreference: .required
    )
    
    lazy var advertiser = MCNearbyServiceAdvertiser(
        peer: peerID,
        discoveryInfo: nil,
        serviceType: "studentapp"
    )
    
    lazy var browser = MCNearbyServiceBrowser(
        peer: peerID,
        serviceType: "studentapp"
    )
    func send(note: Note) {
        
        do {
            let data = try JSONEncoder().encode(note)
            
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )
        } catch {
            print(error)
        }
    }
}
