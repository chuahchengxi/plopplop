//
//  NoteStore.swift
//  plopplop
//
//  Created by cheng xi on 12/7/26.
//
import Foundation
import SwiftUI
import Combine

@MainActor

final class NotesStore: ObservableObject {
    
    @Published private(set) var notes: [Note] = []
    
    private let fileName = "Notes.json"
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }() 
    
    
    init() {
        loadNotes()
    }
    
    //API
    
    func reload() {
        loadNotes()
    }
    
    //Persist the new note
    func add(_ note: Note) {
        
        notes.insert(note, at: 0)
        
        saveNotes()
        
    }
    //Add multiple notes and the UUID does not duplicate.
    func add(contentsOf newNotes: [Note]) {
        
        for note in newNotes {
            
            guard !notes.contains(where: { $0.id == note.id }) else {
                continue
            }
            
            notes.append(note)
            
        }
        
        sortNotes()
        
        saveNotes()
        
    }
    //If there is an existing note, update the note
    func update(_ note: Note) {
        
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            return
        }
        
        notes[index] = note
        
        sortNotes()
        
        saveNotes()
        
    }
    //Remove the note
    func remove(_ note: Note) {
        
        notes.removeAll {
            $0.id == note.id
        }
        
        saveNotes()
        
    }
    //Remove the note through UUID
    func remove(id: UUID) {
        
        notes.removeAll {
            $0.id == id
        }
        
        saveNotes()
        
    }
    //Delete all
    func removeAll() {
        
        notes.removeAll()
        
        saveNotes()
        
    }
    //Returns the note with the UUID
    func note(with id: UUID) -> Note? {
        
        notes.first {
            $0.id == id
        }
        
    }
    //Always sort notes by first created
    private func sortNotes() {
        
        notes.sort {
            $0.createdAt > $1.createdAt
        }
        
    }
    //save to Documents
    private func saveNotes() {
        
        do {
            
            let data = try encoder.encode(notes)
            
            try data.write(
                to: fileURL,
                options: .atomic
            )
            
        } catch {
            
            print("❌ Failed to save notes:")
            print(error.localizedDescription)
            
        }
        
    }
    //Loads the note from the user
    private func loadNotes() {
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            
            notes = []
            
            return
            
        }
        
        do {
            
            let data = try Data(contentsOf: fileURL)
            
            let loadedNotes = try decoder.decode(
                [Note].self,
                from: data
            )
            
            notes = loadedNotes.sorted {
                $0.createdAt > $1.createdAt
            }
            
        } catch {
            
            print("❌ Failed to load notes:")
            print(error.localizedDescription)
            
            notes = []
            
        }
        
    }
    //Location of the data
    private var fileURL: URL {
        
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
            .appendingPathComponent(fileName)
        
    }
    
}
