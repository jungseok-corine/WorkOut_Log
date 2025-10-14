//
//  Item.swift
//  WorkOut Log
//
//  Created by 오정석 on 14/10/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
