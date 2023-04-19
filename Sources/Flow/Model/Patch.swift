// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation
import SwiftUI
import Combine
import os.log

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's `onChange(of:)` to monitor changes, or use `NodeEditor.onNodeAdded`, etc.
public class Patch: ObservableObject {
    
    /// Wire added handler closure.
    public typealias WireAddedHandler = (_ wire: Wire) -> Void
    
    /// Wire removed handler closure.
    public typealias WireRemovedHandler = (_ wire: Wire) -> Void
    
    /// Called when a wire is added.
    var wireAdded: Patch.WireAddedHandler = { _ in }

    /// Called when a wire is removed.
    var wireRemoved: Patch.WireRemovedHandler = { _ in }
    
    @Published public var nodes: [BaseNode]
    
    @Published var wires: Set<Wire>

    public init(nodes: [BaseNode], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = Set<Wire>()
        
        wires.forEach { wire in
            connect(wire)
        }
        
        observeNotes()
    }
    
    private var nodesCancellables: Set<AnyCancellable> = []
    
    private func observeNotes() {
        // Observe initial inputs
        observeNodeChildren()

        // Observe changes to the inputs array itself
        $nodes
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.observeNodeChildren()
            }
            .store(in: &nodesCancellables)
    }

    private func observeNodeChildren() {
        nodesCancellables.removeAll()
        nodes.forEach({ node in
            node.objectWillChange.sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
            .store(in: &nodesCancellables)
        })
    }
    
//    public func connect(_ wire: Wire, wireRemoved: WireRemovedHandler? = nil, wireAdded: WireAddedHandler? = nil) {
    public func connect(_ wire: Wire) {
        let output = nodes[portId: wire.output]
        let input = nodes[portId: wire.input]
        
        guard input.canConnectTo(port: output) else { return }
        // Remove any other wires connected to the input.
        wires = wires.filter { w in
            let result = w.input != wire.input
            if !result {
                let outputPort = nodes[portId: w.output]
                try? input.disconnect(from: outputPort)
                wireRemoved(w)
            }
            return result
        }
        wires.insert(wire)
        
        do {
            try input.connect(to: output)
        } catch {
            Logger().error("\(error.localizedDescription, privacy: .public)")
        }
        
        wireAdded(wire)
    }
    
    public func disconnect(_ wire: Wire) {
        let output = nodes[portId: wire.output]
        let input = nodes[portId: wire.input]
        
        try? input.disconnect(from: output)
        wires.remove(wire)
        wireRemoved(wire)
    }
    
    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
//    public func connect(_ output: OutputID, to input: InputID, wireRemoved: @escaping WireRemovedHandler, wireAdded: @escaping WireAddedHandler) {
    public func connect(_ output: OutputID, to input: InputID) {
        let wire = Wire(from: output, to: input)

//        connect(wire, wireRemoved: wireRemoved, wireAdded: wireAdded)
        connect(wire)
    }
}
