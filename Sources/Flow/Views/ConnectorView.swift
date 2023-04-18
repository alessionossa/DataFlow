//
//  ConnectorView.swift
//  
//
//  Created by Alessio Nossa on 18/04/2023.
//

import SwiftUI

struct ConnectorView: View {
    var connector: any PortProtocol
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 10, height: 10)
    }
}

struct ConnectorView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
        // ConnectorView(connector: )
    }
}
