//
//  TriggerButtonNode.swift
//  
//
//  Created by Alessio Nossa on 20/04/2023.
//

import Foundation

public class TriggerButtonNode: BaseNode {
    
    struct TriggerMiddleView: View {
        @ObservedObject var node: TriggerButtonNode
        
        var body: some View {
            Button("Action!", action: {
                node.trigger.send(ValueUpdate(()))
            })
                .frame(width: 100)
        }
    }

    var trigger = PassthroughSubject<ValueUpdate<Void>?, Never>()
    
    override public init(name: String, position: CGPoint? = nil) {
        super.init(name: name, position: position)
        
        outputs = [
            Port(name: "Trigger", type: .output, valueType: Void.self, parentNodeId: id)
        ]
        
        titleBarColor = .brown
        
        middleView = AnyView(TriggerMiddleView(node: self))
        
        if let intOutput = outputs[0] as? Flow.Port<Void> {
            trigger.assign(to: &intOutput.$valueUpdate)
        }
    }
}
