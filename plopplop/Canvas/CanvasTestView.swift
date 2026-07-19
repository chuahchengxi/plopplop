//
//  CanvasTestView.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//

import SwiftUI
import UIKit

struct CanvasTestView: View {
    var body: some View {
        CanvasView(
            workspace: Workspace(
                name: "Test Workspace",
                objects: [
                    CanvasObject(
                        x: 150,
                        y: 200,
                        width: 200,
                        height: 80,
                        type: "text",
                        text: "Physics"
                    ),

                    CanvasObject(
                        x: 500,
                        y: 300,
                        width: 300,
                        height: 400,
                        type: "pdf",
                        file: CanvasFile(
                            fileName: "Test.pdf",
                            fileType: "pdf",
                            data: createTestPDF()
                        )
                    ),
                    
                    CanvasObject(
                        x: 300,
                        y: 500,
                        width: 300,
                        height: 200,
                        type: "ink",
                        pointsData: createTestInk()
                    )
                ]
            )
        )
    }

    private func createTestPDF() -> Data {
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(
                x: 0,
                y: 0,
                width: 595,
                height: 842
            )
        )

        return renderer.pdfData { context in
            context.beginPage()

            let title = "Physics Notes"

            title.draw(
                at: CGPoint(x: 50, y: 50),
                withAttributes: [
                    .font: UIFont.systemFont(
                        ofSize: 32,
                        weight: .bold
                    )
                ]
            )

            let text = """
            This is a test PDF inside the canvas.

            The PDF is stored as CanvasFile data.
            """

            text.draw(
                in: CGRect(
                    x: 50,
                    y: 120,
                    width: 500,
                    height: 300
                ),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 20)
                ]
            )
        }
    }
    private func createTestInk() -> Data {
        let points = [
            InkPoint(x: 20, y: 100),
            InkPoint(x: 50, y: 80),
            InkPoint(x: 80, y: 120),
            InkPoint(x: 110, y: 60),
            InkPoint(x: 140, y: 100)
        ]

        return (try? JSONEncoder().encode(points)) ?? Data()
    }
}
