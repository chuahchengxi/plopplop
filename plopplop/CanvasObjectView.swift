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
    @State private var resizeStartSize: CGSize?
    @State private var dragStartPosition: CGPoint?
    var body: some View {
        CanvasObjectContent(
            object: object,
            width: object.width,
            height: object.height
        )
            .frame(
                width: object.width,
                height: object.height
            )
            .overlay {
                if isSelected {
                    Rectangle()
                        .stroke(.blue, lineWidth: 2)
                    
                    resizeHandle
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
    
    var resizeHandle: some View {
        Circle()
            .fill(.white)
            .frame(width: 16, height: 16)
            .overlay {
                Circle()
                    .stroke(.blue, lineWidth: 2)
            }
            .offset(
                x: object.width / 2,
                y: object.height / 2
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if resizeStartSize == nil {
                            resizeStartSize = CGSize(
                                width: object.width,
                                height: object.height
                            )
                        }
                        
                        object.width = max(
                            80,
                            resizeStartSize!.width
                            + value.translation.width / zoom
                        )
                        
                        object.height = max(
                            50,
                            resizeStartSize!.height
                            + value.translation.height / zoom
                        )
                    }
                    .onEnded { _ in
                        resizeStartSize = nil
                    }
            )
    }
}
