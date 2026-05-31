import SwiftUI
import UIKit
import CoreText


// MARK: - Dyslexic Font Variant

enum DyslexicFontVariant: String, CaseIterable, Identifiable {
    case regular = "Regular"
    case bold = "Bold"
    case italic = "Italic"
    case boldItalic = "Bold Italic"
    
    var id: String { rawValue }
    
    var fontName: String {
        switch self {
        case .regular: return "OpenDyslexic-Regular"
        case .bold: return "OpenDyslexic-Bold"
        case .italic: return "OpenDyslexic-Italic"
        case .boldItalic: return "OpenDyslexic-BoldItalic"
        }
    }
    
    var fileName: String {
        switch self {
        case .regular: return "OpenDyslexic-Regular"
        case .bold: return "OpenDyslexic-Bold"
        case .italic: return "OpenDyslexic-Italic"
        case .boldItalic: return "OpenDyslexic-BoldItalic"
        }
    }
    
    var icon: String {
        switch self {
        case .regular: return "textformat"
        case .bold: return "bold"
        case .italic: return "italic"
        case .boldItalic: return "bold.italic.underline"
        }
    }
}


// MARK: - Dyslexic Font Usage

enum DyslexicFontUsage: String, CaseIterable, Identifiable {
    case throughoutApp = "Throughout App"
    case exerciseGamesOnly = "Exercise Games Only"
    case nowhere = "Nowhere"
    
    var id: String { rawValue }
}

enum FontContext {
    case general
    case game
    case reader
}

// MARK: - Font Manager

class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var selectedVariant: DyslexicFontVariant = .regular {
        didSet {
            UserDefaults.standard.set(selectedVariant.rawValue, forKey: "selectedFontVariant")
            updateNavigationBarAppearance()
        }
    }
    
    @Published var selectedUsage: DyslexicFontUsage = .nowhere {
        didSet {
            UserDefaults.standard.set(selectedUsage.rawValue, forKey: "selectedFontUsage")
            updateNavigationBarAppearance()
        }
    }
    
    @Published var isInGameContext: Bool = false
    
    init() {
        if let stored = UserDefaults.standard.string(forKey: "selectedFontVariant"),
           let variant = DyslexicFontVariant(rawValue: stored) {
            selectedVariant = variant
        }
        if let storedUsage = UserDefaults.standard.string(forKey: "selectedFontUsage"),
           let usage = DyslexicFontUsage(rawValue: storedUsage) {
            selectedUsage = usage
        }
        updateNavigationBarAppearance()
    }
    
    func updateNavigationBarAppearance() {
        DispatchQueue.main.async {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            
            let applyDyslexic = self.shouldApplyDyslexic(inContext: .general)
            
            let largeTitleFont: UIFont
            let inlineTitleFont: UIFont
            
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            
            if applyDyslexic {
                let largeSize: CGFloat = isPad ? 38 : 32
                let inlineSize: CGFloat = isPad ? 20 : 17
                
                largeTitleFont = UIFont(name: self.selectedVariant.fontName, size: largeSize) ?? UIFont.systemFont(ofSize: largeSize, weight: .bold)
                inlineTitleFont = UIFont(name: self.selectedVariant.fontName, size: inlineSize) ?? UIFont.systemFont(ofSize: inlineSize, weight: .semibold)
            } else {
                let largeSize: CGFloat = isPad ? 44 : 34
                let inlineSize: CGFloat = isPad ? 22 : 17
                
                largeTitleFont = UIFont.systemFont(ofSize: largeSize, weight: .bold)
                inlineTitleFont = UIFont.systemFont(ofSize: inlineSize, weight: .semibold)
            }
            
            appearance.largeTitleTextAttributes = [
                .font: largeTitleFont,
                .foregroundColor: UIColor.white
            ]
            
            appearance.titleTextAttributes = [
                .font: inlineTitleFont,
                .foregroundColor: UIColor.white
            ]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    func shouldApplyDyslexic(inContext context: FontContext = .general) -> Bool {
        switch selectedUsage {
        case .throughoutApp:
            return true
        case .exerciseGamesOnly:
            return isInGameContext || context == .game || context == .reader
        case .nowhere:
            return context == .reader
        }
    }
    
    static func registerFonts() {
        DispatchQueue.global(qos: .userInitiated).async {
            registerFont(named: "OpenDyslexic-Regular", withExtension: "otf")
            registerFont(named: "OpenDyslexic-Bold", withExtension: "otf")
            registerFont(named: "OpenDyslexic-Italic", withExtension: "otf")
            registerFont(named: "OpenDyslexic-BoldItalic", withExtension: "otf")
        }
    }
    
    private static func registerFont(named name: String, withExtension ext: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Failed to load font: \(name)")
            return
        }
        
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        if !success {
            print("Failed to register font: \(name), error: \(String(describing: error))")
        }
    }
    
    func resetFontSettings() {
        selectedVariant = .regular
        selectedUsage = .nowhere
        UserDefaults.standard.removeObject(forKey: "selectedFontVariant")
        UserDefaults.standard.removeObject(forKey: "selectedFontUsage")
    }
}


// MARK: - Device Sizing & Scaling Utility

struct DeviceUtility {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var maxDimension: CGFloat {
        max(screenWidth, screenHeight)
    }
    
    static var fontScale: CGFloat {
        guard isPad else { return 1.0 }
       
        if maxDimension >= 1350 {
            return 1.65
        } else if maxDimension >= 1180 {
            return 1.48
        } else {
            return 1.3
        }
    }

    static var layoutScale: CGFloat {
        guard isPad else { return 1.0 }
        if maxDimension >= 1350 {
            return 1.75
        } else if maxDimension >= 1180 {
            return 1.55
        } else {
            return 1.35
        }
    }
}

// MARK: - Font Extensions

extension Font {
    
    private static var deviceScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? DeviceUtility.fontScale : 1.0
    }

    static func dyslexic(size: CGFloat) -> Font {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let scaledSize = size * (isPad ? DeviceUtility.fontScale * 0.95 : 1.0)
        let variant = FontManager.shared.selectedVariant
        if UIFont(name: variant.fontName, size: scaledSize) != nil {
            return Font.custom(variant.fontName, size: scaledSize)
        }
  
        if UIFont(name: "OpenDyslexic-Regular", size: scaledSize) != nil {
            return Font.custom("OpenDyslexic-Regular", size: scaledSize)
        }
        return Font.custom("OpenDyslexic", size: scaledSize)
    }
    
    static func dyslexicBold(size: CGFloat) -> Font {
        dyslexic(size: size).weight(.bold)
    }
    
    static func dyslexicOrSystem(size: CGFloat) -> Font {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let scaledSize = size * (isPad ? DeviceUtility.fontScale * 0.95 : 1.0)
        let variant = FontManager.shared.selectedVariant
        if UIFont(name: variant.fontName, size: scaledSize) != nil {
            return Font.custom(variant.fontName, size: scaledSize)
        }
        if UIFont(name: "OpenDyslexic-Regular", size: scaledSize) != nil {
            return Font.custom("OpenDyslexic-Regular", size: scaledSize)
        }
        return Font.system(size: scaledSize, weight: .regular, design: .rounded)
    }
    
    static func appFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .rounded, context: FontContext = .general, isAlreadyAdaptive: Bool = false) -> Font {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let padScale = DeviceUtility.fontScale
        
        let baseScale: CGFloat
        if isPad {
            if isAlreadyAdaptive {
               
                baseScale = max(1.15, padScale * 0.85)
            } else {
                baseScale = padScale
            }
        } else {
            baseScale = 1.0
        }
        
        if FontManager.shared.shouldApplyDyslexic(inContext: context) {
           
            let dyslexicScale: CGFloat = isPad 
                ? (isAlreadyAdaptive ? max(1.1, padScale * 0.8) : padScale * 0.95) 
                : (isAlreadyAdaptive ? 0.95 : 0.95)
            
            let scaledSize = size * dyslexicScale
            let variant = FontManager.shared.selectedVariant
            if UIFont(name: variant.fontName, size: scaledSize) != nil {
                return Font.custom(variant.fontName, size: scaledSize)
            }
            if UIFont(name: "OpenDyslexic-Regular", size: scaledSize) != nil {
                return Font.custom("OpenDyslexic-Regular", size: scaledSize)
            }
        }
        return .system(size: size * baseScale, weight: weight, design: design)
    }
    
    static var neuroTitle: Font {
        appFont(size: 34, weight: .bold)
    }
    
    static var neuroHeadline: Font {
        appFont(size: 24, weight: .semibold)
    }
    
    static var neuroSubheadline: Font {
        appFont(size: 18, weight: .medium)
    }
    
    static var neuroBody: Font {
        appFont(size: 16, weight: .regular)
    }
    
    static var neuroCaption: Font {
        appFont(size: 14, weight: .regular)
    }
}



struct DyslexicTextStyle: ViewModifier {
    let transformation: TextTransformation
    
    func body(content: Content) -> some View {
        content
            .font(transformation.useDyslexicFont 
                ? Font.dyslexicOrSystem(size: 18 * transformation.fontScale)
                : Font.system(size: 18 * transformation.fontScale, design: .rounded))
            .tracking(transformation.letterSpacing)
            .lineSpacing(transformation.lineSpacing)
    }
}

extension View {
    func dyslexicStyle(_ transformation: TextTransformation) -> some View {
        modifier(DyslexicTextStyle(transformation: transformation))
    }
    
    func appFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .rounded, context: FontContext = .general, isAlreadyAdaptive: Bool = false) -> some View {
        self.font(Font.appFont(size: size, weight: weight, design: design, context: context, isAlreadyAdaptive: isAlreadyAdaptive))
    }
    
    func gameContext() -> some View {
        self.modifier(GameContextModifier())
    }
}

struct GameContextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                FontManager.shared.isInGameContext = true
            }
            .onDisappear {
                FontManager.shared.isInGameContext = false
            }
    }
}
