// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

extension Node {
    public func translate(by offset: CGSize) -> CGPoint {
        var position = self.position ?? .zero
        
        position.x += offset.width
        position.y += offset.height
        
        self.position = position
        return position
    }

    func hitTest(nodeId: NodeId, point: CGPoint, layout: LayoutConstants) -> Patch.HitTestResult? {
        for (inputIndex, input) in inputs.enumerated() {
            if inputRect(input: inputIndex, layout: layout).contains(point) {
                return .input(InputID(nodeId, input.id))
            }
        }
        for (outputIndex, output) in outputs.enumerated() {
            if outputRect(output: outputIndex, layout: layout).contains(point) {
                return .output(OutputID(nodeId, output.id))
            }
        }

        if rect(layout: layout).contains(point) {
            return .node(nodeId)
        }

        return nil
    }
}
