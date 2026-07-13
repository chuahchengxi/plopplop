//
//  MultipeerManager.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import Foundation
import SwiftUI
import MultipeerConnectivity
import Combine
@MainActor
final class PeerManager: NSObject, ObservableObject {
    private static let serviceType = "plopplop"
    private let settings: DeviceSettings
    private let notesStore: NotesStore
    private(set) var peerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    @Published private(set) var nearbyPeers: [MCPeerID] = []
    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published var incomingRequest: ConnectionRequest?
    @Published private(set) var isAdvertising = false
    @Published private(set) var isBrowsing = false
    @Published private(set) var lastError: String?
    @Published private(set) var connectionStatus: String = "Not Connected"
    @Published var showingConnectionRequest = false
    @Published var currentPairingCode: String?
    @Published var isWaitingForPairing = false
    private var invitationTimeoutTask: Task<Void, Never>?
    init(
        settings: DeviceSettings,
        notesStore: NotesStore
    ) {
        
        self.settings = settings
        self.notesStore = notesStore
        
        let displayName = settings.hasNickname
            ? settings.nickname
            : "Unnamed Device"

        self.peerID = MCPeerID(
            displayName: displayName
        )
        super.init()
        
        configureSession()
        
        startAdvertising()
        
        startBrowsing()
        
    }
    
    deinit {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        invitationTimeoutTask?.cancel()
        session.disconnect()
    }
    //Configure the settings
    
    private func configureSession() {
        
        session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        
        session.delegate = self
        
    }
    //Refresh nickname
    func refreshNickname() {
        
        advertiser?.stopAdvertisingPeer()
        
        browser?.stopBrowsingForPeers()
        
        session.disconnect()
        
        peerID = MCPeerID(
            displayName: settings.nickname
        )
        
        configureSession()
        
        startAdvertising()
        
        startBrowsing()
        
    }
    //Advertising lol -> help to see whether the device want to connect
    
    func startAdvertising() {
        
        guard !isAdvertising else {
            return
        }
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: Self.serviceType
        )
        
        advertiser?.delegate = self
        
        advertiser?.startAdvertisingPeer()
        print("✅ Advertising started")
        isAdvertising = true
        
    }
    
    func stopAdvertising() {
        
        advertiser?.stopAdvertisingPeer()
        
        advertiser = nil
        
        isAdvertising = false
        
    }
    //Browsing -> search for devices with the same type
    
    func startBrowsing() {
        
        guard !isBrowsing else {
            return
        }
        
        browser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: Self.serviceType
        )
        
        browser?.delegate = self
        
        browser?.startBrowsingForPeers()
        
        isBrowsing = true
        
    }
    
    func stopBrowsing() {
        
        browser?.stopBrowsingForPeers()
        
        browser = nil
        print("✅ Browsing started")
        nearbyPeers.removeAll()
        
        isBrowsing = false
        
    }
    
    //Discover nearby devices
    
    private func addNearbyPeer(_ peer: MCPeerID) {
        
        guard peer != peerID else {
            return
        }
        
        guard !nearbyPeers.contains(peer) else {
            return
        }
        
        nearbyPeers.append(peer)
        
        nearbyPeers.sort {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
        
    }
    
    private func removeNearbyPeer(_ peer: MCPeerID) {
        
        nearbyPeers.removeAll {
            $0 == peer
        }
        
    }
    //Connection
    
    func connect(
        to peer: MCPeerID
    ) {
        
        let code = Self.generatePairingCode()

        currentPairingCode = code
        isWaitingForPairing = true

        let context = InvitationContext(
            nickname: settings.nickname,
            pairingCode: code
        )
        
        do {
            
            let data = try JSONEncoder().encode(context)
            
            browser?.invitePeer(
                peer,
                to: session,
                withContext: data,
                timeout: 30
            )
            
        } catch {
            
            reportError(error)
            
        }
        
    }
    
    func disconnect() {
        
        session.disconnect()
        
        connectedPeers.removeAll()
        
        connectionStatus = "Disconnected"
        
    }
    
    //Send notes
    
    func send(note: Note) {
        
        guard !session.connectedPeers.isEmpty else {
            return
        }
        
        do {
            
            let packet = try TransferPacket(
                type: .note,
                value: note
            )
            
            let data = try packet.encoded()
            
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )
            
        } catch {
            
            reportError(error)
            
        }
        
    }
    
    //Just sending generic pacets
    
    func sendPacket<T: Codable>(
        _ value: T,
        type: PacketType
    ) {
        
        guard !session.connectedPeers.isEmpty else {
            return
        }
        
        do {
            
            let packet = try TransferPacket(
                type: type,
                value: value
            )
            
            let data = try packet.encoded()
            
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .reliable
            )
            
        } catch {
            
            reportError(error)
            
        }
        
    }
    func clearError() {
        lastError = nil
    }
}

//Different Helpers

private struct InvitationContext: Codable {
    
    let nickname: String
    
    let pairingCode: String
    
}


private extension PeerManager {
    
    static func generatePairingCode() -> String {
        
        String(
            format: "%06d",
            Int.random(in: 0...999999)
        )
        
    }
    
}

extension PeerManager: MCNearbyServiceAdvertiserDelegate {
    
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        
        Task { @MainActor in
            
            guard let context else {
                
                invitationHandler(false, nil)
                
                return
                
            }
            
            do {
                
                let invitation = try JSONDecoder().decode(
                    InvitationContext.self,
                    from: context
                )
                
                self.incomingRequest = ConnectionRequest(
                    peer: peerID,
                    nickname: invitation.nickname,
                    pairingCode: invitation.pairingCode,
                    invitationHandler: invitationHandler
                )

                self.showingConnectionRequest = true
                self.startInvitationTimeout()
                
            } catch {
                
                invitationHandler(false, nil)
                
            }
            
        }
        
    }
    
}


extension PeerManager: MCNearbyServiceBrowserDelegate {
    
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        print("✅ FOUND:", peerID.displayName)

        Task { @MainActor in
            self.addNearbyPeer(peerID)
        }
    }
    
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        
        Task { @MainActor in
            
            self.removeNearbyPeer(peerID)
            
        }
        
    }
    
}

//Handles incoming requests from other Peers

extension PeerManager {
    
    func acceptIncomingRequest() {
        
        guard let request = incomingRequest else {
            return
        }
        
        invitationTimeoutTask?.cancel()
        
        request.invitationHandler(
            true,
            session
        )
        connectionStatus = "Connecting..."
        incomingRequest = nil
        showingConnectionRequest = false
        
    }
    
    func declineIncomingRequest() {
        
        guard let request = incomingRequest else {
            return
        }
        
        invitationTimeoutTask?.cancel()
        
        request.invitationHandler(
            false,
            nil
        )
        connectionStatus = "Invitation Declined"
        incomingRequest = nil
        showingConnectionRequest = false
    }
}

//Timeout from requests

private extension PeerManager {
    
    func startInvitationTimeout() {
        
        invitationTimeoutTask?.cancel()
        
        invitationTimeoutTask = Task {
            
            try? await Task.sleep(
                for: .seconds(30)
            )
            
            guard !Task.isCancelled else {
                return
            }
            
            guard let request = incomingRequest else {
                return
            }
            
            request.invitationHandler(
                false,
                nil
            )
            
            incomingRequest = nil
            showingConnectionRequest = false
        }
        
    }
}
//MCSessionDelegate

extension PeerManager: MCSessionDelegate {
    
    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        
        Task { @MainActor in
            
            switch state {
                
            case .connected:

                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }

                self.connectionStatus = "Connected"

                // Pairing finished successfully
                self.currentPairingCode = nil
                self.isWaitingForPairing = false
                
            case .connecting:
                
                self.connectionStatus = "Connecting..."
                
            case .notConnected:

                self.connectedPeers.removeAll {
                    $0 == peerID
                }

                if self.connectedPeers.isEmpty {
                    self.connectionStatus = "Not Connected"

                    // Reset pairing state
                    self.currentPairingCode = nil
                    self.isWaitingForPairing = false
                }
                
            @unknown default:
                
                break
                
            }
            
        }
        
    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        
        Task { @MainActor in
            
            self.handleIncomingData(data)
            
        }
        
    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // Streams are intentionally not used.
    }
    
    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // Resources are intentionally not used.
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
//Handles the packets lol

private extension PeerManager {
    
    func handleIncomingData(
        _ data: Data
    ) {
        
        do {
            
            let packet = try TransferPacket.decode(
                from: data
            )
            
            switch packet.type {
                
            case .note:
                
                let note: Note = try packet.decodePayload()
                
                receive(note)
                
            case .ping:
                
                break
                
            case .disconnect:
                
                connectedPeers.removeAll()
                
                connectionStatus = "Disconnected"
                
            case .connectionAccepted:
                
                connectionStatus = "Connected"
                
            case .connectionRequest:
                
                break
                
            }
            
        } catch {
            
            reportError(error)
            
        }
        
    }
    
}
//Handles the note

private extension PeerManager {
    
    func receive(
        _ note: Note
    ) {
        
        guard notesStore.note(with: note.id) == nil else {
            return
        }
        
        notesStore.add(note)
        
    }
    
}
//Utility connection
extension PeerManager {
    
    func sendPing() {
        
        sendPacket(
            Date(),
            type: .ping
        )
        
    }
    
    func sendDisconnect() {
        
        sendPacket(
            Date(),
            type: .disconnect
        )
        
        disconnect()
        
    }
    
}
//Convenience

extension PeerManager {
    
    var hasConnectedPeers: Bool {
        
        !connectedPeers.isEmpty
        
    }
    
    var connectedPeerNames: [String] {
        
        connectedPeers.map(\.displayName)
        
    }
    
    var nearbyPeerNames: [String] {
        
        nearbyPeers.map(\.displayName)
        
    }
    
}
//Just in case they disconnection from session
private extension PeerManager {
    
    func rebuildSessionIfNeeded() {
        
        guard session.connectedPeers.isEmpty else {
            return
        }
        
        session.disconnect()
        
        configureSession()
        
    }
    
}
//Disconnects the user

extension PeerManager {
    
    func disconnectAndReset() {
        
        invitationTimeoutTask?.cancel()
        
        incomingRequest = nil
        showingConnectionRequest = false
        
        session.disconnect()
        
        connectedPeers.removeAll()
        
        nearbyPeers.removeAll()
        
        connectionStatus = "Not Connected"
        
        stopAdvertising()
        stopBrowsing()
        
        configureSession()
        
        startAdvertising()
        startBrowsing()
        
    }
}
//Restart Advertising and Browsing

extension PeerManager {
    
    func restartNetworking() {
        
        stopAdvertising()
        stopBrowsing()
        
        startAdvertising()
        startBrowsing()
        
    }
    
}
//error

private extension PeerManager {
    
    func reportError(
        _ error: Error
    ) {
        
        lastError = error.localizedDescription
        
        print(
            "[PeerManager]",
            error.localizedDescription
        )
        
    }
    
}

extension PeerManager {
    
    var isConnected: Bool {
        
        !session.connectedPeers.isEmpty
        
    }
    
    var peerCount: Int {
        
        session.connectedPeers.count
        
    }
    
}
//debug
#if DEBUG

extension PeerManager {
    
    func debugPrintState() {
        
        print("----- PeerManager -----")
        
        print("Nickname:", settings.nickname)
        
        print("Nearby:")
        
        nearbyPeers.forEach {
            
            print("  \($0.displayName)")
            
        }
        
        print("Connected:")
        
        connectedPeers.forEach {
            
            print("  \($0.displayName)")
            
        }
        
        print("Advertising:", isAdvertising)
        
        print("Browsing:", isBrowsing)
        
        print("Status:", connectionStatus)
        
        print("-----------------------")
        
    }
    
}

#endif
