//
//  TransferPacket.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import Foundation

struct TransferPacket: Codable {
    let type: PacketType
    let payload: Data
    init(
        type: PacketType,
        payload: Data
    ) {
        self.type = type
        self.payload = payload
    }

}
extension TransferPacket {
    init<T: Codable>(
        type: PacketType,
        value: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {

        encoder.dateEncodingStrategy = .iso8601

        let encodedPayload = try encoder.encode(value)

        self.init(
            type: type,
            payload: encodedPayload
        )
    }
    func encoded(
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Data {

        encoder.dateEncodingStrategy = .iso8601

        return try encoder.encode(self)
    }

}
extension TransferPacket {
    static func decode(
        from data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> TransferPacket {

        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(
            TransferPacket.self,
            from: data
        )
    }
    func decodePayload<T: Codable>(
        as type: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {

        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(
            T.self,
            from: payload
        )
    }

}
