//
//  ModalType.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 11/12/24.
//


import SwiftUI

enum ModalType: Identifiable {
    case add
    case edit(workoutId: UUID)

    var id: Int {
        switch self {
        case .add:
            return 0
        case .edit(_):
            return 1
        }
    }
}
