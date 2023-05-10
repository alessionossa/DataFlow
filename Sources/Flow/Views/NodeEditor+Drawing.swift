// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension GraphicsContext {

    func strokeWire(
        from: CGPoint,
        to: CGPoint,
        gradient: Gradient
    ) {
        let d = 0.4 * abs(to.x - from.x)
        var path = Path()
        path.move(to: from)
        path.addCurve(
            to: to,
            control1: CGPoint(x: from.x + d, y: from.y),
            control2: CGPoint(x: to.x - d, y: to.y)
        )

        stroke(
            path,
            with: .linearGradient(gradient, startPoint: from, endPoint: to),
            style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
        )
    }
    
    func strokeDashedLine(from startPoint: CGPoint, to endPoint: CGPoint, pattern: [CGFloat]) {
        var path = Path()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let strokeStyle = StrokeStyle(lineWidth: 1, dash: pattern)
        
        stroke(path, with: .color(Color.gray.opacity(0.2)), style: strokeStyle)
    }
}

extension NodeEditor {

    func drawWires(cx: GraphicsContext) {
        var hideWire: Wire?
        switch dragInfo {
        case let .wire(_, _, hideWire: hw, _):
            hideWire = hw
        default:
            hideWire = nil
        }
        for wire in patch.wires where wire != hideWire {
            guard let fromPoint = self.patch.nodes[portId: wire.output].frame?.center,
                  let toPoint = self.patch.nodes[portId: wire.input].frame?.center else { continue }
            
            let gradient = self.gradient(for: wire)
            cx.strokeWire(from: fromPoint, to: toPoint, gradient: gradient)
        }
    }
    
    func drawDashedBackgroundLines(_ cx: GraphicsContext, _ size: CGSize) {
        let width = size.width
        let height = size.height

        // Draw vertical lines
        for x in stride(from: 0, to: width, by: layout.backgroundlinesSpacing) {
            let startPoint = CGPoint(x: x, y: 0)
            let endPoint = CGPoint(x: x, y: height)

            cx.strokeDashedLine(from: startPoint, to: endPoint, pattern: layout.backgroundlinesPattern)
        }

        // Draw horizontal lines
        for y in stride(from: 0, to: height, by: layout.backgroundlinesSpacing) {
            let startPoint = CGPoint(x: 0, y: y)
            let endPoint = CGPoint(x: width, y: y)

            cx.strokeDashedLine(from: startPoint, to: endPoint, pattern: layout.backgroundlinesPattern)
        }
    }

    func drawDraggedWire(cx: GraphicsContext) {
        if case let .wire(output: output, offset: offset, _, _) = dragInfo {
            guard let fromPoint = self.patch.nodes[portId: output].frame?.center else { return }
            
            let gradient = self.gradient(for: output)
            cx.strokeWire(from: fromPoint, to: fromPoint + offset, gradient: gradient)
        }
    }

    func drawSelectionRect(cx: GraphicsContext) {
        if case let .selection(rect: rect) = dragInfo {
            let rectPath = Path(roundedRect: rect, cornerRadius: 0)
            cx.stroke(rectPath, with: .color(.cyan))
        }
    }

    func gradient(for outputID: OutputID) -> Gradient {
        let port = patch
            .nodes[portId: outputID]
        
        return port.gradient(with: style) ?? .init(colors: [.gray])
    }

    func gradient(for wire: Wire) -> Gradient {
        gradient(for: wire.output)
    }
}
