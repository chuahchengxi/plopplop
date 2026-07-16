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

    @State private var dragStartPosition: CGPoint?

    var body: some View {
        CanvasObjectContent(object: object)
            .position(
                x: object.x,
                y: object.y
            )
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
