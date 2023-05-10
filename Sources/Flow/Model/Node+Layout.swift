// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

public extension Node {
    /// Calculates the bounding rectangle for a node.
    func rect(layout: LayoutConstants) -> CGRect {
        let position = position ?? .zero
        let maxio = CGFloat(max(inputs.count, outputs.count))
        let size = CGSize(width: layout.nodeWidth,
                          height: CGFloat((maxio * (layout.portSize.height + layout.portSpacing)) + layout.nodeTitleHeight + layout.portSpacing))

        return CGRect(origin: position, size: size)
    }
}
