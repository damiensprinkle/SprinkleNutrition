import SwiftUI

class FocusManager: ObservableObject {
    @Published var isAnyTextFieldFocused: Bool = false
    @Published var currentlyFocusedField: FocusableField?
    
    func clearFocus() {
        currentlyFocusedField = nil
    }
    
    func setFocus(to field: FocusableField) {
        currentlyFocusedField = field
    }
}


enum FocusableField: Hashable {
    case distance
    case time
    case weight
    case reps
}

enum FocusableFieldUserForm: Hashable {
    case name
}

