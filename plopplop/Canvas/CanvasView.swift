//
//  CanvasView.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct CanvasView: View {
    let workspace: Workspace

    @State private var canvasOffset: CGSize = .zero
    @State private var zoom: CGFloat = 1
    @State private var dragStartOffset: CGSize?
    @State private var zoomStart: CGFloat?
    @State private var selectedObjectID: UUID?
    @State private var currentPoints: [InkPoint] = []
    @State private var drawingMode = true
    @State private var canvasSize: CGSize = .zero

    // Drawing tool settings
    @State private var tool: DrawingTool = .pen
    @State private var inkColor: InkColor = .black
    @State private var strokeWidth: Double = 4

    // Sheets / popovers
    @State private var showingPalette = false
    @State private var showingFileImporter = false
    @State private var showingScanner = false
    @State private var importError: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !drawingMode else {
                                    return
                                }

                                if dragStartOffset == nil {
                                    dragStartOffset = canvasOffset
                                }

                                canvasOffset = CGSize(
                                    width: dragStartOffset!.width
                                        + value.translation.width,

                                    height: dragStartOffset!.height
                                        + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                dragStartOffset = nil
                            }
                    )
                    .onTapGesture {
                        // Tap empty canvas to deselect.
                        selectedObjectID = nil
                    }

                ZStack {
                    ForEach(workspace.objects) { object in
                        CanvasObjectView(
                            object: object,
                            zoom: zoom,
                            isSelected: selectedObjectID == object.id,
                            onSelect: {
                                selectedObjectID = object.id
                            }
                        )
                    }

                    // Live preview of the stroke currently being drawn.
                    if drawingMode && currentPoints.count > 1 {
                        InkView(
                            points: currentPoints,
                            color: inkColor.color,
                            lineWidth: strokeWidth,
                            opacity: tool.opacity
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .allowsHitTesting(false)
                    }

                    if drawingMode {
                        DrawingLayer(
                            points: $currentPoints,
                            onEnded: finishDrawing
                        )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .scaleEffect(zoom)
                .offset(canvasOffset)
            }
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if zoomStart == nil {
                            zoomStart = zoom
                        }

                        zoom = min(
                            max(
                                zoomStart! * value,
                                0.5
                            ),
                            3
                        )
                    }
                    .onEnded { _ in
                        zoomStart = nil
                    }
            )
            .overlay(alignment: .top) {
                toolbar
            }
            .onAppear {
                canvasSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newValue in
                canvasSize = newValue
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: true
        ) { result in
            handleImport(result)
        }
        .fullScreenCover(isPresented: $showingScanner) {
            DocumentScannerView(
                onFinish: { data in
                    showingScanner = false
                    addPDF(data: data, name: "Scan.pdf")
                },
                onCancel: {
                    showingScanner = false
                }
            )
            .ignoresSafeArea()
        }
        .alert(
            "Import failed",
            isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 12) {
            Button {
                drawingMode.toggle()
                selectedObjectID = nil
            } label: {
                toolbarLabel(
                    drawingMode ? "Draw" : "Select",
                    systemImage: drawingMode ? "pencil.tip" : "hand.tap"
                )
            }

            // Pen / tool palette
            Button {
                showingPalette = true
            } label: {
                Image(systemName: tool.systemImage)
                    .font(.headline)
                    .foregroundStyle(inkColor.color)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay {
                        Circle().stroke(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            .popover(isPresented: $showingPalette) {
                ToolPaletteView(
                    tool: $tool,
                    inkColor: $inkColor,
                    strokeWidth: $strokeWidth
                )
                .presentationCompactAdaptation(.popover)
            }

            // Add menu: import files or scan
            Menu {
                Button {
                    showingFileImporter = true
                } label: {
                    Label("Import File", systemImage: "doc.badge.plus")
                }

                Button {
                    if DocumentScannerView.isSupported {
                        showingScanner = true
                    } else {
                        importError = "Scanning needs a camera and isn't available on this device."
                    }
                } label: {
                    Label("Scan Document", systemImage: "doc.viewfinder")
                }
            } label: {
                toolbarLabel("Add", systemImage: "plus")
            }

            if selectedObjectID != nil {
                Button(role: .destructive) {
                    deleteSelected()
                } label: {
                    toolbarLabel("Delete", systemImage: "trash")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.top, 8)
    }

    private func toolbarLabel(
        _ title: String,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .labelStyle(.titleAndIcon)
    }

    // MARK: - Placement helpers

    /// A point near the middle of the visible canvas for new objects.
    private var placementCenter: CGPoint {
        let size = canvasSize == .zero
            ? CGSize(width: 800, height: 800)
            : canvasSize

        return CGPoint(
            x: size.width / 2 - canvasOffset.width / zoom,
            y: size.height / 2 - canvasOffset.height / zoom
        )
    }

    // MARK: - Drawing

    private func finishDrawing() {
        guard currentPoints.count > 1 else {
            currentPoints.removeAll()
            return
        }

        let minX = currentPoints.map(\.x).min() ?? 0
        let maxX = currentPoints.map(\.x).max() ?? 0
        let minY = currentPoints.map(\.y).min() ?? 0
        let maxY = currentPoints.map(\.y).max() ?? 0

        let padding = strokeWidth + 10

        let width = max(
            maxX - minX + padding * 2,
            40
        )

        let height = max(
            maxY - minY + padding * 2,
            40
        )

        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2

        let localPoints = currentPoints.map { point in
            InkPoint(
                x: point.x - minX + padding,
                y: point.y - minY + padding
            )
        }

        let data = try? JSONEncoder().encode(localPoints)

        let inkObject = CanvasObject(
            x: centerX,
            y: centerY,
            width: width,
            height: height,
            type: "ink",
            pointsData: data,
            inkColor: inkColor.rawValue,
            strokeWidth: strokeWidth,
            opacity: tool.opacity
        )

        workspace.objects.append(inkObject)

        selectedObjectID = inkObject.id
        currentPoints.removeAll()
    }

    private func deleteSelected() {
        guard let id = selectedObjectID,
              let index = workspace.objects.firstIndex(where: { $0.id == id })
        else {
            return
        }

        workspace.objects.remove(at: index)
        selectedObjectID = nil
    }

    // MARK: - Importing

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                importOne(url)
            }
        case .failure(let error):
            importError = error.localizedDescription
        }
    }

    private func importOne(_ url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let ext = url.pathExtension.lowercased()

            if ext == "pdf" {
                addPDF(data: data, name: url.lastPathComponent)
            } else {
                addImage(data: data, name: url.lastPathComponent)
            }
        } catch {
            importError = error.localizedDescription
        }
    }

    private func addPDF(data: Data, name: String) {
        let center = placementCenter

        let object = CanvasObject(
            x: center.x,
            y: center.y,
            width: 300,
            height: 424,
            type: "pdf",
            file: CanvasFile(
                fileName: name,
                fileType: "pdf",
                data: data
            )
        )

        workspace.objects.append(object)
        selectedObjectID = object.id
    }

    private func addImage(data: Data, name: String) {
        let center = placementCenter

        // Size the object to the image's aspect ratio, capped to 320 wide.
        let width = 320.0
        var height = 320.0

        if let image = UIImage(data: data), image.size.width > 0 {
            let ratio = image.size.height / image.size.width
            height = width * ratio
        }

        let object = CanvasObject(
            x: center.x,
            y: center.y,
            width: width,
            height: height,
            type: "image",
            file: CanvasFile(
                fileName: name,
                fileType: "image",
                data: data
            )
        )

        workspace.objects.append(object)
        selectedObjectID = object.id
    }
}
