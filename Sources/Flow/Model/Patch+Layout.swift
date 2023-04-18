// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

public extension Patch {
    /// Recursive layout.
    ///
    /// - Returns: Height of all nodes in subtree.
    @discardableResult
    func recursiveLayout(
        nodeId: NodeId,
        at point: CGPoint,
        layout: LayoutConstants = LayoutConstants(),
        consumedNodeIndexes: Set<NodeId> = [],
        nodePadding: Bool = false
    ) -> (aggregateHeight: CGFloat,
          consumedNodeIndexes: Set<NodeId>)
    {
        let node = nodes[withId: nodeId]
        node.position = point

        // XXX: super slow
        let incomingWires = wires.filter {
            $0.input.nodeId == nodeId
        }.sorted(by: { lhs, rhs in
            guard let lhsIndex = node.indexOfInput(lhs.input),
                  let rhsIndex = node.indexOfInput(rhs.input)
            else { return false }
            return lhsIndex < rhsIndex
        })

        var consumedNodeIndexes = consumedNodeIndexes

        var height: CGFloat = 0
        for wire in incomingWires {
            let addPadding = wire == incomingWires.last
            let ni = wire.output.nodeId
            guard !consumedNodeIndexes.contains(ni) else { continue }
            let rl = recursiveLayout(nodeId: ni,
                                     at: CGPoint(x: point.x - layout.nodeWidth - layout.nodeSpacing,
                                                 y: point.y + height),
                                     layout: layout,
                                     consumedNodeIndexes: consumedNodeIndexes,
                                     nodePadding: addPadding)
            height = rl.aggregateHeight
            consumedNodeIndexes.insert(ni)
            consumedNodeIndexes.formUnion(rl.consumedNodeIndexes)
        }

        let nodeHeight = node.rect(layout: layout).height
        let aggregateHeight = max(height, nodeHeight) + (nodePadding ? layout.nodeSpacing : 0)
        return (aggregateHeight: aggregateHeight,
                consumedNodeIndexes: consumedNodeIndexes)
    }

    /// Manual stacked grid layout.
    ///
    /// - Parameters:
    ///   - origin: Top-left origin coordinate.
    ///   - columns: Array of columns each comprised of an array of node indexes.
    ///   - layout: Layout constants.
    func stackedLayout(at origin: CGPoint = .zero,
                                _ columns: [[NodeId]],
                                layout: LayoutConstants = LayoutConstants())
    {
        for column in columns.indices {
            let nodeStack = columns[column]
            var yOffset: CGFloat = 0

            let xPos = origin.x + (CGFloat(column) * (layout.nodeWidth + layout.nodeSpacing))
            for nodeId in nodeStack {
                let node = nodes[withId: nodeId]
                node.position = .init(
                    x: xPos,
                    y: origin.y + yOffset
                )

                let nodeHeight = node.rect(layout: layout).height
                yOffset += nodeHeight
                if column != columns.indices.last {
                    yOffset += layout.nodeSpacing
                }
            }
        }
    }
}
