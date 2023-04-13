// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

public extension NodeEditor {
    /// Offset to apply to a node based on selection and gesture state.
    func offset(for nodeId: NodeId) -> CGSize {
        if patch.nodes[withId: nodeId].locked {
            return .zero
        }
        switch dragInfo {
        case let .node(id: id, offset: offset):
            if nodeId == id {
                return offset
            }
            if selection.contains(id), selection.contains(nodeId) {
                // Offset other selected node only if we're dragging the
                // selection.
                return offset
            }
        default:
            return .zero
        }
        return .zero
    }

    /// Search for inputs.
    func findInput(node: Node, point: CGPoint, type: PortType) -> PortId? {
        let inputPort = node.inputs.enumerated().first { portIndex, input in
            input.type == type && node.inputRect(input: portIndex, layout: layout).contains(point)
        }?.element
        
        return inputPort?.id
    }

    /// Search for an input in the whole patch.
    func findInput(point: CGPoint, type: PortType) -> InputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for node in patch.nodes.reversed() {
            if let portId = findInput(node: node, point: point, type: type) {
                return InputID(node.id, portId)
            }
        }
        return nil
    }

    /// Search for outputs.
    func findOutput(node: Node, point: CGPoint) -> PortId? {
        let outputPort = node.outputs.enumerated().first { portIndex, _ in
            node.outputRect(output: portIndex, layout: layout).contains(point)
        }?.element
        
        return outputPort?.id
    }

    /// Search for an output in the whole patch.
    func findOutput(point: CGPoint) -> OutputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for node in patch.nodes.reversed() {
            if let portId = findOutput(node: node, point: point) {
                return OutputID(node.id, portId)
            }
        }
        return nil
    }

    /// Search for a node which intersects a point.
    func findNode(point: CGPoint) -> NodeIndex? {
        // Search nodes in reverse to find nodes drawn on top first.
        patch.nodes.enumerated().reversed().first { _, node in
            node.rect(layout: layout).contains(point)
        }?.0
    }
}
