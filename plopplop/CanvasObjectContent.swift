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
                    .background(.white)
                    .cornerRadius(8)
                } else {
                    Text(object.text)
                        .padding()
                        .background(.white)
                        .cornerRadius(8)
                }
            } else if object.type == "pdf" {
                if let data = object.file?.data,
                   let document = PDFDocument(data: data) {
                    PDFKitView(document: document)
                        .frame(width: 300, height: 400)
                        .allowsHitTesting(false)
                    
                }
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
