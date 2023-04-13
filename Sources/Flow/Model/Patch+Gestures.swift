// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

extension Patch {
    enum HitTestResult {
        case node(NodeId)
        case input(NodeId, PortId)
        case output(NodeId, PortId)
    }

    /// Hit test a point against the whole patch.
    func hitTest(point: CGPoint, layout: LayoutConstants) -> HitTestResult? {
        for node in nodes.reversed() {
            if let result = node.hitTest(nodeId: node.id, point: point, layout: layout) {
                return result
            }
        }

        return nil
    }

    func moveNode(
        nodeId: NodeId,
        offset: CGSize,
        nodeMoved: NodeEditor.NodeMovedHandler
    ) {
        var node = nodes[withId: nodeId]
        if !node.locked {
            node.position += offset
            nodes.update(with: node)
            nodeMoved(nodeId, node.position)
        }
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<NodeId> {
        var selection = Set<NodeId>()

        for node in nodes {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(node.id)
            }
        }
        return selection
    }
}
