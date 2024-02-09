//
//  ModalType.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/6/24.
//

import SwiftUI

enum ModalType: Identifiable {
    case add
    case edit(workoutId: UUID, originalTitle: String)

    var id: Int {
        switch self {
        case .add:
            return 0
        case .edit(_, _):
            return 1
        }
    }
}

