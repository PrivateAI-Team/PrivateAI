
import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case light, dark, system
    var id: Self { self }

    var displayName: String {
        switch self {
        case .light:   "Claro"
        case .dark:    "Escuro"
        case .system:  "Sistema"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark:  .dark
        case .system: nil
        }
    }
}
