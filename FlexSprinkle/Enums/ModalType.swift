//
//  ModalType.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/6/24.
//

import SwiftUI

enum ModalType: Identifiable {
    case add
    case edit(originalTitle: String)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let originalTitle):
            return "edit_\(originalTitle)"
        }
    }
}
