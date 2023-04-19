//
//  ConnectorView.swift
//  
//
//  Created by Alessio Nossa on 18/04/2023.
//

import SwiftUI

struct ConnectorView: View {
    
    @EnvironmentObject var patch: Patch
    var connector: any PortProtocol
    
    var gestureState: GestureState<NodeEditor.DragInfo>
    
    var isDragging: Bool {
        if case let NodeEditor.DragInfo.wire(outputId, _, _, _) = gestureState.wrappedValue {
            return (outputId.portId == connector.id) && (outputId.nodeId == connector.nodeId)
        }
        return false
    }
    
    var isPossibleInput: Bool {
        if case let NodeEditor.DragInfo.wire(_, _, _, possibleInputId) = gestureState.wrappedValue,
           let possibleInputId {
            return (possibleInputId.portId == connector.id) && (possibleInputId.nodeId == connector.nodeId)
        }
        return false
    }
    
    var isConnected: Bool {
        switch connector.type {
        case .input:
            return !connector.connectedToOutputs.isEmpty
        case .output:
            return !connector.connectedToInputs.isEmpty
        }
    }
    
    @State private var previousPosition: CGPoint?
    @State private var draggingWire: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            if connector.type == .output {
                Text(connector.name)
                    .font(.caption)
            }
            
            ZStack(alignment: .center) {
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            connector.frame = proxy.frame(in: .named(NodeEditor.kEditorCoordinateSpaceName))
                        }
                        .onChange(of: proxy.frame(in: .named(NodeEditor.kEditorCoordinateSpaceName))) { newValue in
                            connector.frame = newValue
                        }
                }
                
                if isConnected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                }
                
            }
            .frame(width: 20, height: 20)
            .scaleEffect((isDragging || isPossibleInput) ? 1.2 : 1.0)
            .gesture(dragGesture)
            
            if connector.type == .input {
                Text(connector.name)
                    .font(.caption)
            }
        }
        .animation(.easeInOut, value: isDragging)
        .animation(.easeInOut, value: isPossibleInput)
        .animation(.easeInOut, value: isConnected)
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(NodeEditor.kEditorCoordinateSpaceName))
            .updating(gestureState, body: { dragValue, dragState, transaction in
                switch connector.type {
                case .input:
                    guard let attachedWire = patch.wires.first(where: { $0.input.portId == connector.id }) else { return }
                    
                    guard let connectorFrame = connector.frame,
                          let outputFrame = patch.nodes[portId: attachedWire.output].frame
                    else { return }
                    
                    // (inputCenter - outputCenter) + dragValue.translation - (inputCenter - dragValue.startLocation)
                    let originDifference = connectorFrame.center - dragValue.startLocation
                    let offset = (connectorFrame.center - outputFrame.center) + dragValue.translation - originDifference
                    let possibleInputPortId = findPossibleInputPortId(outputFrame: outputFrame, offset: offset)
                    
                    dragState = .wire(output: attachedWire.output,
                                      offset: offset,
                                      hideWire: attachedWire,
                                      possibleInputId: possibleInputPortId)
                case .output:
                    let outputId = OutputID(connector.nodeId, connector.id)
                    guard let connectorFrame = connector.frame else { return }
                    let originDifference = connectorFrame.center - dragValue.startLocation
                    let offset = dragValue.translation - originDifference
                    let possibleInputPortId = findPossibleInputPortId(outputFrame: connectorFrame, offset: offset)
                    
                    dragState = NodeEditor.DragInfo.wire(output: outputId, offset: offset, possibleInputId: possibleInputPortId)
                }
            })
            .onEnded { value in
                switch connector.type {
                case .input:
                    guard let attachedWire = patch.wires.first(where: { $0.input.portId == connector.id }) else { return }
                    let outputPort = patch.nodes[portId: attachedWire.output]
                    guard let connectorFrame = connector.frame,
                          let outputFrame = outputPort.frame
                    else { return }
                    
                    // (inputCenter - outputCenter) + dragValue.translation - (inputCenter - dragValue.startLocation)
                    let originDifference = connectorFrame.center - value.startLocation
                    let offset = (connectorFrame.center - outputFrame.center) + value.translation - originDifference
                    if let possibleInputPort = findPossibleInputPort(outputFrame: outputFrame, offset: offset) {
                        let outputId = OutputID(outputPort.nodeId, outputPort.id)
                        let inputId = InputID(possibleInputPort.nodeId, possibleInputPort.id)
                        let newWire = Wire(from: outputId, to: inputId)
                        patch.connect(newWire)
                    } else {
                        patch.disconnect(attachedWire)
                    }
                case .output:
                    guard let connectorFrame = connector.frame else { return }
                    let originDifference = connectorFrame.center - value.startLocation
                    let offset = value.translation - originDifference
                    
                    if let possibleInputPort = findPossibleInputPort(outputFrame: connectorFrame, offset: offset) {
                        let outputId = OutputID(connector.nodeId, connector.id)
                        let inputId = InputID(possibleInputPort.nodeId, possibleInputPort.id)
                        let newWire = Wire(from: outputId, to: inputId)
                        patch.connect(newWire)
                    }
                }
            }
    }
    
    func findPossibleInputPort(outputFrame: CGRect, offset: CGSize) -> (any PortProtocol)? {
        let point = outputFrame.center + offset
        var inputPort: (any PortProtocol)?
        _ = patch.nodes.reversed().first { node in
            inputPort = node.inputs.first { inputPort in
                inputPort.frame?.contains(point) ?? false
            }
            return inputPort != nil
        }
        
        guard let inputPort, inputPort.canConnectTo(port: connector) else { return nil }
        return inputPort
    }
    
    func findPossibleInputPortId(outputFrame: CGRect, offset: CGSize) -> InputID? {
        guard let possibleInputPort = findPossibleInputPort(outputFrame: outputFrame, offset: offset) else {
            return nil
        }
        return InputID(possibleInputPort.nodeId, possibleInputPort.id)
    }
}

struct ConnectorView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        // ConnectorView(connector: )
    }
}
