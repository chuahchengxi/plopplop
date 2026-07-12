//
//  ContentView.swift
//  plopplop
//
//  Created by cheng xi on 4/7/26.
//
import SwiftUI
import MultipeerConnectivity
struct ContentView: View {
    @EnvironmentObject private var peerManager: PeerManager
    @EnvironmentObject private var notesStore: NotesStore
    @EnvironmentObject private var settings: DeviceSettings
    @State private var showingSendView = false
    @State private var showingReceiveView = false
    @State private var showingSettings = false
    @State private var showingNicknameSheet = false
    @State private var nickname = ""
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    connectionSection
                    nearbySection
                    connectedSection
                    
                }
                floatingButtons
            }
            .navigationTitle("plopplop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button {
                        
                        showingSettings = true
                        
                    } label: {
                        
                        Image(systemName: "gearshape")
                        
                    }
                    
                }
                
            }
            .sheet(isPresented: $showingSendView) {
                
                SendView()
                
            }
            .sheet(isPresented: $showingReceiveView) {
                
                ReceiveView()
                
            }
            .sheet(isPresented: $showingSettings) {
                
                SettingsView()
                
            }
            .sheet(isPresented: $peerManager.showingConnectionRequest) {
                
                ConnectionRequestSheet()
                
            }
            .sheet(isPresented: $showingNicknameSheet) {
                
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
                
                Text(peerManager.lastError ?? "")
                
            }
            .onAppear {
                
                nickname = settings.nickname
                showingNicknameSheet = !settings.hasNickname
                
            }
            
        }
        
    }
    
}
private extension ContentView {
    
    var connectionSection: some View {
        
        Section("Connection") {
            
            HStack {
                
                Text("Status")
                
                Spacer()
                
                Text(peerManager.connectionStatus)
                    .foregroundStyle(
                        peerManager.isConnected
                        ? .green
                        : .secondary
                    )
                
            }
            
            HStack {
                
                Text("Connected")
                
                Spacer()
                
                Text("\(peerManager.peerCount)")
                
            }
            
        }
        
    }
    
    var nearbySection: some View {
        
        Section("Nearby Devices") {
            
            if peerManager.nearbyPeers.isEmpty {
                
                Text("No nearby devices found.")
                    .foregroundStyle(.secondary)
                
            } else {
                
                ForEach(peerManager.nearbyPeers, id: \.self) { peer in
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text(peer.displayName)
                            
                            Text("Available")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                        }
                        
                        Spacer()
                        
                        Button("Connect") {
                            
                            peerManager.connect(to: peer)
                            
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    var connectedSection: some View {
        
        Section("Connected Devices") {
            
            if peerManager.connectedPeers.isEmpty {
                
                Text("No connected devices.")
                    .foregroundStyle(.secondary)
                
            } else {
                
                ForEach(peerManager.connectedPeers, id: \.self) { peer in
                    
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
private extension ContentView {
    @ViewBuilder
    func actionButton(
        title: String,
        systemImage: String,
        tint: Color,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            HStack(spacing: 14) {

                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(disabled ? .gray : tint)
                    .frame(width: 26)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(disabled ? .gray : tint)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)

        }
        .disabled(disabled)

    }

}
private extension ContentView {
    var floatingButtons: some View {
        HStack {
            Button {

                showingReceiveView = true

            } label: {
                Image(systemName: "tray.full.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 8)            }
            Spacer()

            Button {

                showingSendView = true

            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 8)
            }
            .disabled(!peerManager.isConnected)

        }
        .padding(.horizontal, 28)
        .padding(.bottom, 20)

    }

}

private extension ContentView {
    
    var nicknameSetupSheet: some View {
        
        NavigationStack {
            
            Form {
                
                Section("Welcome") {
                    
                    Text("""
Choose a nickname that other nearby devices will see.
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button("Continue") {
                        
                        let trimmed = nickname
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
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
    
    ContentView()
        .environmentObject(DeviceSettings())
        .environmentObject(NotesStore())
        .environmentObject(
            PeerManager(
                settings: DeviceSettings(),
                notesStore: NotesStore()
            )
        )
    
}
