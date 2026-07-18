//
//  CanvasObjectContent.swift
//  plopplop
//
//  Created by cheng xi on 16/7/26.
//
import SwiftUI
import PDFKit

struct CanvasObjectContent: View {
    let object: CanvasObject
    let width: CGFloat
        let height: CGFloat

    @State private var isEditing = false

    var body: some View {
        Group {
            if object.type == "text" {
                if isEditing {
                    TextField(
                        "Text",
                        text: Bindable(object).text
                    )
                    .textFieldStyle(.plain)
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .background(.white)
                    .cornerRadius(8)
                } else {
                    Text(object.text)
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                        .background(.white)
                        .cornerRadius(8)
                }

            } else if object.type == "pdf" {
                if let data = object.file?.data,
                   let document = PDFDocument(data: data) {
                    PDFKitView(document: document)
                        .frame(
                            width: width,
                            height: height
                        )
                        .allowsHitTesting(false)
                }

            } else if object.type == "ink" {
                InkView(points: inkPoints)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )

            } else {
                Circle()
                    .frame(width: 80, height: 80)
            }
        }
        .onTapGesture(count: 2) {
            if object.type == "text" {
                isEditing = true
            }
        }
    }
    private var inkPoints: [InkPoint] {
        guard let data = object.pointsData else {
            return []
        }

        return (try? JSONDecoder().decode(
            [InkPoint].self,
            from: data
        )) ?? []
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        pdfView.document = document
        pdfView.autoScales = true
        pdfView.isUserInteractionEnabled = false

        return pdfView
    }

    func updateUIView(
        _ pdfView: PDFView,
        context: Context
    ) {
        pdfView.document = document
    }
}

struct InkView: View {
    let points: [InkPoint]

    var body: some View {
        Canvas { context, size in
            guard points.count > 1 else {
                return
            }

            var path = Path()

            path.move(
                to: CGPoint(
                    x: points[0].x,
                    y: points[0].y
                )
            )

            for point in points.dropFirst() {
                path.addLine(
                    to: CGPoint(
                        x: point.x,
                        y: point.y
                    )
                )
            }

            context.stroke(
                path,
                with: .color(.black),
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}
