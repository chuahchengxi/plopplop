//
//  DocumentScannerView.swift
//  plopplop
//
//  Wraps VisionKit's document camera so users can scan pages
//  straight into the canvas as a PDF.
//

import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    /// Whether this device supports document scanning (needs a camera).
    static var isSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }

    /// Called with the combined PDF data once scanning finishes.
    let onFinish: (Data) -> Void
    /// Called when the user cancels or scanning fails.
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView

        init(parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var pages: [UIImage] = []
            for index in 0..<scan.pageCount {
                pages.append(scan.imageOfPage(at: index))
            }

            if let data = PDFBuilder.pdfData(from: pages) {
                parent.onFinish(data)
            } else {
                parent.onCancel()
            }
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            parent.onCancel()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            parent.onCancel()
        }
    }
}

enum PDFBuilder {
    /// Renders images into a multi-page PDF, one image per page.
    static func pdfData(from images: [UIImage]) -> Data? {
        guard !images.isEmpty else {
            return nil
        }

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(
                x: 0,
                y: 0,
                width: 595,
                height: 842
            )
        )

        return renderer.pdfData { context in
            for image in images {
                let pageBounds = CGRect(
                    x: 0,
                    y: 0,
                    width: 595,
                    height: 842
                )

                context.beginPage()

                // Aspect-fit the scanned page inside A4.
                let scale = min(
                    pageBounds.width / image.size.width,
                    pageBounds.height / image.size.height
                )

                let drawSize = CGSize(
                    width: image.size.width * scale,
                    height: image.size.height * scale
                )

                let origin = CGPoint(
                    x: (pageBounds.width - drawSize.width) / 2,
                    y: (pageBounds.height - drawSize.height) / 2
                )

                image.draw(
                    in: CGRect(origin: origin, size: drawSize)
                )
            }
        }
    }
}
