import Flow
import PlaygroundSupport
import SwiftUI

class IntNode: Node {
    var id: NodeId = UUID()

    var name: String
    var position: CGPoint?
    var titleBarColor: Color = .brown
    var locked: Bool = false

    var inputs: PortsContainer = PortsContainer([
        Port(name: "Value", valueType: Int.self)
    ])
    
    var outputs: PortsContainer = PortsContainer([
        Port(name: "Value", valueType: Int.self)
    ])

    @Published var value: Int? = nil
    
    @State var valueState: Int? = nil
    
    var valueBinding: Binding<String> {
        Binding<String>(
            get: { self.value?.description ?? "" },
            set: { newValue in
                self.value = Int.init(newValue)
            }
        )
    }

    var middleView: (some View)? {
        HStack {
            Text("The connected value is \(value?.description ?? "")")
            TextField("Integer", text: valueBinding)
        }
    }
    
    init(name: String, position: CGPoint? = nil) {
        self.name = name
        self.position = position
        
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
