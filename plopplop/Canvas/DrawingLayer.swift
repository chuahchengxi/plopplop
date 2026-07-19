//
//  DrawingLayer.swift
//  plopplop
//
//  Created by cheng xi on 18/7/26.
//
import SwiftUI
import UIKit

struct DrawingLayer: UIViewRepresentable {
    @Binding var points: [InkPoint]

    let onEnded: () -> Void

    func makeUIView(context: Context) -> PencilDrawingView {
        let view = PencilDrawingView()

        view.onPoint = { point in
            points.append(
                InkPoint(
                    x: point.x,
                    y: point.y
                )
            )
        }

        view.onEnded = {
            onEnded()
        }

        return view
    }

    func updateUIView(
        _ uiView: PencilDrawingView,
        context: Context
    ) {
        uiView.onPoint = { point in
            points.append(
                InkPoint(
                    x: point.x,
                    y: point.y
                )
            )
        }

        uiView.onEnded = {
            onEnded()
        }
    }
}

final class PencilDrawingView: UIView {

    var onPoint: ((CGPoint) -> Void)?
    var onEnded: (() -> Void)?
    var requiresPencil = false

    private var isDrawing = false

    private func isDrawingTouch(_ touch: UITouch) -> Bool {
        requiresPencil ? touch.type == .pencil : true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        isMultipleTouchEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let touch = touches.first else {
            return
        }

        guard isDrawingTouch(touch) else {
            return
        }

        isDrawing = true

        onPoint?(
            touch.location(in: self)
        )
    }

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard isDrawing else {
            return
        }

        guard let touch = touches.first else {
            return
        }

        guard isDrawingTouch(touch) else {
            return
        }

        onPoint?(
            touch.location(in: self)
        )
    }

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard isDrawing else {
            return
        }

        isDrawing = false

        onEnded?()
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        isDrawing = false

        onEnded?()
    }
}
