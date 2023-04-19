// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

public extension NodeEditor {
    /// Configuration used to determine rendering style of a ``NodeEditor`` instance.
    struct Style {
        /// Color used for rendering nodes.
        public var nodeColor: Color = .init(white: 0.3)

        /// Color used for rendering Integer wires.
        public var intWire: WireStyle = .init()
        
        /// Color used for rendering Integer wires.
        public var defaultWire: WireStyle = .init()
    }
}

public extension NodeEditor.Style {
    /// Configuration used to determine rendering style of a ``NodeEditor`` wire type.
    struct WireStyle {
        public var inputColor: Color = .cyan
        public var outputColor: Color = .magenta

        /// Get or set the input and output colors as a `Gradient`.
        /// Only the first and last stops will be used.
        public var gradient: Gradient {
            get {
                Gradient(colors: [outputColor, inputColor])
            }
            set {
                if let inputColor = newValue.stops.last?.color {
                    self.inputColor = inputColor
                }
                if let outputColor = newValue.stops.first?.color {
                    self.outputColor = outputColor
                }
            }
        }
    }
}
