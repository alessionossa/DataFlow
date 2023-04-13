// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

extension Node {
    public func translate(by offset: CGSize) -> Node {
        var result = self
        result.position.x += offset.width
        result.position.y += offset.height
        return result
    }

    func hitTest(nodeId: NodeId, point: CGPoint, layout: LayoutConstants) -> Patch.HitTestResult? {
        for (inputIndex, input) in inputs.enumerated() {
            if inputRect(input: inputIndex, layout: layout).contains(point) {
                return .input(nodeId, input.id)
            }
        }
        for (outputIndex, output) in outputs.enumerated() {
            if outputRect(output: outputIndex, layout: layout).contains(point) {
                return .output(nodeId, output.id)
            }
        }

        if rect(layout: layout).contains(point) {
            return .node(nodeId)
        }

        return nil
    }
}
