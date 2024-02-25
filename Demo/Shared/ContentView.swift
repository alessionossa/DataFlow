import Flow
import SwiftUI
import Combine


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

/// Bit of a stress test to show how Flow performs with more nodes.
func randomPatch() -> Patch {
    var randomNodes: [BaseNode] = []
    
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
    return Patch(nodes: randomNodes, wires: randomWires)
}

struct ContentView: View {
    @StateObject var patch = simplePatch()
    @State var selection = Set<NodeId>()

    func addNode(type: DemoNodeType) {
        let newNode: BaseNode
        switch type {
        case .integer:
            newNode = IntNode(name: "Integer")
        case .string:
            let stringNode = StringNode(name: "")
            stringNode.setValue("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent at tortor egestas ante ultricies lobortis. Cras fringilla, turpis id volutpat mollis, ligula metus egestas ante, sed fringilla ex sapien in elit.")
            newNode = stringNode
        case .trigger:
            newNode = TriggerButtonNode(name: "Trigger")
        }
        patch.nodes.append(newNode)
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
            
            Menu("Add node") {
                Button(action: { addNode(type: .integer) }) {
                    Label("Add Integer Node", systemImage: "number")
                }
                
                Button(action: { addNode(type: .string) }) {
                    Label("Add Text Node", systemImage: "textformat")
                }
                
                Button(action: { addNode(type: .trigger) }) {
                    Label("Add Trigger Node", systemImage: "button.programmable")
                }
            }
            .padding()
        }
    }
    
}

enum DemoNodeType {
    case integer, string, trigger
}
