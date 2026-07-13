import SwiftUI
import MultipeerConnectivity

struct NotesView: View {
    
    @EnvironmentObject
    private var peerManager: PeerManager
    
    @EnvironmentObject
    private var notesStore: NotesStore
    
    @EnvironmentObject
    private var settings: DeviceSettings
    
    @State
    private var showingSendView = false
    
    @State
    private var showingNicknameSheet = false
    
    @State
    private var nickname = ""
    
    @State
    private var searchText = ""
    
    private var filteredNotes: [Note] {
        
        let notes: [Note]
        
        if searchText.isEmpty {
            
            notes = notesStore.notes
            
        } else {
            
            notes = notesStore.notes.filter {
                
                $0.title.localizedCaseInsensitiveContains(searchText)
                ||
                $0.content.localizedCaseInsensitiveContains(searchText)
                ||
                $0.senderName.localizedCaseInsensitiveContains(searchText)
                
            }
            
        }
        
        return notes.sorted {
            
            if $0.isPinned != $1.isPinned {
                
                return $0.isPinned
                
            }
            
            return $0.createdAt > $1.createdAt
            
        }
        
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .bottomTrailing) {
                
                List {
                    
                    if notesStore.notes.isEmpty {
                        
                        ContentUnavailableView(
                            "No Notes Yet",
                            systemImage: "tray",
                            description: Text("Received notes will appear here.")
                        )
                        
                    } else if filteredNotes.isEmpty {
                        
                        ContentUnavailableView.search(
                            text: searchText
                        )
                        
                    } else {
                        
                        ForEach(filteredNotes) { note in
                            
                            NavigationLink(
                                destination: NoteDetailView(note: note)
                            ) {
                                NoteRow(note: note)
                            }
                            .swipeActions(edge: .leading) {

                                Button(
                                    note.isPinned ? "Unpin" : "Pin"
                                ) {

                                    notesStore.togglePinned(note)

                                }

                                .tint(.orange)

                                
                        }
                            .swipeActions(edge: .trailing) {
                                
                                Button(
                                    role: .destructive
                                ) {
                                    
                                    notesStore.remove(
                                        note
                                    )
                                    
                                } label: {
                                    
                                    Label(
                                        "Delete",
                                        systemImage: "trash"
                                    )
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                .searchable(
                    text: $searchText,
                    prompt: "Search Notes"
                )
                
                floatingButton
                
            }
            .navigationTitle("Notes")
            .sheet(
                isPresented: $showingSendView
            ) {
                
                SendView()
                
            }
            .sheet(
                isPresented: $peerManager.showingConnectionRequest
            ) {
                
                ConnectionRequestSheet()
                
            }
            .sheet(
                isPresented: $showingNicknameSheet
            ) {
                
                nicknameSetupSheet
                
            }
            .alert(
                "Error",
                isPresented: Binding(
                    
                    get: {
                        
                        peerManager.lastError != nil
                        
                    },
                    
                    set: { value in
                        
                        if !value {
                            
                            peerManager.clearError()
                            
                        }
                        
                    }
                    
                )
                
            ) {
                
                Button("OK") {
                    
                    peerManager.clearError()
                    
                }
                
            } message: {
                
                Text(
                    peerManager.lastError ?? ""
                )
                
            }
            .onAppear {
                
                nickname = settings.nickname
                
                showingNicknameSheet =
                !settings.hasNickname
                
            }
            
        }
        
    }
    
}
private extension NotesView {

    var floatingButton: some View {

        HStack {

            Spacer()

            Button {

                showingSendView = true

            } label: {

                Image(systemName: "square.and.pencil")
                    .font(.title.weight(.bold))
                    .frame(width: 64, height: 64)

            }
            .buttonStyle(.glassProminent)
            .disabled(!peerManager.isConnected)

        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)

    }

}

private extension NotesView {

    var nicknameSetupSheet: some View {

        NavigationStack {

            Form {

                Section("Welcome") {

                    Text("""
Choose a nickname that nearby devices will see when discovering you.
""")

                    TextField(
                        "Nickname",
                        text: $nickname
                    )
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                }

            }
            .navigationTitle("Welcome")
            .interactiveDismissDisabled()
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Continue") {

                        let trimmed = nickname
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )

                        guard !trimmed.isEmpty else {
                            return
                        }

                        settings.saveNickname(trimmed)

                        peerManager.refreshNickname()

                        showingNicknameSheet = false

                    }

                }

            }

        }

    }

}

#Preview {

    NotesView()
        .environmentObject(DeviceSettings())
        .environmentObject(NotesStore())
        .environmentObject(
            PeerManager(
                settings: DeviceSettings(),
                notesStore: NotesStore()
            )
        )

}
