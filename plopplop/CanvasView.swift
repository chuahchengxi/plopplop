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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.1)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
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

                ForEach(workspace.objects) { object in
                    CanvasObjectView(
                        object: object,
                        zoom: zoom
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
        .clipped()
    }
}
