//
//  ToolPaletteView.swift
//  plopplop
//
//  Drawing tool options: pen / highlighter, colour, and stroke size.
//

import SwiftUI

enum DrawingTool: String, CaseIterable, Identifiable {
    case pen
    case highlighter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pen: return "Pen"
        case .highlighter: return "Highlighter"
        }
    }

    var systemImage: String {
        switch self {
        case .pen: return "pencil.tip"
        case .highlighter: return "highlighter"
        }
    }

    /// Opacity applied to strokes made with this tool.
    var opacity: Double {
        switch self {
        case .pen: return 1
        case .highlighter: return 0.35
        }
    }
}

struct ToolPaletteView: View {
    @Binding var tool: DrawingTool
    @Binding var inkColor: InkColor
    @Binding var strokeWidth: Double

    private let colors: [InkColor] = [.black, .red, .blue, .green, .yellow]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tool")
                .font(.headline)

            Picker("Tool", selection: $tool) {
                ForEach(DrawingTool.allCases) { tool in
                    Label(tool.title, systemImage: tool.systemImage)
                        .tag(tool)
                }
            }
            .pickerStyle(.segmented)

            Text("Colour")
                .font(.headline)

            HStack(spacing: 14) {
                ForEach(colors, id: \.self) { swatch in
                    Button {
                        inkColor = swatch
                    } label: {
                        Circle()
                            .fill(swatch.color)
                            .frame(width: 30, height: 30)
                            .overlay {
                                Circle()
                                    .stroke(
                                        .primary,
                                        lineWidth: inkColor == swatch ? 3 : 0
                                    )
                            }
                            .overlay {
                                // Outline the white/yellow swatch so it stays visible.
                                Circle()
                                    .stroke(.gray.opacity(0.4), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Size")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(strokeWidth)) pt")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(value: $strokeWidth, in: 1...40, step: 1)

                // Preview of the current stroke.
                Capsule()
                    .fill(inkColor.color.opacity(tool.opacity))
                    .frame(height: max(2, strokeWidth))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
