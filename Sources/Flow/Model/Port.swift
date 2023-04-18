// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import Combine

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
    case control
    case signal
    case midi
    case custom(String)
}

public protocol PortProtocol: AnyObject, ObservableObject {
    associatedtype T: Any
    
    var id: PortId { get }
    var name: String { get }
    var type: PortType { get }
    var value: T? { get set }
    var valueType: T.Type { get }
    
    func setPublisher(from port: (any PortProtocol)?) throws
}

/// Information for either an input or an output.
public class Port<T>: Identifiable, PortProtocol where T: Equatable {
    public let id: PortId = UUID()
    public let name: String
    public let type: PortType
    @Published public var value: T?
    public var valueType: T.Type
    
    private var portValueCancellable: Cancellable?
    
    enum PortError: Error {
        case valueTypeMismatch
    }
    
    public init(name: String, type: PortType = .signal, publisher: Published<T?>.Publisher? = nil, valueType: T.Type) {
        self.name = name
        self.type = type
        self.valueType = valueType
    }
    
    public func setPublisher(from port: (any PortProtocol)?) throws {
        if let port {
            guard let port = port as? Port<T> else { throw PortError.valueTypeMismatch }
            self.portValueCancellable = port.$value.removeDuplicates().sink { [weak self] newValue in
                self?.value = newValue
            }
        } else {
            portValueCancellable?.cancel()
            portValueCancellable = nil
        }
    }
}

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
