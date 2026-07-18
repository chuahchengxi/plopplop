//
//  CanvasView.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//
import SwiftUI

struct CanvasView: View {
    let workspace: Workspace
    
    @State private var canvasOffset: CGSize = .zero
    @State private var zoom: CGFloat = 1
    @State private var dragStartOffset: CGSize?
    @State private var zoomStart: CGFloat?
    @State private var selectedObjectID: UUID?
    @State private var isDrawing = false
    @State private var currentPoints: [InkPoint] = []
    @State private var drawingMode = true
    
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
        }
    }
    private func finishDrawing() {
        guard currentPoints.count > 1 else {
            currentPoints.removeAll()
            return
        }
        
        let minX = currentPoints.map(\.x).min() ?? 0
        let maxX = currentPoints.map(\.x).max() ?? 0
        let minY = currentPoints.map(\.y).min() ?? 0
        let maxY = currentPoints.map(\.y).max() ?? 0
        
        let padding = 10.0

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
            pointsData: data
        )
        
        workspace.objects.append(inkObject)
        
        selectedObjectID = inkObject.id
        currentPoints.removeAll()
    }
}
