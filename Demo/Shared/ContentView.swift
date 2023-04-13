import Flow
import SwiftUI

func simplePatch() -> Patch {
    let generator1 = Node(name: "generator", titleBarColor: Color.cyan, outputs: ["out"])
    let processor2 = Node(name: "processor", titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
    let generator3 = Node(name: "generator", titleBarColor: Color.cyan, outputs: ["out"])
    let processor4 = Node(name: "processor", titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
    let mixer5 = Node(name: "mixer", titleBarColor: Color.gray, inputs: ["in1", "in2"], outputs: ["out"])
    let output6 = Node(name: "output", titleBarColor: Color.purple, inputs: ["in"])

    let nodes = Set([generator1, processor2, generator3, processor4, mixer5, output6])

    let wires = Set([Wire(from: OutputID(generator1, \.[0]), to: InputID(processor2, \.[0])),
        Wire(from: OutputID(processor2, \.[0]), to: InputID(mixer5, \.[0])),
        Wire(from: OutputID(generator3, \.[0]), to: InputID(processor4, \.[0])),
        Wire(from: OutputID(processor4, \.[0]), to: InputID(mixer5, \.[1])),
        Wire(from: OutputID(mixer5, \.[0]), to: InputID(output6, \.[0]))
    ])

    var patch = Patch(nodes: nodes, wires: wires)
    patch.recursiveLayout(nodeId: output6.id, at: CGPoint(x: 800, y: 50))
    return patch
}

/// Bit of a stress test to show how Flow performs with more nodes.
func randomPatch() -> Patch {
    var randomNodes: [Node] = []
    for n in 0 ..< 50 {
        let randomPoint = CGPoint(x: 1000 * Double.random(in: 0 ... 1),
                                  y: 1000 * Double.random(in: 0 ... 1))
        randomNodes.append(Node(name: "node\(n)",
                                position: randomPoint,
                                inputs: ["In"],
                                outputs: ["Out"]))
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
    return Patch(nodes: Set(randomNodes), wires: randomWires)
}

struct ContentView: View {
    @StateObject var patch = simplePatch()
    @State var selection = Set<NodeId>()

    func addNode() {
        let newNode = Node(name: "processor", titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
        patch.nodes.insert(newNode)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NodeEditor(patch: patch, selection: $selection)
            Button("Add Node", action: addNode).padding()
        }
    }
}
