// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation
import SwiftUI

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's `onChange(of:)` to monitor changes, or use `NodeEditor.onNodeAdded`, etc.
public class Patch: ObservableObject {
    @Published public var nodes: [any Node]
    
    @Published public var wires: Set<Wire>

    public init(nodes: [any Node], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = wires
    }
}
