import SwiftUI


// MARK: - Theme-Aware Color Extensions

extension Color {
    

    
    static var neuroPrimary: Color {
        ThemeManager.shared.currentTheme.primaryColor
    }
    
    static var neuroSecondary: Color {
        ThemeManager.shared.currentTheme.secondaryColor
    }
    
    static var neuroAccent: Color {
        ThemeManager.shared.currentTheme.accentColor
    }
    
    static var neuroBackground: Color {
        ThemeManager.shared.currentTheme.backgroundColor
    }
    
    static var neuroSurface: Color {
        ThemeManager.shared.currentTheme.surfaceColor
    }
    
    static var neuroSurfaceLight: Color {
        ThemeManager.shared.currentTheme.surfaceLightColor
    }
    

    static let neuroSuccess = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let neuroWarning = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let neuroError = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    static var neuroText: Color {
        .white
    }
    
    static var neuroTextSecondary: Color {
        Color.white.opacity(0.7)
    }
    
    static var neuroTextMuted: Color {
        Color.white.opacity(0.5)
    }
    
    static var neuroGradient: LinearGradient {
        ThemeManager.shared.currentTheme.primaryGradient
    }
    
    static var neuroGradientSubtle: LinearGradient {
        LinearGradient(
            colors: [neuroPrimary.opacity(0.3), neuroSecondary.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


// MARK: - Theme-Aware Gradient Extensions

extension LinearGradient {
    static var neuroPrimaryGradient: LinearGradient {
        ThemeManager.shared.currentTheme.primaryGradient
    }
    
    static var neuroCardGradient: LinearGradient {
        ThemeManager.shared.currentTheme.cardGradient
    }
    
    static var neuroBackgroundGradient: LinearGradient {
        ThemeManager.shared.currentTheme.backgroundGradient
    }
}


// MARK: - Themed Background Modifier


struct ThemedBackground: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.neuroBackground
                    // Subtle accent glow in corner for visual richness
                    themeManager.currentTheme.accentGlow
                        .opacity(0.6)
                }
                .ignoresSafeArea()
            )
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackground())
    }
}


// MARK: - Card Style

struct NeuroCardStyle: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    var padding: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.neuroSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.neuroPrimary.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: Color.neuroPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}


// MARK: - Button Style

struct NeuroButtonStyle: ButtonStyle {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var fontManager = FontManager.shared
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.appFont(size: 17, weight: .semibold, context: .general))
            .foregroundColor(.white)
            .padding(.horizontal, 32.adaptive)
            .padding(.vertical, 16.adaptive)
            .background(
                isPrimary ? Color.neuroPrimary : Color.neuroSurface
            )
            .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
            .overlay(
                RoundedRectangle(cornerRadius: 16.adaptive)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: isPrimary ? Color.neuroPrimary.opacity(0.3) : .clear, radius: 10.adaptive, x: 0, y: 5.adaptive)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


// MARK: - View Extension

extension View {
    func neuroCard(padding: CGFloat = 20) -> some View {
        modifier(NeuroCardStyle(padding: padding))
    }
}
