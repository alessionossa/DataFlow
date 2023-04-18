import Flow
import SwiftUI

class IntNode: Node {
    var id: NodeId = UUID()

class IntNode: BaseNode<IntNode.IntMiddleView> {
    
    struct IntMiddleView: View {
        @Binding var valueBinding: String
        
        var body: some View {
            HStack {
                TextField("Integer", text: $valueBinding)
            }
        }
    }

    @Published var value: Int? = nil
    
    var valueBinding: Binding<String> {
        Binding<String>(
            get: { self.value?.description ?? "" },
            set: { newValue in
                self.value = Int.init(newValue)
            }
        )
    }
    
    override init(name: String, position: CGPoint? = nil) {
        super.init(name: name, position: position)
        
        inputs = [
            Port(name: "Value", valueType: Int.self)
        ]
        
        outputs = [
            Port(name: "Value", valueType: Int.self)
        ]
        
        titleBarColor = .brown
        
        middleView = IntMiddleView(valueBinding: valueBinding)
        
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
    
    let nodes: [any Node] = [int1, int2]
    
    let wires = Set([
        Wire(from: OutputID(int1, \.[0]), to: InputID(int2, \.[0]))
    ])
    
    let patch = Patch(nodes: nodes.asAnyNodeSet, wires: wires)
    patch.recursiveLayout(nodeId: int2.id, at: CGPoint(x: 800, y: 50))
    return patch
}

/// Bit of a stress test to show how Flow performs with more nodes.
func randomPatch() -> Patch {
    var randomNodes: [any Node] = []
    for n in 0 ..< 50 {
        let randomPoint = CGPoint(x: 1000 * Double.random(in: 0 ... 1),
                                  y: 1000 * Double.random(in: 0 ... 1))
        randomNodes.append(IntNode(name: "Integer \(n)", position: randomPoint))
    }

    var randomWires: Set<Wire> = []
    for n in 0 ..< 50 {
        randomWires.insert(
            Wire(
                from: OutputID(randomNodes[n], \.[0]),
                to: InputID(randomNodes[Int.random(in: 0 ... 49)], \.[0])
            )
        )
    }
    return Patch(nodes: randomNodes.asAnyNodeSet, wires: randomWires)
}

struct ContentView: View {
    @StateObject var patch = simplePatch()
    @State var selection = Set<NodeId>()

    func addNode() {
        let newNode = IntNode(name: "Integer")
        patch.nodes.insert(AnyNode(newNode))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NodeEditor(patch: patch, selection: $selection)
                .onWireAdded { wire in
                    print("Added wire: \(wire)")
                }
                .onWireRemoved { wire in
                    print("Removed wire: \(wire)")
                }
            Button("Add Node", action: addNode).padding()
        }
    }
    
}
