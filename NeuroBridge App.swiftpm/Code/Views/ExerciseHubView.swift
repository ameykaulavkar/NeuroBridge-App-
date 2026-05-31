import SwiftUI

struct ExerciseHubView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var fontManager = FontManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                themeManager.currentTheme.accentGlow
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24.adaptive) {
                
                        HStack(spacing: 20.adaptive) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                value: "\(progressManager.exercisesCompleted)",
                                label: "Completed"
                            )
                            
                            StatCard(
                                icon: "target",
                                value: String(format: "%.0f%%", progressManager.totalAccuracy),
                                label: "Accuracy"
                            )
                            
                            StatCard(
                                icon: "calendar.badge.clock",
                                value: "\(progressManager.dailyReadingSessions.count)",
                                label: "Active Days"
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16.adaptive) {
                            Text("Choose an Exercise")
                                .font(.neuroHeadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink {
                                SyllableSplitterGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Syllable Splitter",
                                    description: "Learn to break words into syllables",
                                    icon: "textformat.abc",
                                    color: .blue,
                                    difficulty: "Easy"
                                )
                            }

                            
                            NavigationLink {
                                WordHunterGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Word Hunter",
                                    description: "Find target words quickly",
                                    icon: "magnifyingglass",
                                    color: .green,
                                    difficulty: "Medium"
                                )
                            }

                            
                            NavigationLink {
                                SpeedReadingGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Speed Reading",
                                    description: "Improve your reading pace",
                                    icon: "gauge.with.dots.needle.67percent",
                                    color: .orange,
                                    difficulty: "Medium"
                                )
                            }

                            
                            NavigationLink {
                                LetterDetectiveGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Letter Detective",
                                    description: "Spot similar letters (b/d, p/q)",
                                    icon: "eye.trianglebadge.exclamationmark",
                                    color: .purple,
                                    difficulty: "Hard"
                                )
                            }

                            
                            NavigationLink {
                                SentenceBuilderGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Sentence Builder",
                                    description: "Arrange words correctly",
                                    icon: "text.alignleft",
                                    color: .indigo,
                                    difficulty: "Medium"
                                )
                            }

                            
                            NavigationLink {
                                PhonicsMatchGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Phonics Match",
                                    description: "Match spoken sounds to letters",
                                    icon: "ear",
                                    color: .teal,
                                    difficulty: "Hard"
                                )
                            }

                            
                            NavigationLink {
                                RhymeTimeGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Rhyme Time",
                                    description: "Find rhyming words quickly",
                                    icon: "music.note",
                                    color: .pink,
                                    difficulty: "Easy"
                                )
                            }

                            
                            NavigationLink {
                                RightSpellGame()
                                    .onAppear { HapticManager.shared.buttonPress() }
                            } label: {
                                ExerciseCard(
                                    title: "Right Spell",
                                    description: "Choose the correct spelling",
                                    icon: "character.book.closed",
                                    color: .cyan,
                                    difficulty: "Medium"
                                )
                            }

                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Exercises")
            .id(FontManager.shared.selectedVariant.rawValue + FontManager.shared.selectedUsage.rawValue)
        }
    }
}


struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8.adaptive) {
            Image(systemName: icon)
                .font(.system(size: 20.adaptive))
                .foregroundColor(.neuroPrimary)
            
            Text(value)
                .font(Font.appFont(size: 24, weight: .bold, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
            
            Text(label)
                .font(Font.appFont(size: 12, weight: .regular, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.neuroTextMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(16.adaptive)
        .background(Color.neuroSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


struct ExerciseCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let difficulty: String
    
    var body: some View {
        HStack(spacing: 16.adaptive) {
            Image(systemName: icon)
                .font(.system(size: 24.adaptive))
                .foregroundColor(.white)
                .frame(width: 56.adaptive, height: 56.adaptive)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14.adaptive))
            
            VStack(alignment: .leading, spacing: 4.adaptive) {
                HStack {
                    Text(title)
                        .font(.neuroSubheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(difficulty)
                        .font(Font.appFont(size: 12, weight: .medium, context: .general))
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 8.adaptive)
                        .padding(.vertical, 4.adaptive)
                        .background(difficultyColor.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Text(description)
                    .font(.neuroCaption)
                    .foregroundColor(.neuroTextSecondary)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.neuroTextMuted)
        }
        .padding(16.adaptive)
        .background(Color.neuroSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}


struct SyllableSplitterGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = TextTransformationEngine()
    
    @State private var currentWordIndex = 0
    @State private var score = 0
    @State private var userSyllables: [String] = []
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var gameComplete = false
    @State private var startTime = Date()
    
    private let words = [
        "butterfly", "elephant", "umbrella", "computer", 
        "adventure", "hamburger", "telephone", "calendar",
        "crocodile", "dinosaur", "astronaut", "kangaroo",
        "chocolate", "hospital", "important", "magazine",
        "octopus", "potato", "tomato", "volcano"
    ]
    
    private var currentWord: String {
        words[currentWordIndex]
    }
    
    private var correctSyllables: [String] {
        engine.breakIntoSyllables(currentWord)
    }
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow
                .opacity(0.3)
                .ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(
                    score: score,
                    maxScore: words.count,
                    exerciseType: .syllableSplitter,
                    onDismiss: { dismiss() }
                )
            } else {
                VStack(spacing: 30) {
                    HStack {
                        Text("Word \(currentWordIndex + 1) of \(words.count)")
                            .font(.neuroSubheadline)
                            .foregroundColor(.neuroTextSecondary)
                        
                        Spacer()
                        
                        Text("Score: \(score)")
                            .font(.neuroSubheadline)
                            .foregroundColor(.neuroPrimary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Split this word into syllables")
                            .font(.neuroBody)
                            .foregroundColor(.neuroTextSecondary)
                        
                        Text(currentWord)
                            .font(Font.appFont(size: 42, weight: .bold, design: .rounded, context: .game))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.neuroSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if !userSyllables.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(Array(userSyllables.enumerated()), id: \.offset) { index, syllable in
                                SyllableBubble(text: syllable) {
                                    userSyllables.remove(at: index)
                                    HapticManager.shared.tap()
                                }
                            }
                        }
                    }
                    
                    Text("Tap letters to mark syllable breaks")
                        .font(.neuroCaption)
                        .foregroundColor(.neuroTextMuted)
                    
                    LetterSplitter(word: currentWord) { syllables in
                        userSyllables = syllables
                    }
                    .id(currentWord)
                    
                    Spacer()

                    Button {
                        checkAnswer()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Check Answer")
                        }
                    }
                    .buttonStyle(NeuroButtonStyle())
                    .disabled(userSyllables.isEmpty)
                    .opacity(userSyllables.isEmpty ? 0.5 : 1)
                }
                .padding()
            }

            if showingResult {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: correctSyllables.joined(separator: "-"))
            }
        }
        .navigationTitle("Syllable Splitter")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
    }
    
    private func checkAnswer() {
        let userAnswer = userSyllables.map { $0.lowercased() }
        let correct = correctSyllables.map { $0.lowercased() }

        isCorrect = userAnswer.joined() == correct.joined() && userSyllables.count == correctSyllables.count
        
        if isCorrect {
            score += 1
            HapticManager.shared.correctAnswer()
            SoundManager.shared.playCorrect()
        } else {
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.playIncorrect()
        }
        
        showingResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingResult = false
            userSyllables = []
            
            if currentWordIndex < words.count - 1 {
                currentWordIndex += 1
            } else {
                completeGame()
            }
        }
    }
    
    private func completeGame() {
        gameComplete = true
        SoundManager.shared.playCompletion()
        let result = ExerciseResult(
            id: UUID(),
            exerciseType: .syllableSplitter,
            score: score,
            maxScore: words.count,
            completedAt: Date(),
            duration: Date().timeIntervalSince(startTime)
        )
        progressManager.recordExerciseResult(result)
    }
}


struct LetterSplitter: View {
    let word: String
    let onSplit: ([String]) -> Void
    
    @State private var splitIndices: Set<Int> = []
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(word.enumerated()), id: \.offset) { index, char in
                HStack(spacing: 0) {
                    Button {
                        if index < word.count - 1 {
                            toggleSplit(at: index)
                        }
                    } label: {
                        Text(String(char))
                            .font(Font.appFont(size: word.count > 8 ? 24 : 28, weight: .medium, design: .rounded, context: .game))
                            .foregroundColor(.white)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 50 : (word.count > 8 ? 32 : 36), height: 50)
                            .background(
                                splitIndices.contains(index) ? Color.neuroPrimary.opacity(0.3) : Color.neuroSurface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if index < word.count - 1 {
                        if splitIndices.contains(index) {
                            Rectangle()
                                .fill(Color.neuroPrimary)
                                .frame(width: 3, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                }
            }
        }
        .onChange(of: splitIndices) { _, _ in
            updateSyllables()
        }
    }
    
    private func toggleSplit(at index: Int) {
        HapticManager.shared.selection()
        if splitIndices.contains(index) {
            splitIndices.remove(index)
        } else {
            splitIndices.insert(index)
        }
    }
    
    private func updateSyllables() {
        var syllables: [String] = []
        var currentSyllable = ""
        
        for (index, char) in word.enumerated() {
            currentSyllable.append(char)
            if splitIndices.contains(index) {
                syllables.append(currentSyllable)
                currentSyllable = ""
            }
        }
        if !currentSyllable.isEmpty {
            syllables.append(currentSyllable)
        }
        
        onSplit(syllables)
    }
}


struct SyllableBubble: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.neuroBody)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.neuroPrimary)
        .clipShape(Capsule())
    }
}


struct ResultOverlay: View {
    let isCorrect: Bool
    let correctAnswer: String
    var isMissed: Bool = false
    
    private var displayText: String {
        if isCorrect { return "Correct!" }
        if isMissed { return "Missed!" }
        return "Incorrect!"
    }
    
    private var iconName: String {
        if isCorrect { return "checkmark.circle.fill" }
        if isMissed { return "clock.badge.xmark" }
        return "xmark.circle.fill"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(isCorrect ? .neuroSuccess : .neuroError)
            
            Text(displayText)
                .font(.neuroHeadline)
                .foregroundColor(.white)
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            
            if !isCorrect {
                Text("Answer: \(correctAnswer)")
                    .font(.neuroBody)
                    .foregroundColor(.neuroTextSecondary)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .background(Color.neuroSurface.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .transition(.scale.combined(with: .opacity))
    }
}


struct GameCompleteView: View {
    let score: Int
    let maxScore: Int
    let exerciseType: ExerciseResult.ExerciseType
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    
    var accuracy: Double {
        Double(score) / Double(maxScore) * 100
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.neuroPrimary)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .scaleEffect(showConfetti ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)
            
            Text("Exercise Complete!")
                .font(.neuroTitle)
                .foregroundColor(.white)
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    VStack {
                        Text("\(score)/\(maxScore)")
                            .font(Font.appFont(size: 36, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(.neuroPrimary)
                        Text("Score")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                    }
                    
                    VStack {
                        Text(String(format: "%.0f%%", accuracy))
                            .font(Font.appFont(size: 36, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(accuracy >= 70 ? .neuroSuccess : .neuroWarning)
                        Text("Accuracy")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                    }
                }
            }
            .neuroCard()

            Text(motivationalMessage)
                .font(.neuroBody)
                .foregroundColor(.neuroTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
            
            Spacer()
            
            Button {
                HapticManager.shared.buttonPress()
                onDismiss()
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back to Exercises")
                }
            }
            .buttonStyle(NeuroButtonStyle())
        }
        .padding()
        .onAppear {
            showConfetti = true
            HapticManager.shared.celebration()
        }
    }
    
    private var motivationalMessage: String {
        if accuracy >= 90 {
            return "Amazing work! You're a natural!"
        } else if accuracy >= 70 {
            return "Great job! Keep practicing!"
        } else if accuracy >= 50 {
            return "Good effort! Practice makes perfect!"
        } else {
            return "Don't give up! Try again!"
        }
    }
}

#Preview {
    ExerciseHubView()
        .environmentObject(ProgressManager())
}
