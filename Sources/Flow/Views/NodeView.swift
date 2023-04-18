//
//  NodeView.swift
//  
//
//  Created by Alessio Nossa on 18/04/2023.
//

import SwiftUI

struct NodeView: View {
    @Binding var node: BaseNode
    
    var body: some View {
            VStack {
                HStack {
                    Text(node.name)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                
                HStack(alignment: .top, spacing: 8) {
                    VStack {
                        ForEach(node.inputs, id: \.id) { input in
                            ConnectorView(connector: input)
                        }
                    }

                    node.middleView

                    VStack {
                        ForEach(node.outputs, id: \.id) { output in
                            ConnectorView(connector: output)
                        }
                    }
                }
                .padding()
            }
            .background(.white)
            .cornerRadius(8)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named(NodeEditor.kEditorCoordinateSpaceName))
                    .onChanged { value in
                        node.position? += value.translation
                    }
                    .onEnded({ value in
                        node.position?.x += value.translation.width
                        node.position?.y += value.translation.height
                    })
            )
            .shadow(radius: 5)
            .position(node.position ?? .zero)

    }
    
    
}

struct NodeView_Previews: PreviewProvider {
    static func getTestNode(proxy: GeometryProxy) -> BaseNode {
        let node = BaseNode(name: "Test", position: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2))
        node.setMiddleView {
            Text("Middle view")
        }
        
        return node
    }
    
    static var previews: some View {
        GeometryReader { proxy in
            NodeView(node: .constant(getTestNode(proxy: proxy)))
                
        }
        .background(.clear)
        .previewLayout(.sizeThatFits)
//        .previewLayout(.fixed(width: 250, height: 150))

    }
}
