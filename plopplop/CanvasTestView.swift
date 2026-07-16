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
                        type: "text",
                        text: "Physics"
                    ),

                    CanvasObject(
                        x: 500,
                        y: 300,
                        type: "pdf",
                        file: CanvasFile(
                            fileName: "Test.pdf",
                            fileType: "pdf",
                            data: createTestPDF()
                        )
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
}
