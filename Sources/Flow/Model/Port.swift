// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import Combine
import SwiftUI

/// Ports are identified by index within a node.
public typealias PortIndex = Int
public typealias PortId = UUID

/// Uniquely identifies an input by indices.
public struct InputID: Equatable, Hashable {
    public let nodeId: NodeId
    public var portId: PortId

    /// Initialize an output
    /// - Parameters:
    ///   - node: The node the input belongs
    ///   - portKeyPath: The keypath to access the Port on Node's input
    public init(_ node: any Node, _ portKeyPath: KeyPath<[any PortProtocol], any PortProtocol>) {
        self.nodeId = node.id
        self.portId = node.inputs[keyPath: portKeyPath].id
    }
    
    /// Initialize an input
    /// - Parameters:
    ///   - nodeId: The id of the node the input belongs to
    ///   - portId: The id of the input port
    public init(_ nodeId: NodeId, _ portId: PortId) {
        self.nodeId = nodeId
        self.portId = portId
    }
}

/// Uniquely identifies an output by indices.
public struct OutputID: Equatable, Hashable {
    public let nodeId: NodeId
    public var portId: PortId

    /// Initialize an output
    /// - Parameters:
    ///   - node: The node the output belongs
    ///   - portKeyPath: The keypath to access the Port on Node's outputs
    public init(_ node: any Node, _ portKeyPath: KeyPath<[any PortProtocol], any PortProtocol>) {
        self.nodeId = node.id
        self.portId = node.outputs[keyPath: portKeyPath].id
    }
    
    /// Initialize an output
    /// - Parameters:
    ///   - nodeId: The id of the node the output belongs to
    ///   - portId: The id of the output port
    public init(_ nodeId: NodeId, _ portId: PortId) {
        self.nodeId = nodeId
        self.portId = portId
    }
}

/// Support for different types of connections.
///
/// Some graphs have different types of ports which can't be
/// connected to each other. Here we offer two common types
/// as well as a custom option for your own types. XXX: not implemented yet
public enum PortType: Equatable, Hashable {
    case input
    case output
}

public enum PortValue: Equatable {
    public static func == (lhs: PortValue, rhs: PortValue) -> Bool {
        switch (lhs, rhs) {
        case (.int(_), .int(_)): return true
        case (.string, .string): return true
        case (.signal, .signal): return true
        default: return false
        }
    }
    
    case int(Published<Int?>.Publisher)
    case string(Published<String?>.Publisher)
    case signal
}

public protocol PortProtocol: AnyObject, ObservableObject, Identifiable {
    associatedtype T: Any
    
    var id: PortId { get }
    var name: String { get }
    var type: PortType { get }
    var frame: CGRect? { get set }
//    var value: T? { get set }
    var valueUpdate: ValueUpdate<T>? { get set }
    var valueType: T.Type { get }
    
    var nodeId: NodeId { get }
    
    var connectedToInputs: Set<InputID> { get }
    var connectedToOutputs: Set<OutputID> { get }
    
    func canConnectTo(port: any PortProtocol) -> Bool
    func connect(to port: any PortProtocol) throws
    func disconnect(from port: any PortProtocol) throws
    func forwardUpdatesTo(objectPublisher: ObservableObjectPublisher) -> AnyCancellable
    
    func color(with style: NodeEditor.Style, isOutput: Bool) -> Color?
    func gradient(with style: NodeEditor.Style) -> Gradient?
}

/// Information for either an input or an output.
public class Port<T>: Identifiable, ObservableObject, PortProtocol {
    
    public let id: PortId = UUID()
    public let name: String
    public let type: PortType
    @Published public var frame: CGRect?
//    @Published public var value: T?
    @Published public var valueUpdate: ValueUpdate<T>?
    public var valueType: T.Type
    
    public var nodeId: NodeId
    
    private(set) public var connectedToInputs = Set<InputID>()
    private(set) public var connectedToOutputs = Set<OutputID>()
    
    private var portValueCancellable: Cancellable?
    
    enum PortError: Error {
        case valueTypeMismatch
        case wrongPortType
    }
    
//    var valueContainer: PortValue
    
    public init(name: String, type: PortType, valueType: T.Type, parentNodeId: NodeId) {
        self.name = name
        self.type = type
        self.valueType = valueType
        
        self.nodeId = parentNodeId
    }
    
    public func canConnectTo(port: any PortProtocol) -> Bool {
        if port is Port<T> {
            return true
        }
        
        return false
    }
    
    public func connect(to outputPort: any PortProtocol) throws {
        guard type == .input else { throw PortError.wrongPortType }
        guard let port = outputPort as? Port<T> else { throw PortError.valueTypeMismatch }
//        self.portValueCancellable = port.$value.removeDuplicates().sink { [weak self] newValue in
//            self?.value = newValue
//        }
        self.portValueCancellable = port.$valueUpdate.removeDuplicates().sink { [weak self] newValue in
            self?.valueUpdate = newValue
        }
        
        connectedToOutputs.insert(OutputID(port.nodeId, port.id))
        port.connectedToInputs.insert(InputID(nodeId, id))
    }
    
    public func disconnect(from outputPort: any PortProtocol) throws {
        guard type == .input else { throw PortError.wrongPortType }
        guard let port = outputPort as? Port<T> else { throw PortError.valueTypeMismatch }
        
        connectedToOutputs.remove(OutputID(port.nodeId, port.id))
        port.connectedToInputs.remove(InputID(nodeId, id))
        
        portValueCancellable?.cancel()
        portValueCancellable = nil
    }
    
    public func forwardUpdatesTo(objectPublisher: ObservableObjectPublisher) -> AnyCancellable {
        self.objectWillChange.sink { [weak objectPublisher] _ in
            objectPublisher?.send()
        }
    }
}

extension Port {
    /// Returns input or output port color for the specified port type.
    public func color(with style: NodeEditor.Style, isOutput: Bool) -> Color? {
        switch valueType {
        case is Int.Type:
            return isOutput ? style.intWire.outputColor : style.intWire.inputColor
        default:
            return isOutput ? style.defaultWire.outputColor : style.defaultWire.inputColor
        }
    }
    
    /// Returns port gradient for the specified port type.
    public func gradient(with style: NodeEditor.Style) -> Gradient? {
        switch valueType {
        case is Int.Type:
            return style.intWire.gradient
        default:
            return style.defaultWire.gradient
        }
    }
}

//public extension Sequence where Element == any PortProtocol { // doesn't work
public extension Sequence where Element == any PortProtocol {
    subscript(withId id: PortId) -> any PortProtocol {
        get {
            guard let port = first(where: { $0.id == id }) else {
                fatalError("Port with identifier \(id.uuidString) not found")
            }
            
            return port
        }
    }
}
