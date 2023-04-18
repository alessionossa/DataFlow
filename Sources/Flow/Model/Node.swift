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

open class BaseNode: Node {
    public  var id: NodeId = UUID()
    
    public var name: String
    
    public var position: CGPoint?
    
    public var titleBarColor: Color = .mint
    
    public var locked: Bool = false
    
    open var inputs: [any PortProtocol] = []
    
    open var outputs: [any PortProtocol] = []
    
    private(set) public var middleView: AnyView?
    
    public init(name: String, position: CGPoint? = nil) {
        self.name = name
        self.position = position
        
    }
    
    public func setMiddleView(@ViewBuilder _ view: () -> (any View)? = { nil }) {
        if let view = view() {
            self.middleView = AnyView(view)
        } else {
            self.middleView = nil
        }
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
