import Flow
import PlaygroundSupport
import SwiftUI

func simplePatch() -> Patch {
    let midiSource1 = Node(name: "MIDI source",
                          outputs: [
                              Port(name: "out ch. 1", type: .midi),
                              Port(name: "out ch. 2", type: .midi),
                          ])
    let generator2 = Node(name: "generator",
                         inputs: [
                             Port(name: "midi in", type: .midi),
                             Port(name: "CV in", type: .control),
                         ],
                         outputs: [Port(name: "out")])
    let processor3 = Node(name: "processor 3", inputs: ["in"], outputs: ["out"])
    let generator4 = Node(name: "generator",
                         inputs: [
                             Port(name: "midi in", type: .midi),
                             Port(name: "CV in", type: .control),
                         ],
                         outputs: [Port(name: "out")])
    let processor5 = Node(name: "processor", inputs: ["in"], outputs: ["out"])
    let mixer6 = Node(name: "mixer", inputs: ["in1", "in2"], outputs: ["out"])
    let output7 = Node(name: "output", inputs: ["in"])

    let nodes = [midiSource1, generator2, processor3, generator4, processor5, mixer6, output7]

    let wires = Set([
        Wire(from: OutputID(midiSource1, \.[0]), to: InputID(generator2, \.[0])),
        Wire(from: OutputID(midiSource1, \.[1]), to: InputID(generator4, \.[0])),
        Wire(from: OutputID(generator2, \.[0]), to: InputID(processor3, \.[0])),
        Wire(from: OutputID(processor3, \.[0]), to: InputID(mixer6, \.[0])),
        Wire(from: OutputID(generator4, \.[0]), to: InputID(processor5, \.[0])),
        Wire(from: OutputID(generator4, \.[0]), to: InputID(processor5, \.[0])),
        Wire(from: OutputID(processor5, \.[0]), to: InputID(mixer6, \.[1])),
        Wire(from: OutputID(mixer6, \.[0]), to: InputID(output7, \.[0]))
    ])

    var patch = Patch(nodes: Set(nodes), wires: wires)
    patch.recursiveLayout(nodeId: output7.id, at: CGPoint(x: 1000, y: 50))
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
