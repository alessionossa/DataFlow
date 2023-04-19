// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
public struct NodeEditor: View {
    
    static let kEditorCoordinateSpaceName = "node-editor-coordinate-space"
    
    /// Data model.
    @ObservedObject var patch: Patch

    /// Selected nodes.
    @Binding var selection: Set<NodeId>

    /// State for all gestures.
    @GestureState var dragInfo = DragInfo.none

    /// Node moved handler closure.
    public typealias NodeMovedHandler = (_ index: NodeId,
                                         _ location: CGPoint) -> Void

    /// Called when a node is moved.
    var nodeMoved: NodeMovedHandler = { _, _ in }
    
    /// Handler for pan or zoom.
    public typealias TransformChangedHandler = (_ pan: CGSize, _ zoom: CGFloat) -> Void
    
    /// Called when the patch is panned or zoomed.
    var transformChanged: TransformChangedHandler = { _, _ in }

    /// Initialize the patch view with a patch and a selection.
    ///
    /// To define event handlers, chain their view modifiers: ``onNodeMoved(_:)``, ``onWireAdded(_:)``, ``onWireRemoved(_:)``.
    ///
    /// - Parameters:
    ///   - patch: Patch to display.
    ///   - selection: Set of nodes currently selected.
    public init(patch: Patch,
                selection: Binding<Set<NodeId>>,
                layout: LayoutConstants = LayoutConstants())
    {
        self.patch = patch
        _selection = selection
        self.layout = layout
    }

    /// Constants used for layout.
    var layout: LayoutConstants

    /// Configuration used to determine rendering style.
    public var style = Style()

    @State var pan: CGSize = .zero
    @State var zoom: Double = 1
    @State var mousePosition: CGPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)

    public var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollProxy in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    ZStack {
                        
                        Color.clear
                            .frame(width: 2000, height: 2000)
                        
                        
                        
                        Canvas { cx, size in
                            self.drawWires(cx: cx)
                            self.drawDraggedWire(cx: cx)
                            self.drawSelectionRect(cx: cx)
                        }.background(.green)
                        
                        ForEach(patch.nodes, id: \.id) { node in
                            NodeView(node: node, gestureState: $dragInfo)
                                .fixedSize()
                        }
                    }
                    .coordinateSpace(name: NodeEditor.kEditorCoordinateSpaceName)
                    
                }
            }
        }
//            WorkspaceView(pan: $pan, zoom: $zoom, mousePosition: $mousePosition)
//                #if os(macOS)
//                .gesture(commandGesture)
//                #endif
//                .gesture(dragGesture)
        .environmentObject(patch)
        .onChange(of: pan) { newValue in
            transformChanged(newValue, zoom)
        }
        .onChange(of: zoom) { newValue in
            transformChanged(pan, newValue)
        }
    }
}
