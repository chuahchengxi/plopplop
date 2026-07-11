//
//  DataStore.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import Foundation

struct Note: Identifiable, Codable, Hashable{
    var id = UUID()
    var title: String
    var content: String
    var dateCreated: Date
}
