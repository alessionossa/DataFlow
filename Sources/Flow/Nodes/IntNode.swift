//
//  IntNode.swift
//  
//
//  Created by Alessio Nossa on 20/04/2023.
//

import SwiftUI

public class IntNode: BaseNode {
    
    struct IntMiddleView: View {
        @ObservedObject var node: IntNode
        
        var valueBinding: Binding<String> {
            Binding<String>(
                get: {
                    guard let value = node.valueUpdate?.value else { return "" }
                    return String(value)
                },
                set: { newValue in
                    self.node.valueUpdate = ValueUpdate(Int.init(newValue))
                }
            )
        }
        
        var body: some View {
            TextField("Integer", text: valueBinding)
#if os(iOS)
                .keyboardType(.numberPad)
#endif
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }
    }

//    @Published var value: Int? = nil
    @Published var valueUpdate: ValueUpdate<Int>? = nil
    
    override public init(name: String, position: CGPoint? = nil) {
        super.init(name: name, position: position)
        
        inputs = [
            Port(name: "Value", type: .input, valueType: Int.self, parentNodeId: id)
        ]
        
        outputs = [
            Port(name: "Value", type: .output, valueType: Int.self, parentNodeId: id)
        ]
        
        titleBarColor = Color(UIColor.systemMint)
        
        middleView = AnyView(IntMiddleView(node: self))
        
        if let intInput = inputs[0] as? Port<Int> {
//            intInput.$value.assign(to: &$value)
            intInput.$valueUpdate.assign(to: &$valueUpdate)
        }
        
        if let intOutput = outputs[0] as? Port<Int> {
            $valueUpdate.assign(to: &intOutput.$valueUpdate)
        }
    }
}
