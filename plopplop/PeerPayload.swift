//
//  PeerPayload.swift
//  plopplop
//
//  Created by cheng xi on 15/7/26.
//


import Foundation

enum PeerPayload: Codable {

    case intro(nickname: String)

    case draft(
        id: UUID,
        title: String,
        body: String
    )

    case message(
        text: String,
        senderNickname: String
    )
}
