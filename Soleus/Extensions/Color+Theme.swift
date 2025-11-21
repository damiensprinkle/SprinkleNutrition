//
//  Color+Theme.swift
//  FlexSprinkle
//
//  Semantic color definitions for consistent theming
//

import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let overlayBackground = Color.black.opacity(0.4)

    // MARK: - Primary Actions
    static let primaryAction = Color("MyBlue")
    static let primaryActionDisabled = Color("MyGrey")

    // MARK: - States
    static let success = Color("MyGreen")
    static let successBackground = Color("MyGreen").opacity(0.2)
    static let error = Color("myRed")

    // MARK: - Text
    static let primaryText = Color("MyBlack")
    static let secondaryText = Color("MyGrey")
    static let tertiaryText = Color("MyGrey").opacity(0.6)

    // MARK: - Borders & Dividers
    static let border = Color("MyGrey").opacity(0.3)
    static let divider = Color("MyGrey").opacity(0.2)

    // MARK: - Tab Bar
    static let tabBarBackground = Color("MyGrey").opacity(0.1)
    static let tabBarSelected = Color("MyBlue")
    static let tabBarUnselected = Color("MyGrey")
}
