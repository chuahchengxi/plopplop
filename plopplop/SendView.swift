//
//  SendView.swift
//  plopplop
//
//  Created by cheng xi on 11/7/26.
//
import SwiftUI
import MultipeerConnectivity

struct SendView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var peerManager: PeerManager
    @EnvironmentObject private var settings: DeviceSettings
    @EnvironmentObject private var draftStore: DraftStore
    @State private var title = ""
    @State private var content = ""
    @FocusState private var focusedField: Field?
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    private enum Field {
        case title
        case content
    }
    var body: some View {
        NavigationStack {
            Form {
                noteSection
                connectionSection
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button("Cancel") {
                        
                        dismiss()
                        
                    }
                    
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button("Send") {
                        
                        sendNote()
                        
                    }
                    .disabled(!canSend)
                    
                }
                
            }
            .alert(
                "Unable to Send",
                isPresented: $showingValidationAlert
            ) {
                
                Button("OK") { }
                
            } message: {
                
                Text(validationMessage)
                
            }
            
        }
        .onAppear {

            let draft = draftStore.restore()

            title = draft.title
            content = draft.content

        }
        .onChange(of: title) { _, _ in

            draftStore.update(
                title: title,
                content: content
            )

        }
        .onChange(of: content) { _, _ in

            draftStore.update(
                title: title,
                content: content
            )

        }
    }
    
}

private extension SendView {
    
    var noteSection: some View {
        
        Section("Note") {
            
            TextField(
                "Title",
                text: $title
            )
            .focused(
                $focusedField,
                equals: .title
            )
            
            TextField(
                "Content",
                text: $content,
                axis: .vertical
            )
            .lineLimit(
                8,
                reservesSpace: true
            )
            .focused(
                $focusedField,
                equals: .content
            )
            
        }
        
    }
    
}

private extension SendView {
    
    var connectionSection: some View {
        
        Section("Connection") {
            
            HStack {
                
                Text("Connected Devices")
                
                Spacer()
                
                Text(
                    "\(peerManager.peerCount)"
                )
                .foregroundStyle(.secondary)
                
            }
            
            if peerManager.connectedPeers.isEmpty {
                
                Label(
                    "No connected devices",
                    systemImage: "wifi.slash"
                )
                .foregroundStyle(.secondary)
                
            } else {
                
                ForEach(
                    peerManager.connectedPeers,
                    id: \.self
                ) { peer in
                    
                    Label(
                        peer.displayName,
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                    
                }
                
            }
            
        }
        
    }
    
}

private extension SendView {
    
    var canSend: Bool {
        
        peerManager.isConnected &&
        !title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty &&
        !content.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        
    }
    
    func sendNote() {
        
        let trimmedTitle = title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        let trimmedContent = content
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        guard !trimmedTitle.isEmpty else {
            
            validationMessage = "Please enter a title."
            
            showingValidationAlert = true
            
            return
            
        }
        
        guard !trimmedContent.isEmpty else {
            
            validationMessage = "Please enter some content."
            
            showingValidationAlert = true
            
            return
            
        }
        
        guard peerManager.isConnected else {
            
            validationMessage = "Connect to another device before sending a note."
            
            showingValidationAlert = true
            
            return
            
        }
        
        let note = Note(
            title: trimmedTitle,
            content: trimmedContent,
            senderName: settings.nickname
        )
        
        peerManager.send(note:note)

        draftStore.clear()

        title = ""
        content = ""

        dismiss()
    }
    
}
