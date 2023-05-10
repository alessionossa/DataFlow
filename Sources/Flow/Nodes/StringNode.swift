//
//  StringNode.swift
//  
//
//  Created by Alessio Nossa on 20/04/2023.
//

import SwiftUI
import Combine

public class StringNode: BaseNode {
    
    struct StringMiddleView: View {
        @ObservedObject var node: StringNode
        
        var body: some View {
            Text("\(node.valueUpdate?.value ?? "")")
                .font(.callout.monospaced())
                .lineLimit(nil)
                .frame(width: 150)
        }
    }

    @Published var valueUpdate: ValueUpdate<String>? = nil
    
    override public init(name: String, position: CGPoint? = nil) {
        super.init(name: name, position: position)
        
        inputs = [
            Port(name: "Value", type: .input, valueType: String.self, parentNodeId: id)
        ]
        
        outputs = [
            Port(name: "Value", type: .output, valueType: String.self, parentNodeId: id)
        ]
        
        titleBarColor = Color(UIColor.systemTeal)
        
        middleView = AnyView(StringMiddleView(node: self))
        
        if let intInput = inputs[0] as? Port<String> {
            intInput.$valueUpdate.assign(to: &$valueUpdate)
        }
        
        if let intOutput = outputs[0] as? Port<String> {
            $valueUpdate.assign(to: &intOutput.$valueUpdate)
        }
    }
}
