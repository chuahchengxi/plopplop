//
//  CanvasObjectView.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//
import SwiftUI

struct CanvasObjectView: View {
    let object: CanvasObject
    let zoom: CGFloat
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var dragStartPosition: CGPoint?
    var body: some View {
        CanvasObjectContent(object: object)
            .frame(
                width: object.width,
                height: object.height
            )
            .overlay {
                if isSelected {
                    Rectangle()
                        .stroke(.blue, lineWidth: 2)
                }
            }
            .contentShape(Rectangle())
            .position(
                x: object.x,
                y: object.y
            )
            .onTapGesture {
                onSelect()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if dragStartPosition == nil {
                            dragStartPosition = CGPoint(
                                x: object.x,
                                y: object.y
                            )
                        }

                        object.x =
                            dragStartPosition!.x
                            + value.translation.width / zoom

                        object.y =
                            dragStartPosition!.y
                            + value.translation.height / zoom
                    }
                    .onEnded { _ in
                        dragStartPosition = nil
                    }
            )
    }
}
