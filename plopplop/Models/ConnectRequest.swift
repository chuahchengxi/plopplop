//
//  ConnectRequest.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import Foundation
import MultipeerConnectivity

struct ConnectionRequest: Identifiable {

    let id = UUID()
//request the connection
    let peer: MCPeerID
//nickname is user nickname
    let nickname: String
//pairing code
    let pairingCode: String
//accept or decline the request
    let invitationHandler: (Bool, MCSession?) -> Void

}
