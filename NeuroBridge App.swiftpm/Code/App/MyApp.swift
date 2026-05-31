import SwiftUI

@main
struct NeuroBridgeApp: App {
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var appState = AppState()
    @ObservedObject private var themeManager = ThemeManager.shared
    
    init() {
        FontManager.registerFonts()
        configureAppearance()
    }
    
    private func configureAppearance() {
        // Pre-configure tab bar appearance for faster initial render
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Pre-configure navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
        }
    }
}


class AppState: ObservableObject {
    @Published var showingSettings: Bool = false
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var currentTransformation: TextTransformation = TextTransformation()
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    func resetApp() {
        hasCompletedOnboarding = false
        userName = ""
        currentTransformation = TextTransformation()
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        ThemeManager.shared.setTheme(.classic)
        
        NotificationManager.shared.resetReminders()

        FontManager.shared.resetFontSettings()
    }
}
