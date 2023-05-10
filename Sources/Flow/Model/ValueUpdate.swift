//
//  ValueUpdate.swift
//  
//
//  Created by Alessio Nossa on 20/04/2023.
//

import Foundation

public struct ValueUpdate<T>: Identifiable, Equatable {
    public let id = UUID()
    public let value: T?
    
    public init(_ value: T?) {
        self.value = value
    }
    
    public static func == (lhs: ValueUpdate<T>, rhs: ValueUpdate<T>) -> Bool {
        lhs.id == rhs.id
    }
}
