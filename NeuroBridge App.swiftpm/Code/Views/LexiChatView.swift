import SwiftUI
import FoundationModels

struct LexiChatView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @ObservedObject private var fontManager = FontManager.shared
    @State private var lexiService = LexiService()
    @State private var inputText = ""
    @State private var showGreeting = true
    @FocusState private var isInputFocused: Bool
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                themeManager.currentTheme.accentGlow
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                switch lexiService.availability {
                case .available:
                    chatContent
                case .deviceNotEligible:
                    UnavailableView(
                        icon: "exclamationmark.triangle.fill",
                        title: "Device Not Supported",
                        message: "Lexi requires a device that supports Apple Intelligence. Please check your device compatibility."
                    )
                case .notEnabled:
                    UnavailableView(
                        icon: "brain.head.profile.fill",
                        title: "Enable Apple Intelligence",
                        message: "To chat with Lexi, turn on Apple Intelligence in Settings → Apple Intelligence & Siri."
                    )
                case .modelNotReady:
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.neuroPrimary)
                        Text("Lexi is getting ready...")
                            .font(Font.appFont(size: 20, weight: .bold, context: .general, isAlreadyAdaptive: true))
                            .foregroundColor(.white)
                        Text("The AI model is downloading. This may take a moment.")
                            .font(Font.appFont(size: 15, weight: .regular, context: .general, isAlreadyAdaptive: true))
                            .foregroundColor(.neuroTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Retry") {
                            lexiService.checkAvailability()
                        }
                        .buttonStyle(NeuroButtonStyle())
                    }
                case .unknownIssue:
                    UnavailableView(
                        icon: "questionmark.circle.fill",
                        title: "Lexi Unavailable",
                        message: "The AI model is currently unavailable. Please try again later."
                    )
                }
            }
            .navigationTitle("Lexi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if lexiService.availability == .available {
                        Button {
                            HapticManager.shared.buttonPress()
                            withAnimation(.spring(response: 0.3)) {
                                lexiService.resetChat()
                                showGreeting = true
                            }
                        } label: {
                            Label("New Chat", systemImage: "arrow.counterclockwise")
                                .font(.system(size: 16.adaptive, weight: .medium))
                                .foregroundColor(.neuroPrimary)
                        }
                    }
                }
            }
            .id(FontManager.shared.selectedVariant.rawValue + FontManager.shared.selectedUsage.rawValue)
        }
    }
    
    // MARK: - Chat Content
    
    private var chatContent: some View {
        VStack(spacing: 0) {
       
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16.adaptive) {
                        if showGreeting && lexiService.messages.isEmpty {
                            greetingView
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        ForEach(lexiService.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }
                        
                        if lexiService.isGenerating {
                            if lexiService.currentStreamText.isEmpty {
                                TypingIndicator()
                                    .id("typing")
                            } else {
                                StreamingBubble(text: lexiService.currentStreamText)
                                    .id("streaming")
                            }
                        }
                        
                        // Bottom anchor
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16.adaptive)
                    .padding(.top, 16.adaptive)
                    .padding(.bottom, 8)
                }
                .onChange(of: lexiService.messages.count) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: lexiService.currentStreamText) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Quick actions
            if !lexiService.isGenerating && lexiService.messages.count < 2 {
                quickActionsBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
          
            inputBar
        }
        .frame(maxWidth: isIPad ? 850 : .infinity)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Greeting View
    
    private var greetingView: some View {
        VStack(spacing: 20.adaptive) {
            Spacer(minLength: 40.adaptive)
            
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .frame(width: 100.adaptive, height: 100.adaptive)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44.adaptive))
                    .foregroundColor(.neuroPrimary)
            }
            
            VStack(spacing: 8.adaptive) {
                Text("Hey\(appState.userName.isEmpty ? "" : ", \(appState.userName)")! 👋")
                    .font(Font.appFont(size: 24, weight: .bold, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.white)
                
                Text("I'm **Lexi**, your personal reading coach")
                    .font(Font.appFont(size: 17, weight: .regular, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextSecondary)
                
                Text("Ask me anything about reading, words, or dyslexia tips!")
                    .font(Font.appFont(size: 14, weight: .regular, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer(minLength: 20)
        }
    }
    
    // MARK: - Quick Actions Bar
    
    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10.adaptive) {
                ForEach(LexiQuickAction.allCases) { action in
                    Button {
                        HapticManager.shared.tap()
                        showGreeting = false
                        Task {
                            await lexiService.executeQuickAction(action)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: action.icon)
                                .font(.system(size: 13.adaptive))
                            Text(action.rawValue)
                                .font(Font.appFont(size: 13, weight: .medium, context: .general, isAlreadyAdaptive: true))
                        }
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 14.adaptive)
                        .padding(.vertical, 10.adaptive)
                        .background(themeManager.currentTheme.primaryColor.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(themeManager.currentTheme.primaryColor.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .disabled(lexiService.isGenerating)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask Lexi anything...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(Font.appFont(size: 16, weight: .regular, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
                .padding(.horizontal, 16.adaptive)
                .padding(.vertical, 12.adaptive)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .background(Color.neuroSurface)
                .clipShape(RoundedRectangle(cornerRadius: 20.adaptive))
                .overlay(
                    RoundedRectangle(cornerRadius: 20.adaptive)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            
            Button {
                HapticManager.shared.buttonPress()
                let text = inputText
                inputText = ""
                showGreeting = false
                isInputFocused = false
                Task {
                    await lexiService.sendMessage(text)
                    HapticManager.shared.tap()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36.adaptive))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || lexiService.isGenerating
                        ? Color.neuroTextMuted
                        : themeManager.currentTheme.primaryColor
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || lexiService.isGenerating)
        }
        .padding(.horizontal, 16.adaptive)
        .padding(.vertical, 12.adaptive)
        .background(Color.neuroBackground.opacity(0.95))
    }
}


// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer(minLength: 60.adaptive) }
            
            if !message.isUser {
                Image(systemName: "sparkles")
                    .font(.system(size: 12.adaptive))
                    .foregroundColor(.neuroPrimary)
                    .frame(width: 28.adaptive, height: 28.adaptive)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Text(message.content)
                .font(Font.appFont(size: 15, weight: .regular, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
                .padding(.horizontal, 14.adaptive)
                .padding(.vertical, 10.adaptive)
                .background(
                    message.isUser
                    ? themeManager.currentTheme.primaryColor
                    : Color.neuroSurface
                )
                .clipShape(RoundedRectangle(cornerRadius: 18.adaptive))
                .overlay(
                    RoundedRectangle(cornerRadius: 18.adaptive)
                        .stroke(Color.white.opacity(message.isUser ? 0 : 0.06), lineWidth: 1)
                )
            
            if !message.isUser { Spacer(minLength: 60.adaptive) }
        }
    }
}


// MARK: - Streaming Bubble

struct StreamingBubble: View {
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12.adaptive))
                .foregroundColor(.neuroPrimary)
                .frame(width: 28.adaptive, height: 28.adaptive)
                .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                .clipShape(Circle())
            
            Text(text)
                .font(Font.appFont(size: 15, weight: .regular, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
                .padding(.horizontal, 14.adaptive)
                .padding(.vertical, 10.adaptive)
                .background(Color.neuroSurface)
                .clipShape(RoundedRectangle(cornerRadius: 18.adaptive))
                .overlay(
                    RoundedRectangle(cornerRadius: 18.adaptive)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            
            Spacer(minLength: 60.adaptive)
        }
    }
}


// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12.adaptive))
                .foregroundColor(.neuroPrimary)
                .frame(width: 28.adaptive, height: 28.adaptive)
                .background(Color.neuroPrimary.opacity(0.15))
                .clipShape(Circle())
            
            HStack(spacing: 5.adaptive) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.neuroTextMuted)
                        .frame(width: 7.adaptive, height: 7.adaptive)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .opacity(animating ? 1.0 : 0.4)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16.adaptive)
            .padding(.vertical, 14.adaptive)
            .background(Color.neuroSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18.adaptive))
            
            Spacer(minLength: 60.adaptive)
        }
        .onAppear { animating = true }
    }
}


// MARK: - Unavailable View

struct UnavailableView: View {
    let icon: String
    let title: String
    let message: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 24.adaptive) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .frame(width: 120.adaptive, height: 120.adaptive)
                
                Image(systemName: icon)
                    .font(.system(size: 48.adaptive))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            VStack(spacing: 10.adaptive) {
                Text(title)
                    .font(Font.appFont(size: 22, weight: .bold, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(Font.appFont(size: 15, weight: .regular, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
    }
}
