import SwiftUI

// MARK: - Onboarding Flow (6 screens)

struct OnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentPage = 0
    @State private var bgAnimate = false
    
    private let totalPages = 8
    
    var body: some View {
        ZStack {
          
            ZStack {
                themeManager.currentTheme.backgroundColor
                    .animation(.easeInOut(duration: 0.5), value: themeManager.currentTheme)
                
                if currentPage < 6 {
                    LiquidGlassBackground(animate: bgAnimate)
                } else {
                    themeManager.currentTheme.accentGlow
                        .opacity(0.5)
                        .animation(.easeInOut(duration: 0.5), value: themeManager.currentTheme)
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            .onAppear {
                bgAnimate = true
            }
            
            VStack(spacing: 0.adaptive) {
             
                if currentPage > 0 {
                    HStack(spacing: 8.adaptive) {
                        ForEach(1..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentPage
                                      ? themeManager.currentTheme.secondaryColor
                                      : Color.white.opacity(0.2))
                                .frame(height: 4.adaptive)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                TabView(selection: $currentPage) {
                    SplashLogoView(onContinue: { goToPage(1) })
                        .tag(0)
                    
                    NameEntryView(onContinue: { goToPage(2) })
                        .tag(1)
                    
                    DyslexiaInfoView(onContinue: { goToPage(3) })
                        .tag(2)
                    
                    HowWeHelpView(onContinue: { goToPage(4) })
                        .tag(3)
                    
                    LexiIntroView(onContinue: { goToPage(5) })
                        .tag(4)
                    
                    ThemeChooserView(onContinue: { goToPage(6) })
                        .tag(5)
                        
                    RemindersSetupView(onContinue: { goToPage(7) })
                        .tag(6)
                    
                    TransformDemoView(onComplete: completeOnboarding)
                        .tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage > 0)
    }
    
    private func goToPage(_ page: Int) {
        HapticManager.shared.buttonPress()
        currentPage = page
    }
    
    private func completeOnboarding() {
        HapticManager.shared.celebration()
        progressManager.unlockFirstSteps()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            appState.hasCompletedOnboarding = true
        }
    }
}


// MARK: - Screen 1: Splash Logo Animation

struct SplashLogoView: View {
    let onContinue: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isAppearing = false
    @State private var iconFloat = false
    @State private var buttonOpacity: Double = 0
    @State private var textAppearing = false
    
    var body: some View {
        VStack(spacing: 0.adaptive) {
            Spacer()
       
            ZStack {
                RoundedRectangle(cornerRadius: 36.adaptive, style: .continuous)
                    .fill(Color.neuroSurface.opacity(0.5))
                    .frame(width: 160.adaptive, height: 160.adaptive)
                    .shadow(color: Color.black.opacity(0.2), radius: 25, x: 0, y: 15)
                    
                RoundedRectangle(cornerRadius: 36.adaptive, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 160.adaptive, height: 160.adaptive)
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90.adaptive, height: 90.adaptive)
                    .clipShape(RoundedRectangle(cornerRadius: 20.adaptive))
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                    .scaleEffect(isAppearing ? 1 : 0.5)
                    .opacity(isAppearing ? 1 : 0)
            }
            
            Spacer().frame(height: 55.adaptive)

            VStack(spacing: 12.adaptive) {
                Text("NeuroBridge")
                    .font(.system(size: 42.adaptive, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.neuroPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                    .opacity(textAppearing ? 1 : 0)
                    .offset(y: textAppearing ? 0 : 20)
                
                Text("Reading Made Easier")
                    .font(.system(size: 18.adaptive, weight: .medium, design: .rounded))
                    .foregroundColor(.neuroTextSecondary)
                    .opacity(textAppearing ? 1 : 0)
                    .offset(y: textAppearing ? 0 : 20)
            }
            
            Spacer()
    
            Button(action: {
                HapticManager.shared.buttonPress()
                onContinue()
            }) {
                HStack(spacing: 10.adaptive) {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(NeuroButtonStyle())
            .opacity(buttonOpacity)
            .scaleEffect(buttonOpacity > 0 ? 1 : 0.8)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 30)
        .onAppear { animateEntrance() }
    }
    
    private func animateEntrance() {

        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            isAppearing = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            textAppearing = true
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.8)) {
            buttonOpacity = 1.0
        }
    }
}


// MARK: - Screen 2: Name Entry

struct NameEntryView: View {
    let onContinue: () -> Void
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var nameInput: String = ""
    @FocusState private var isNameFocused: Bool
    @State private var iconFloat = false
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0.adaptive) {
                    Spacer(minLength: 50)
        
                    ZStack {
                        RoundedRectangle(cornerRadius: 36.adaptive, style: .continuous)
                            .fill(Color.neuroSurface.opacity(0.5))
                            .frame(width: 140.adaptive, height: 140.adaptive)
                            .shadow(color: Color.black.opacity(0.2), radius: 25, x: 0, y: 15)
                            
                        RoundedRectangle(cornerRadius: 36.adaptive, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            .frame(width: 140.adaptive, height: 140.adaptive)
                        
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 64.adaptive))
                            .foregroundColor(.neuroPrimary)
                            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                            .rotationEffect(.degrees(iconFloat ? 15 : -10))
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .offset(y: showContent ? 0 : 20)
                    
                    Spacer(minLength: 45)
                    
                    Text("What should we call you?")
                        .font(.system(size: 28.adaptive, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                    
                    Text("We'll personalize your experience")
                        .font(.system(size: 15.adaptive, weight: .regular, design: .rounded))
                        .foregroundColor(.neuroTextSecondary)
                        .padding(.top, 8)
                        .opacity(showContent ? 1 : 0)
                    
                    Spacer(minLength: 40)
            
                    HStack(spacing: 14.adaptive) {
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(isNameFocused ? Color.neuroPrimary : .neuroTextMuted)
                        
                        TextField("Your name", text: $nameInput)
                            .font(.system(size: 20.adaptive, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .tint(Color.neuroPrimary)
                            .focused($isNameFocused)
                            .submitLabel(.done)
                            .onSubmit { isNameFocused = false }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20.adaptive, style: .continuous)
                            .fill(Color.neuroSurface.opacity(0.5)) // Glass effect
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.adaptive, style: .continuous)
                            .stroke(
                                isNameFocused ? Color.neuroPrimary : Color.white.opacity(0.15),
                                lineWidth: isNameFocused ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isNameFocused ? Color.neuroPrimary.opacity(0.25) : .clear,
                        radius: 12, x: 0, y: 4
                    )
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    Spacer(minLength: 50)
                    
                    VStack(spacing: 14.adaptive) {
                        Button(action: {
                            appState.userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            isNameFocused = false
                            onContinue()
                        }) {
                            HStack {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(NeuroButtonStyle())
                        
                        Button(action: {
                            appState.userName = ""
                            isNameFocused = false
                            onContinue()
                        }) {
                            Text("Skip for now")
                                .font(.subheadline)
                                .foregroundColor(.neuroTextMuted)
                                .padding(.vertical, 10)
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .padding(.bottom, 50)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .padding(.horizontal, 30)
        .responsiveContent()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                iconFloat = true
            }
        }
        .onTapGesture { isNameFocused = false }
    }
}


// MARK: - Screen 3: What Is Dyslexia?

struct DyslexiaInfoView: View {
    let onContinue: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showContent = false
    @State private var iconBounce = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24.adaptive) {
                    Spacer(minLength: 30)
                    
                    ZStack {
                        Circle()
                            .fill(Color.neuroWarning.opacity(0.15))
                            .frame(width: 100.adaptive, height: 100.adaptive)
                        
                        Image(systemName: "eye.trianglebadge.exclamationmark")
                            .font(.system(size: 64.adaptive))
                            .foregroundStyle(Color.neuroWarning)
                            .offset(y: iconBounce ? -3 : 3)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: iconBounce
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.7)
                    
                    Text("What is Dyslexia?")
                        .font(.system(size: 36.adaptive, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 20.adaptive) {
                        InfoRow(icon: "textformat", text: "Letters may appear to move or swap places")
                        InfoRow(icon: "doc.text", text: "Reading can be slow and tiring")
                        InfoRow(icon: "brain", text: "It's about how the brain processes text")
                        InfoRow(icon: "checkmark.seal", text: "With the right tools, reading becomes easier!")
                    }
                    .padding(24.adaptive)
                    .neuroCard()
                    .padding(.horizontal, 10)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 25)
                    
                    HStack(alignment: .top, spacing: 0.adaptive) {
                        StatBubble(value: "1 in 10", label: "people have dyslexia")
                            .frame(maxWidth: .infinity)
                        StatBubble(value: "700M+", label: "affected worldwide")
                            .frame(maxWidth: .infinity)
                    }
                    .opacity(showContent ? 1 : 0)
                    .padding(.top, 4)
                    
                    Spacer(minLength: 20)
                    
                    Button(action: {
                        HapticManager.shared.buttonPress()
                        onContinue()
                    }) {
                        HStack {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(NeuroButtonStyle())
                    .padding(.bottom, 50)
                    .opacity(showContent ? 1 : 0)
                }
                .frame(minHeight: geometry.size.height)
            }
            .padding(.horizontal, 20)
            .responsiveContent()
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                    showContent = true
                }
                iconBounce = true
            }
        }
        }
    }

    
    // MARK: - Screen 4: How NeuroBridge Helps
    
    struct HowWeHelpView: View {
        let onContinue: () -> Void
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showContent = false
        @State private var sparkle = false
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24.adaptive) {
                        Spacer(minLength: 30)
                        
                        ZStack {
                            Circle()
                                .fill(Color.neuroPrimary.opacity(0.15))
                                .frame(width: 100.adaptive, height: 100.adaptive)
                            
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 48.adaptive))
                                .foregroundColor(.neuroPrimary)
                                .rotationEffect(.degrees(sparkle ? 5 : -5))
                                .animation(
                                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                    value: sparkle
                                )
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.7)
                        
                        Text("How NeuroBridge Helps")
                            .font(.system(size: 26.adaptive, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                        
                        VStack(spacing: 14.adaptive) {
                            FeatureRow(
                                icon: "textformat.size",
                                title: "Smart Text",
                                description: "Dyslexia-friendly fonts and spacing for clarity"
                            )
                            FeatureRow(
                                icon: "camera.fill",
                                title: "Scan Any Text",
                                description: "Use camera to transform books & documents"
                            )
                            FeatureRow(
                                icon: "gamecontroller.fill",
                                title: "Fun Exercises",
                                description: "Practice reading with engaging games"
                            )
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Track Progress",
                                description: "See how much you've improved over time"
                            )
                        }
                        .neuroCard(padding: 16)
                        .padding(.horizontal, 10)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 25)
                        
                        Spacer(minLength: 20)
                        
                        Button(action: {
                            HapticManager.shared.buttonPress()
                            onContinue()
                        }) {
                            HStack {
                                Text("Meet Lexi")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(NeuroButtonStyle())
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .padding(.horizontal, 20)
            .responsiveContent()
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                    showContent = true
                }
                sparkle = true
            }
        }
    }
    
    
    // MARK: - Screen 5: Meet Lexi AI
    
    struct LexiIntroView: View {
        let onContinue: () -> Void
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showContent = false
        @State private var pulseGlow = false
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24.adaptive) {
                        Spacer(minLength: 30)
                        
                       
                        ZStack {
                            Circle()
                                .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                                .frame(width: 120.adaptive, height: 120.adaptive)
                                .scaleEffect(pulseGlow ? 1.15 : 1.0)
                                .opacity(pulseGlow ? 0.6 : 0.3)
                                .animation(
                                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                    value: pulseGlow
                                )
                            
                            Circle()
                                .fill(themeManager.currentTheme.primaryColor.opacity(0.15))
                                .frame(width: 100.adaptive, height: 100.adaptive)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 48.adaptive))
                                .foregroundColor(.neuroPrimary)
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.7)
                        
                        VStack(spacing: 8.adaptive) {
                            Text("Meet Lexi")
                                .font(.system(size: 28.adaptive, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Your personal Reading Coach")
                                .font(.system(size: 16.adaptive, weight: .medium, design: .rounded))
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                        }
                        .opacity(showContent ? 1 : 0)
                        
                        Text("Powered by Apple Intelligence, Lexi lives on your device and is always ready to help.")
                            .font(.system(size: 14.adaptive, design: .rounded))
                            .foregroundColor(.neuroTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .opacity(showContent ? 1 : 0)
                        
                        VStack(spacing: 14.adaptive) {
                            LexiFeatureRow(
                                icon: "character.book.closed",
                                title: "Word Explainer",
                                description: "Break down tricky words into syllables and meanings"
                            )
                            LexiFeatureRow(
                                icon: "lightbulb.fill",
                                title: "Reading Tips",
                                description: "Get personalized strategies to read more comfortably"
                            )
                            LexiFeatureRow(
                                icon: "pencil.and.outline",
                                title: "Practice Partner",
                                description: "Build vocabulary with fun, interactive exercises"
                            )
                            LexiFeatureRow(
                                icon: "heart.fill",
                                title: "Encouragement",
                                description: "Stay motivated with uplifting messages"
                            )
                        }
                        .neuroCard(padding: 16)
                        .padding(.horizontal, 10)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 25)
                        
                        Spacer(minLength: 20)
                        
                        Button(action: {
                            HapticManager.shared.buttonPress()
                            onContinue()
                        }) {
                            HStack {
                                Text("Choose Your Theme")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(NeuroButtonStyle())
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .padding(.horizontal, 20)
            .responsiveContent()
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                    showContent = true
                }
                pulseGlow = true
            }
        }
    }

    struct LexiFeatureRow: View {
        let icon: String
        let title: String
        let description: String
        @EnvironmentObject var themeManager: ThemeManager
        
        var body: some View {
            HStack(spacing: 14.adaptive) {
                Image(systemName: icon)
                    .font(.system(size: 20.adaptive))
                    .foregroundColor(.neuroPrimary)
                    .frame(width: 40.adaptive, height: 40.adaptive)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10.adaptive))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15.adaptive, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 12.adaptive, design: .rounded))
                        .foregroundColor(.neuroTextSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    
    // MARK: - Screen 6: Theme Chooser
    
    struct ThemeChooserView: View {
        let onContinue: () -> Void
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showContent = false
        
        let columns = [
            GridItem(.flexible(), spacing: 14.adaptive),
            GridItem(.flexible(), spacing: 14.adaptive)
        ]
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20.adaptive) {
                        Spacer(minLength: 20)
                        
                        VStack(spacing: 8.adaptive) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 40.adaptive))
                                .foregroundColor(.neuroPrimary)
                                .opacity(showContent ? 1 : 0)
                                .scaleEffect(showContent ? 1 : 0.5)
                            
                            Text("Choose Your Theme")
                                .font(.system(size: 28.adaptive, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(showContent ? 1 : 0)
                            
                            Text("You can always change this later in settings")
                                .font(.system(size: 13.adaptive, weight: .regular, design: .rounded))
                                .foregroundColor(.neuroTextMuted)
                                .opacity(showContent ? 1 : 0)
                        }
                        
                        LazyVGrid(columns: columns, spacing: 14.adaptive) {
                            ForEach(AppTheme.allCases) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme == theme
                                ) {
                                    HapticManager.shared.selection()
                                    themeManager.setTheme(theme)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 25)
                        
                        Spacer(minLength: 20)
                        
                        Button(action: {
                            HapticManager.shared.buttonPress()
                            onContinue()
                        }) {
                            HStack {
                                Text("Set Reminders")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .padding(.horizontal, 16)
            .responsiveContent()
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                    showContent = true
                }
            }
        }
    }
    
    struct LiquidGlassBackground: View {
        let animate: Bool
        @EnvironmentObject var themeManager: ThemeManager
        
        var body: some View {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                
                Circle()
                    .fill(Color.neuroPrimary.opacity(0.45))
                    .frame(width: width * 0.8, height: width * 0.8)
                    .blur(radius: 60)
                    .offset(x: animate ? width * 0.3 : -width * 0.1, y: animate ? -height * 0.1 : height * 0.2)
                    .animation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(Color.neuroSecondary.opacity(0.35))
                    .frame(width: width * 0.9, height: width * 0.9)
                    .blur(radius: 70)
                    .offset(x: animate ? -width * 0.2 : width * 0.4, y: animate ? height * 0.4 : -height * 0.1)
                    .animation(.easeInOut(duration: 7.5).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(Color.neuroAccent.opacity(0.3))
                    .frame(width: width * 0.7, height: width * 0.7)
                    .blur(radius: 50)
                    .offset(x: animate ? width * 0.2 : -width * 0.3, y: animate ? height * 0.5 : height * 0.1)
                    .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: animate)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    // Additional padding orbs for iPad
                    Circle()
                        .fill(Color.neuroPrimary.opacity(0.2))
                        .frame(width: width * 0.5, height: width * 0.5)
                        .blur(radius: 40)
                        .offset(x: animate ? -width * 0.4 : width * 0.3, y: animate ? -height * 0.3 : height * 0.4)
                        .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: animate)
                    
                    Circle()
                        .fill(Color.neuroAccent.opacity(0.2))
                        .frame(width: width * 0.6, height: width * 0.6)
                        .blur(radius: 60)
                        .offset(x: animate ? width * 0.4 : -width * 0.2, y: animate ? -height * 0.2 : height * 0.3)
                        .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: animate)
                }
            }
            .allowsHitTesting(false)
        }
    }
    
    
    struct ThemeCard: View {
        let theme: AppTheme
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 10.adaptive) {
                    // Swatch preview — larger, more impactful
                    HStack(spacing: 4.adaptive) {
                        ForEach(Array(theme.swatchColors.enumerated()), id: \.offset) { _, color in
                            RoundedRectangle(cornerRadius: 6.adaptive)
                                .fill(color)
                                .frame(height: 44.adaptive)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10.adaptive))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.adaptive)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                    HStack(spacing: 6.adaptive) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 12.adaptive))
                            .foregroundColor(isSelected ? theme.accentColor : .neuroTextMuted)
                        
                        VStack(alignment: .leading, spacing: 1.adaptive) {
                            Text(theme.rawValue)
                                .font(.system(size: 12.adaptive, weight: .semibold, design: .rounded))
                                .foregroundColor(isSelected ? .white : .neuroTextSecondary)
                                .lineLimit(1)
                            
                            Text(theme.subtitle)
                                .font(.system(size: 10.adaptive, weight: .regular, design: .rounded))
                                .foregroundColor(.neuroTextMuted)
                                .lineLimit(1)
                        }
                        
                        Spacer(minLength: 0)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16.adaptive))
                                .foregroundColor(theme.accentColor)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16.adaptive)
                        .fill(isSelected ? theme.surfaceColor : Color.neuroSurface.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.adaptive)
                        .stroke(
                            isSelected
                            ? theme.accentColor.opacity(0.8)
                            : Color.white.opacity(0.06),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? theme.accentColor.opacity(0.3) : .clear,
                    radius: 12, x: 0, y: 4
                )
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
    
    
    // MARK: - Screen 6: Transform Demo
    
    struct TransformDemoView: View {
        let onComplete: () -> Void
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showTransformed = false
        @State private var transformation = TextTransformation()
        @State private var showContent = false
        
        private let sampleText = "Imagine reading without the struggle. No more losing your place, no more blurry lines. Just clear, comfortable words — finally."
        
        var body: some View {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20.adaptive) {
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 6.adaptive) {
                            Text("Watch the Magic!")
                                .font(.system(size: 26.adaptive, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            if !appState.userName.isEmpty {
                                Text("See how NeuroBridge transforms text for you, \(appState.userName)!")
                                    .font(.system(size: 14.adaptive, weight: .regular, design: .rounded))
                                    .foregroundColor(.neuroTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        
                        VStack(spacing: 16.adaptive) {
                            ZStack {
                                ScrollView {
                                    Text(sampleText)
                                        .font(.system(size: 16.adaptive))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, 4)
                                }
                                .opacity(showTransformed ? 0 : 1)
                                
                                ScrollView {
                                    Text(sampleText)
                                        .font(.dyslexicOrSystem(size: 18.adaptive * transformation.fontScale))
                                        .tracking(transformation.letterSpacing)
                                        .lineSpacing(transformation.lineSpacing)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, 4)
                                }
                                .opacity(showTransformed ? 1 : 0)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 220.adaptive)
                            .background(
                                RoundedRectangle(cornerRadius: 16.adaptive)
                                    .fill(showTransformed ? transformation.overlayColor.color : Color.neuroSurface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16.adaptive)
                                    .stroke(Color.neuroPrimary.opacity(showTransformed ? 1 : 0.3), lineWidth: 2)
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTransformed)
                            
                            Button(action: {
                                HapticManager.shared.success()
                                withAnimation { showTransformed.toggle() }
                            }) {
                                HStack {
                                    Image(systemName: showTransformed ? "arrow.uturn.backward" : "wand.and.stars")
                                    Text(showTransformed ? "Show Original" : "Transform Text")
                                }
                            }
                            .buttonStyle(NeuroButtonStyle(isPrimary: !showTransformed))
                        }
                        .padding(.horizontal, 10)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        if showTransformed {
                            VStack(spacing: 10.adaptive) {
                                Text("Adjust to Your Preference")
                                    .font(.neuroSubheadline)
                                    .foregroundColor(.neuroTextSecondary)
                                
                                HStack(spacing: 20.adaptive) {
                                    VStack(spacing: 4.adaptive) {
                                        Image(systemName: "textformat.size")
                                            .foregroundColor(.neuroPrimary)
                                            .font(.caption)
                                        Text("Size")
                                            .font(.caption2)
                                            .foregroundColor(.neuroTextMuted)
                                        Slider(value: $transformation.fontScale, in: 1.0...1.5)
                                            .tint(.neuroPrimary)
                                    }
                                    .frame(width: 100.adaptive)
                                    
                                    VStack(spacing: 4.adaptive) {
                                        Image(systemName: "arrow.left.and.right")
                                            .foregroundColor(.neuroPrimary)
                                            .font(.caption)
                                        Text("Spacing")
                                            .font(.caption2)
                                            .foregroundColor(.neuroTextMuted)
                                        Slider(value: $transformation.letterSpacing, in: 0...6)
                                            .tint(.neuroPrimary)
                                    }
                                    .frame(width: 100.adaptive)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        Spacer(minLength: 20)
                        
                        Button(action: {
                            HapticManager.shared.celebration()
                            SoundManager.shared.playStartReading()
                            onComplete()
                        }) {
                            HStack {
                                Text("Start Reading")
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .buttonStyle(NeuroButtonStyle())
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .padding(.horizontal, 20)
            .responsiveContent()
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                    showContent = true
                }
            }
        }
    }
    
    
    // MARK: - Supporting Views
    
    struct StatBubble: View {
        let value: String
        let label: String
        
        var body: some View {
            VStack(spacing: 4.adaptive) {
                Text(value)
                    .font(.system(size: 22.adaptive, weight: .bold, design: .rounded))
                    .foregroundColor(.neuroPrimary)
                    .frame(height: 28.adaptive)
                
                Text(label)
                    .font(.neuroCaption)
                    .foregroundColor(.neuroTextMuted)
                    .multilineTextAlignment(.center)
                    .frame(height: 34.adaptive)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minWidth: 130)
        }
    }
    
    
    struct InfoRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 16.adaptive) {
                Image(systemName: icon)
                    .font(.system(size: 22.adaptive))
                    .foregroundStyle(Color.neuroPrimary)
                    .frame(width: 32.adaptive)
                
                Text(text)
                    .font(.system(size: 18.adaptive, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    
    struct FeatureRow: View {
        let icon: String
        let title: String
        let description: String
        @EnvironmentObject var themeManager: ThemeManager
        
        var body: some View {
            HStack(alignment: .top, spacing: 14.adaptive) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 40.adaptive, height: 40.adaptive)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10.adaptive))
                
                VStack(alignment: .leading, spacing: 3.adaptive) {
                    Text(title)
                        .font(.system(size: 15.adaptive, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(description)
                        .font(.system(size: 13.adaptive, weight: .regular, design: .rounded))
                        .foregroundColor(.neuroTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    
    // MARK: - Previews
    
    #Preview {
        OnboardingFlow()
            .environmentObject(AppState())
            .environmentObject(ProgressManager())
            .environmentObject(ThemeManager.shared)
    }

