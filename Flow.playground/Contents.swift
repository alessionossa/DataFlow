import Flow
import PlaygroundSupport
import SwiftUI

class IntNode: BaseNode {
    
    struct IntMiddleView: View {
        @ObservedObject var node: IntNode
        
        var valueBinding: Binding<String> {
            Binding<String>(
                get: {
                    guard let value = node.value else { return "" }
                    return String(value)
                },
                set: { newValue in
                    self.node.value = Int.init(newValue)
                }
            )
        }
        
        var body: some View {
            TextField("Integer", text: valueBinding)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
        }
    }

    @Published var value: Int? = nil
    
    override init(name: String, position: CGPoint? = nil) {
        super.init(name: name, position: position)
        
        inputs = [
            Port(name: "Value", type: .input, valueType: Int.self, parentNodeId: id)
        ]
        
        outputs = [
            Port(name: "Value", type: .output, valueType: Int.self, parentNodeId: id)
        ]
        
        titleBarColor = .brown
        
        middleView = AnyView(IntMiddleView(node: self))
        
        if let intInput = inputs[0] as? Flow.Port<Int> {
            intInput.$value.assign(to: &$value)
        }
        
        if let intOutput = outputs[0] as? Flow.Port<Int> {
            $value.assign(to: &intOutput.$value)
        }
    }
}

func simplePatch() -> Patch {
    let int1 = IntNode(name: "Integer 1")
    let int2 = IntNode(name: "Integer 2")
    
    let nodes = [int1, int2]
    
    let wires = Set([
        Wire(from: OutputID(int1, \.[0]), to: InputID(int2, \.[0]))
    ])
    
    let patch = Patch(nodes: nodes, wires: wires)
    patch.recursiveLayout(nodeId: int2.id, at: CGPoint(x: 600, y: 50))
    return patch
}

struct FlowDemoView: View {
    @StateObject var patch = simplePatch()
    @State var selection = Set<NodeId>()

    public var body: some View {
        NodeEditor(patch: patch, selection: $selection)
            .nodeColor(.secondary)
            .portColor(for: .control, .gray)
            .portColor(for: .signal, Gradient(colors: [.yellow, .blue]))
            .portColor(for: .midi, .red)

            .onNodeMoved { index, location in
                print("Node at index \(index) moved to \(location)")
            }
            .onWireAdded { wire in
                print("Added wire: \(wire)")
            }
            .onWireRemoved { wire in
                print("Removed wire: \(wire)")
            }
    }
}

PlaygroundPage.current.setLiveView(FlowDemoView().frame(width: 1200, height: 500))
PlaygroundPage.current.needsIndefiniteExecution = true
