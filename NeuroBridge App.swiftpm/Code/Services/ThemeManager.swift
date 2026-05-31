import SwiftUI

// MARK: - App Theme Enum

enum AppTheme: String, CaseIterable, Identifiable, Equatable {
    case classic = "Classic"
    case ocean = "Ocean"
    case luxe = "Luxe"
    case ember = "Ember"
    case meadow = "Meadow"
    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .classic: return "Original & Vibrant"
        case .ocean: return "Cool & Serene"
        case .luxe: return "Refined & Elegant"
        case .ember: return "Bold & Dynamic"
        case .meadow: return "Calm & Natural"
        }
    }
    
    var icon: String {
        switch self {
        case .classic: return "brain.head.profile"
        case .ocean: return "water.waves"
        case .luxe: return "crown.fill"
        case .ember: return "flame.fill"
        case .meadow: return "leaf.fill"
        }
    }
    
    // MARK: - Color Definitions (vibrant & rich)
    
    var backgroundColor: Color {
        switch self {
        case .classic: return Color(red: 0.06, green: 0.09, blue: 0.16)
        case .ocean: return Color(hex: "0D1B2A")
        case .luxe: return Color(hex: "1A1A1A")
        case .ember: return Color(hex: "141414")
        case .meadow: return Color(hex: "0F1F0F")
        }
    }
    
    var surfaceColor: Color {
        switch self {
        case .classic: return Color(red: 0.12, green: 0.16, blue: 0.23)
        case .ocean: return Color(hex: "1B2838")
        case .luxe: return Color(hex: "2D3436")
        case .ember: return Color(hex: "222222")
        case .meadow: return Color(hex: "1A3318")
        }
    }
    
    var surfaceLightColor: Color {
        switch self {
        case .classic: return Color(red: 0.20, green: 0.25, blue: 0.33)
        case .ocean: return Color(hex: "253649")
        case .luxe: return Color(hex: "3D4446")
        case .ember: return Color(hex: "333333")
        case .meadow: return Color(hex: "2A4A26")
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .classic: return Color(red: 0.39, green: 0.40, blue: 0.95)
        case .ocean: return Color(hex: "1B98E0")
        case .luxe: return Color(hex: "C8A951")
        case .ember: return Color(hex: "E63946")
        case .meadow: return Color(hex: "4CAF50")
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .classic: return Color(red: 0.55, green: 0.36, blue: 0.96)
        case .ocean: return Color(hex: "48CAE4")
        case .luxe: return Color(hex: "DFE6E9")
        case .ember: return Color(hex: "FF6B6B")
        case .meadow: return Color(hex: "81C784")
        }
    }
    
    var accentColor: Color {
        switch self {
        case .classic: return Color(red: 0.24, green: 0.82, blue: 0.95)
        case .ocean: return Color(hex: "90E0EF")
        case .luxe: return Color(hex: "D4AF37")
        case .ember: return Color(hex: "FF4757")
        case .meadow: return Color(hex: "AED581")
        }
    }
    
    var textLightColor: Color {
        switch self {
        case .classic: return Color.white
        case .ocean: return Color(hex: "CAF0F8")
        case .luxe: return Color.white
        case .ember: return Color(hex: "F1F2F6")
        case .meadow: return Color(hex: "F1F8E9")
        }
    }
    
    /// The 4 swatch colors for the theme chooser preview
    var swatchColors: [Color] {
        [backgroundColor, primaryColor, secondaryColor, accentColor]
    }
    
    // MARK: - Gradients
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundColor, surfaceColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var accentGlow: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                primaryColor.opacity(0.15),
                Color.clear
            ]),
            center: .topTrailing,
            startRadius: 50,
            endRadius: 400
        )
    }
    
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [surfaceColor, surfaceColor.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .classic {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        if let storedValue = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: storedValue) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}


// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
