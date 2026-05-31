import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var fontManager = FontManager.shared
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case reader
        case exercises
        case lexi
        case progress
    }
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingFlow()
            } else {
                MainTabView(selectedTab: $selectedTab)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
        .overlay(alignment: .top) {
            if let achievement = progressManager.recentlyUnlockedAchievement {
                AchievementBanner(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progressManager.recentlyUnlockedAchievement != nil)
    }
}

struct AchievementBanner: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.7))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1F2937").opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 50)
    }
}


struct MainTabView: View {
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab, showSettings: $appState.showingSettings)
                .id(themeManager.currentTheme)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(ContentView.Tab.home)
            
            ReaderView(showSettings: $appState.showingSettings)
                .id(themeManager.currentTheme)
                .tabItem {
                    Label("Reader", systemImage: "text.book.closed.fill")
                }
                .tag(ContentView.Tab.reader)
            
            ExerciseHubView()
                .id(themeManager.currentTheme)
                .tabItem {
                    Label("Exercises", systemImage: "gamecontroller.fill")
                }
                .tag(ContentView.Tab.exercises)
            
            LexiChatView()
                .id(themeManager.currentTheme)
                .tabItem {
                    Label("Lexi", systemImage: "sparkles")
                }
                .tag(ContentView.Tab.lexi)
            
            ProgressDashboardView()
                .id(themeManager.currentTheme)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(ContentView.Tab.progress)
        }
        .tint(themeManager.currentTheme.secondaryColor)
        .fullScreenCover(isPresented: $appState.showingSettings) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                        .onTapGesture { appState.showingSettings = false }
                    
                    ReadingSettingsView()
                        .frame(width: 680, height: 850)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .shadow(color: .black.opacity(0.3), radius: 30)
                }
                .presentationBackground(.clear)
            } else {
                ReadingSettingsView()
            }
        }
    }
}


// MARK: - Home View

struct HomeView: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showSettings: Bool
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var fontManager = FontManager.shared
    @State private var animateGreeting = false
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                themeManager.currentTheme.accentGlow
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 28.adaptive) {
                            // Greeting
                            VStack(alignment: .leading, spacing: 6.adaptive) {
                                Text(greeting + ",")
                                    .font(Font.appFont(size: 18, weight: .medium, context: .general, isAlreadyAdaptive: true))
                                    .foregroundColor(.neuroTextSecondary)
                                
                                Text(appState.userName.isEmpty ? "Explorer" : appState.userName)
                                    .font(Font.appFont(size: 32, weight: .bold, context: .general, isAlreadyAdaptive: true))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(animateGreeting ? 1 : 0)
                            .offset(y: animateGreeting ? 0 : 20)
                            
                            // Quick Stats
                            HStack(spacing: 14.adaptive) {
                                QuickStatCard(
                                    icon: "calendar.badge.clock",
                                    value: "\(progressManager.dailyReadingSessions.count)",
                                    label: "Active Days",
                                    color: .teal
                                )
                                
                                QuickStatCard(
                                    icon: "book.fill",
                                    value: "\(progressManager.wordsRead)",
                                    label: "Words Read",
                                    color: .neuroPrimary
                                )
                                
                                QuickStatCard(
                                    icon: "star.fill",
                                    value: "\(progressManager.exercisesCompleted)",
                                    label: "Exercises",
                                    color: .yellow
                                )
                            }
                            .padding(.horizontal)
                            
                            // Feature Cards (tappable — switch tabs)
                            VStack(spacing: 16.adaptive) {
                                Text("What would you like to do?")
                                    .font(.neuroSubheadline)
                                    .foregroundColor(.neuroTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                Button {
                                    selectedTab = .reader
                                } label: {
                                    HomeFeatureCardContent(
                                        icon: "text.book.closed.fill",
                                        title: "Read & Transform",
                                        subtitle: "Open dyslexia-friendly reading with text transformation",
                                        color: themeManager.currentTheme.primaryColor
                                    )
                                }
                                
                                Button {
                                    selectedTab = .exercises
                                } label: {
                                    HomeFeatureCardContent(
                                        icon: "gamecontroller.fill",
                                        title: "Practice Exercises",
                                        subtitle: "Syllable splitting, word hunting, and speed reading games",
                                        color: themeManager.currentTheme.accentColor
                                    )
                                }
                                
                                Button {
                                    selectedTab = .lexi
                                } label: {
                                    HomeFeatureCardContent(
                                        icon: "sparkles",
                                        title: "Talk with Lexi",
                                        subtitle: "Your AI reading coach — ask about words, get tips & motivation",
                                        color: themeManager.currentTheme.primaryColor
                                    )
                                }
                                
                                Button {
                                    selectedTab = .progress
                                } label: {
                                    HomeFeatureCardContent(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: "Track Progress",
                                        subtitle: "View your stats, streaks, and achievements",
                                        color: themeManager.currentTheme.secondaryColor
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Tip of the Day
                            VStack(alignment: .leading, spacing: 12.adaptive) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Tip of the Day")
                                        .font(.neuroSubheadline)
                                        .foregroundColor(.white)
                                }
                                
                                Text(dailyTip)
                                    .font(.neuroCaption)
                                    .foregroundColor(.neuroTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.neuroSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.15), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            
                            Spacer(minLength: 24.adaptive)
                        }
                        .padding(.top, 8)
                        .frame(width: min(geometry.size.width, UIDevice.current.userInterfaceIdiom == .pad ? 850 : geometry.size.width))
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("NeuroBridge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.buttonPress()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.neuroPrimary)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    animateGreeting = true
                }
            }
            .id(FontManager.shared.selectedVariant.rawValue + FontManager.shared.selectedUsage.rawValue)
        }
    }
    
    private var dailyTip: String {
        let tips = [
            "Reading with a colored overlay can reduce visual stress. Try different background colors in Settings!",
            "Break down long words into syllables — it makes them easier to decode and remember.",
            "Consistent daily practice, even just 5 minutes, builds strong reading habits over time.",
            "The OpenDyslexic font uses weighted bottoms on letters to help prevent letter rotation.",
            "Using a wider letter spacing can make text easier to read. Adjust it in Settings!",
            "Focus mode highlights one line at a time, reducing visual overload while reading.",
            "Try reading aloud — hearing words while seeing them strengthens word recognition."
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[dayOfYear % tips.count]
    }
}


// MARK: - Home Sub-Views

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8.adaptive) {
            Image(systemName: icon)
                .font(.system(size: 20.adaptive))
                .foregroundColor(color)
            
            Text(value)
                .font(Font.appFont(size: 22, weight: .bold, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(Font.appFont(size: 11, weight: .medium, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.neuroTextMuted)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16.adaptive)
        .background(Color.neuroSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}


struct HomeFeatureCardContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16.adaptive) {
            ZStack {
                RoundedRectangle(cornerRadius: 14.adaptive)
                    .fill(color.opacity(0.15))
                    .frame(width: 52.adaptive, height: 52.adaptive)
                
                Image(systemName: icon)
                    .font(.system(size: 22.adaptive))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font.appFont(size: 17, weight: .semibold, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(subtitle)
                    .font(Font.appFont(size: 13, weight: .regular, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14.adaptive, weight: .semibold))
                .foregroundColor(.neuroTextMuted)
        }
        .padding(16.adaptive)
        .background(Color.neuroSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}


#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(ProgressManager())
        .environmentObject(ThemeManager.shared)
}
