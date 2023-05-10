//
//  NodeView.swift
//  
//
//  Created by Alessio Nossa on 18/04/2023.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct NodeView: View {
    @ObservedObject var node: BaseNode
    
    var gestureState: GestureState<NodeEditor.DragInfo>
    
    @State private var previousPosition: CGPoint?
    
    var dragging: Bool {
        if case let .node(draggedId, _) = gestureState.wrappedValue {
            let draggingNode = draggedId == node.id
            return draggingNode
        }
        
        return false
    }
    
    var currentNodePosition: CGPoint? {
        if dragging, case let .node(_, offset) = gestureState.wrappedValue {
            return (node.position ?? .zero) + offset
        }
        return node.position
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                HStack {
                    Text(node.name)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(node.titleBarColor)
                .gesture(dragGesture)
                
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .center) {
                        ForEach(node.inputs, id: \.id) { input in
                            ConnectorView(connector: input, gestureState: gestureState)
                        }
                    }
                    .padding(.leading, 8)
                    
                    if let middleView = node.middleView {
                        AnyView(middleView)
                    }
                    
                    VStack(alignment: .center) {
                        ForEach(node.outputs, id: \.id) { output in
                            ConnectorView(connector: output, gestureState: gestureState)
                        }
                    }
                    .padding(.trailing, 8)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
#if canImport(UIKit)
            .background(
                Color(UIColor.systemBackground)
                    .opacity(0.6)
            )
#endif
#if os(macOS)
            .background(
                Color(NSColor.textBackgroundColor)
                    .opacity(0.6)
            )
#endif
            .cornerRadius(8)
            .shadow(radius: 5)
            .scaleEffect(dragging ? 1.1 : 1.0)
            .fixedSize()
            .position(currentNodePosition ?? .zero)
            .animation(.easeInOut, value: dragging)
            .onAppear {
                node.frame = geometryProxy.frame(in: .named(NodeEditor.kEditorCoordinateSpaceName))
            }
            .onChange(of: geometryProxy.frame(in: .named(NodeEditor.kEditorCoordinateSpaceName))) { newValue in
                if newValue != node.frame {
                    node.frame = newValue
                }
            }
        }
    }
    
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(NodeEditor.kEditorCoordinateSpaceName))
            .updating(gestureState, body: { dragValue, dragState, transaction in
                if gestureState.wrappedValue == NodeEditor.DragInfo.none
                    || dragging {
                    dragState = NodeEditor.DragInfo.node(id: node.id, offset: dragValue.translation)
                }
            })
            .onChanged { value in
                if dragging && previousPosition == nil {
                    previousPosition = node.position ?? .zero
                }
            }
            .onEnded { value in
                guard let previousPosition else { return }
                node.position = previousPosition + value.translation

                self.previousPosition = nil
            }
    }
    
    
}

struct NodeView_Previews: PreviewProvider {
    static func getTestNode(proxy: GeometryProxy) -> BaseNode {
        let node = BaseNode(name: "Test", position: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2))
        
        return node
    }
    
    static var previews: some View {
        GeometryReader { proxy in
            NodeView(node: getTestNode(proxy: proxy), gestureState: .init(initialValue: .none))
                
        }
        .background(.clear)
        .previewLayout(.sizeThatFits)
//        .previewLayout(.fixed(width: 250, height: 150))

    }
}
