// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// State for all gestures.
    enum DragInfo {
        case wire(output: OutputID, offset: CGSize = .zero, hideWire: Wire? = nil)
        case node(id: NodeId, offset: CGSize = .zero)
        case selection(rect: CGRect = .zero)
        case none
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func connect(_ output: OutputID, to input: InputID) {
        let wire = Wire(from: output, to: input)

        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            let result = w.input != wire.input
            if !result {
                wireRemoved(w)
            }
            return result
        }
        patch.wires.insert(wire)
        wireAdded(wire)
    }

    func attachedWire(inputID: InputID) -> Wire? {
        patch.wires.first(where: { $0.input == inputID })
    }

    func toLocal(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x / CGFloat(zoom), y: p.y / CGFloat(zoom)) - pan
    }

    func toLocal(_ sz: CGSize) -> CGSize {
        CGSize(width: sz.width / CGFloat(zoom), height: sz.height / CGFloat(zoom))
    }

#if os(macOS)
    var commandGesture: some Gesture {
        DragGesture(minimumDistance: 0).modifiers(.command).onEnded { drag in
            guard drag.distance < 5 else { return }

            let startLocation = toLocal(drag.startLocation)

            let hitResult = patch.hitTest(point: startLocation, layout: layout)
            switch hitResult {
            case .none:
                return
            case let .node(nodeIndex):
                if selection.contains(nodeIndex) {
                    selection.remove(nodeIndex)
                } else {
                    selection.insert(nodeIndex)
                }
            default: break
            }
        }
    }
#endif

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { drag, dragInfo, _ in

                let startLocation = toLocal(drag.startLocation)
                let location = toLocal(drag.location)
                let translation = toLocal(drag.translation)

                switch patch.hitTest(point: startLocation, layout: layout) {
                case .none:
                    dragInfo = .selection(rect: CGRect(a: startLocation,
                                                       b: location))
                case let .node(nodeId):
                    dragInfo = .node(id: nodeId, offset: translation)
                case let .output(nodeId, portId):
                    dragInfo = DragInfo.wire(output: OutputID(nodeId, portId), offset: translation)
                case let .input(nodeId, portId):
                    // Is a wire attached to the input?
                    let inputId = InputID(nodeId, portId)
                    if let attachedWire = attachedWire(inputID: inputId) {
                        
                        let inputNode = patch.nodes[withId: nodeId]
                        let inputPortIndex = inputNode.indexOfInput(inputId)
                        
                        
                        let outputNode = patch.nodes[withId: attachedWire.output.nodeId]
                        let outputIndex = outputNode.indexOfOutput(attachedWire.output)
                        
                        guard let outputIndex, let inputPortIndex else { return }
                        let inputCenter = inputNode.inputRect(input: inputPortIndex, layout: layout).center
                        let outputCenter = outputNode.outputRect(output: outputIndex, layout: layout).center
                        
                        let offset = inputCenter - outputCenter + translation
                        dragInfo = .wire(output: attachedWire.output,
                                         offset: offset,
                                         hideWire: attachedWire)
                    }
                }
            }
            .onEnded { drag in

                let startLocation = toLocal(drag.startLocation)
                let location = toLocal(drag.location)
                let translation = toLocal(drag.translation)

                let hitResult = patch.hitTest(point: startLocation, layout: layout)

                // Note that this threshold should be in screen coordinates.
                if drag.distance > 5 {
                    switch hitResult {
                    case .none:
                        let selectionRect = CGRect(a: startLocation, b: location)
                        selection = self.patch.selected(
                            in: selectionRect,
                            layout: layout
                        )
                    case let .node(nodeId):
                        patch.moveNode(
                            nodeId: nodeId,
                            offset: translation,
                            nodeMoved: self.nodeMoved
                        )
                        if selection.contains(nodeId) {
                            for idx in selection where idx != nodeId {
                                patch.moveNode(
                                    nodeId: idx,
                                    offset: translation,
                                    nodeMoved: self.nodeMoved
                                )
                            }
                        }
                    case let .output(nodeId, portId):
                        let type = patch.nodes[withId: nodeId].outputs[portId].type
                        if let input = findInput(point: location, type: type) {
                            connect(OutputID(nodeId, portId), to: input)
                        }
                    case let .input(nodeId, portId):
                        let type = patch.nodes[withId: nodeId].inputs[portId].type
                        // Is a wire attached to the input?
                        if let attachedWire = attachedWire(inputID: InputID(nodeId, portId)) {
                            patch.wires.remove(attachedWire)
                            wireRemoved(attachedWire)
                            if let input = findInput(point: location, type: type) {
                                connect(attachedWire.output, to: input)
                            }
                        }
                    }
                } else {
                    // If we haven't moved far, then this is effectively a tap.
                    switch hitResult {
                    case .none:
                        selection = Set<NodeId>()
                    case let .node(nodeIndex):
                        selection = Set<NodeId>([nodeIndex])
                    default: break
                    }
                }
            }
    }
}

extension DragGesture.Value {
    @inlinable @inline(__always)
    var distance: CGFloat {
        startLocation.distance(to: location)
    }
}
