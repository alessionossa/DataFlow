// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// State for all gestures.
    enum DragInfo: Equatable {
        case wire(output: OutputID, offset: CGSize = .zero, hideWire: Wire? = nil, possibleInputId: InputID? = nil)
        case node(id: NodeId, offset: CGSize = .zero)
        case selection(rect: CGRect = .zero)
        case none
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
}

extension DragGesture.Value {
    @inlinable @inline(__always)
    var distance: CGFloat {
        startLocation.distance(to: location)
    }
}
