//
//  StringNode.swift
//  
//
//  Created by Alessio Nossa on 20/04/2023.
//

import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class StringNode: BaseNode {
    
    struct StringMiddleView: View {
        @ObservedObject var node: StringNode
        
        var valueBinding: Binding<String> {
            Binding<String>(
                get: {
                    return node.valueUpdate?.value ?? ""
                },
                set: { newValue in
                    self.node.valueUpdate = ValueUpdate(newValue)
                }
            )
        }
        
        var body: some View {
            if #available(iOS 16.0, macOS 13.0, *) {
                TextField("Text", text: valueBinding, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2...6)
                    .font(.callout.monospaced())
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 192)
            } else {
                TextEditor(text: valueBinding)
                    .frame(minHeight: 40, maxHeight: 80)
                    .multilineTextAlignment(.leading)
                    .font(.callout.monospaced())
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 192)
                    .fixedSize(horizontal: true, vertical: true)
            }
            
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
        
        #if canImport(UIKit)
        titleBarColor = Color(UIColor.systemTeal)
        #elseif canImport(AppKit)
        titleBarColor = Color(NSColor.systemTeal)
        #endif
        
        middleView = AnyView(StringMiddleView(node: self))
        
        if let intInput = inputs[0] as? Port<String> {
            intInput.$valueUpdate.assign(to: &$valueUpdate)
        }
        
        if let intOutput = outputs[0] as? Port<String> {
            $valueUpdate.assign(to: &intOutput.$valueUpdate)
        }
    }
    
    public func setValue(_ newString: String) {
        self.valueUpdate = .init(newString)
    }
}
