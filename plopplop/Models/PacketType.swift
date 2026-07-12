//
//  PacketType.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import Foundation

enum PacketType: String, Codable {
    case note
    case connectionRequest
    case connectionAccepted
    case disconnect
    case ping
}
