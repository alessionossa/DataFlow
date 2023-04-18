// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import SwiftUI

/// Nodes are identified by index in `Patch/nodes``.
public typealias NodeIndex = Int
public typealias NodeId = UUID

/// Nodes are identified by index in ``Patch/nodes``.
///
/// Using indices as IDs has proven to be easy and fast for our use cases. The ``Patch`` should be
/// generated from your own data model, not used as your data model, so there isn't a requirement that
/// the indices be consistent across your editing operations (such as deleting nodes).
public protocol Node: AnyObject, ObservableObject, Hashable, Equatable {
    associatedtype MiddleContent: View
    
    var id: NodeId { get }
    var name: String { get set }
    var position: CGPoint? { get set }
    var titleBarColor: Color { get set }

    /// Is the node position fixed so it can't be edited in the UI?
    var locked: Bool { get set }

    var inputs: [any PortProtocol] { get }
    @ViewBuilder var middleView: MiddleContent? { get }
    var outputs: [any PortProtocol] { get }
    
    func indexOfOutput(_ port: OutputID) -> Array<PortProtocol>.Index?
    
    func indexOfInput(_ port: InputID) -> Array<PortProtocol>.Index?
}

extension Node {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func indexOfOutput(_ port: OutputID) -> Array<PortProtocol>.Index? {
        self.outputs.firstIndex { $0.id == port.portId }
    }
    
    public func indexOfInput(_ port: InputID) -> Array<PortProtocol>.Index? {
        self.inputs.firstIndex { $0.id == port.portId }
    }
}

public class AnyNode: Node, Hashable {
    private var node: any Node
    
    public var id: NodeId { node.id }
    
    public var name: String {
        get { node.name }
        set { node.name = newValue }
    }
    
    public var position: CGPoint? {
        get { node.position }
        set { node.position = newValue }
    }
    
    public var titleBarColor: Color {
        get { node.titleBarColor }
        set { node.titleBarColor = newValue }
    }
    
    public var locked: Bool {
        get { node.locked }
        set { node.locked = newValue }
    }
    
    public var inputs: [any PortProtocol] {
        get { node.inputs }
    }
    
    public var outputs: [any PortProtocol] {
        get { node.outputs }
    }
    
    public var middleView: AnyView? {
        if let nodeMiddleView = node.middleView {
            return AnyView(nodeMiddleView)
        } else {
            return nil
        }
    }
    
    public init(_ node: some Node) {
        self.node = node
    }
}

public extension Sequence where Element: Node {
    subscript(withId id: NodeId) -> Element {
        get {
            guard let node = first(where: { $0.id == id }) else {
                fatalError("Node with identifier \(id.uuidString) not found")
            }
            
            return node
        }
    }
    
    subscript(portId outputId: OutputID) -> any PortProtocol {
        get {
            return self[withId: outputId.nodeId]
                .outputs[withId: outputId.portId]
        }
    }
    
    subscript(portId inputId: InputID) -> any PortProtocol {
        get {
            return self[withId: inputId.nodeId]
                .inputs[withId: inputId.portId]
        }
    }
}

public extension Sequence where Element == any Node {
    var asAnyNodeSet: Set<AnyNode> {
        Set(self.map({ node in
            AnyNode(node)
        }))
    }
}
