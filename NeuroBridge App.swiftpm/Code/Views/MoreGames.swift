import SwiftUI

struct WordHunterGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var targetWord = ""
    @State private var gridWords: [String] = []
    @State private var foundIndices: Set<Int> = []
    @State private var timeRemaining = 30
    @State private var gameComplete = false
    @State private var showMissed = false
    @State private var timer: Timer?
    
    private let totalRounds = 15
    private let gridSize = 12
    
    private let allWords = [
        "apple", "beach", "cloud", "dream", "eagle",
        "flame", "grape", "house", "image", "juice",
        "kite", "lemon", "music", "night", "ocean",
        "piano", "queen", "river", "storm", "table"
    ]
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow
                .opacity(0.3)
                .ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(
                    score: score,
                    maxScore: totalRounds,
                    exerciseType: .wordHunter,
                    onDismiss: { dismiss() }
                )
            } else {
                VStack(spacing: 24) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(totalRounds)")
                            .font(.neuroSubheadline)
                            .foregroundColor(.neuroTextSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(timeRemaining)s")
                        }
                        .font(.neuroSubheadline)
                        .foregroundColor(timeRemaining <= 5 ? .neuroError : .neuroTextSecondary)
                        
                        Spacer()
                        
                        Text("Score: \(score)")
                            .font(.neuroSubheadline)
                            .foregroundColor(.neuroPrimary)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 8) {
                        Text("Find this word:")
                            .font(.neuroBody)
                            .foregroundColor(.neuroTextSecondary)
                        
                        Text(targetWord.uppercased())
                            .font(Font.appFont(size: 36, weight: .bold, design: .rounded, context: .game))
                            .foregroundColor(.neuroPrimary)
                            .padding()
                            .background(Color.neuroSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(Array(gridWords.enumerated()), id: \.offset) { index, word in
                            WordButton(
                                word: word,
                                isFound: foundIndices.contains(index),
                                isTarget: word == targetWord
                            ) {
                                checkWord(word, at: index)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.top)
            }
            
            if showMissed {
                ResultOverlay(isCorrect: false, correctAnswer: targetWord, isMissed: true)
            }
        }
        .navigationTitle("Word Hunter")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
        .onAppear {
            setupRound()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setupRound() {
        targetWord = allWords.randomElement() ?? "apple"

        var words = [targetWord]
        let distractors = allWords.filter { $0 != targetWord }.shuffled().prefix(gridSize - 1)
        words.append(contentsOf: distractors)
        gridWords = words.shuffled()
        
        foundIndices = []
        timeRemaining = 15
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                HapticManager.shared.wrongAnswer()
                SoundManager.shared.playIncorrect()
                showMissed = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showMissed = false
                    nextRound(correct: false)
                }
            }
        }
    }
    
    private func checkWord(_ word: String, at index: Int) {
        HapticManager.shared.tap()
        
        if word == targetWord {
            foundIndices.insert(index)
            score += 1
            HapticManager.shared.correctAnswer()
            SoundManager.shared.playCorrect()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                nextRound(correct: true)
            }
        } else {
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.playIncorrect()
        }
    }
    
    private func nextRound(correct: Bool) {
        if currentRound < totalRounds - 1 {
            currentRound += 1
            setupRound()
        } else {
            timer?.invalidate()
            gameComplete = true
            SoundManager.shared.playCompletion()
            
            let result = ExerciseResult(
                id: UUID(),
                exerciseType: .wordHunter,
                score: score,
                maxScore: totalRounds,
                completedAt: Date(),
                duration: TimeInterval((totalRounds * 15) - timeRemaining)
            )
            progressManager.recordExerciseResult(result)
        }
    }
}


struct WordButton: View {
    let word: String
    let isFound: Bool
    let isTarget: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word)
                .font(.neuroSubheadline)
                .foregroundColor(isFound ? .neuroSuccess : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isFound 
                        ? Color.neuroSuccess.opacity(0.2) 
                        : Color.neuroSurface
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFound ? Color.neuroSuccess : Color.white.opacity(0.1), lineWidth: 2)
                )
        }
        .disabled(isFound)
    }
}


struct SpeedReadingGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    enum GamePhase {
        case selectingStory
        case reading
        case quiz
        case complete
    }
    
    enum ReadMode: String, CaseIterable, Identifiable {
        case tap = "Tap to Read"
        case auto = "Auto"
        case complete = "Complete Read"
        var id: String { rawValue }
    }
    
    @State private var phase: GamePhase = .selectingStory
    @State private var selectedStory: ReadingStory? = nil
    @State private var readMode: ReadMode = .tap
    
    @State private var currentWordIndex = 0
    @State private var wordsRead = 0
    @State private var startTime = Date()
    @State private var readingEndTime: Date?
    @State private var wordsPerMinute: Double = 150
    @State private var timer: Timer?

    @State private var currentQuestionIndex = 0
    @State private var quizScore = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showQuizFeedback = false
    
    private var words: [String] {
        guard let text = selectedStory?.text else { return [] }
        return text.split(separator: " ").map(String.init)
    }
    
    private var currentWord: String {
        guard currentWordIndex < words.count else { return "" }
        return words[currentWordIndex]
    }
    
    private var interval: TimeInterval {
        60.0 / wordsPerMinute
    }
    
    private var currentQuestion: QuizQuestion {
        let defaultQuestion = QuizQuestion(question: "Error", options: ["Error"], correctIndex: 0)
        guard let questions = selectedStory?.questions, currentQuestionIndex < questions.count else { return defaultQuestion }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                switch phase {
                case .selectingStory:
                    librarySelectionView
                case .reading:
                    readingView
                case .quiz:
                    quizView
                case .complete:
                    SpeedReadingComplete(
                        wordsRead: wordsRead,
                        wpm: calculateWPM(),
                        duration: readingEndTime?.timeIntervalSince(startTime) ?? 0,
                        quizScore: quizScore,
                        totalQuestions: selectedStory?.questions.count ?? 0,
                        onDismiss: { dismiss() }
                    )
                }
            }
        }
        .navigationTitle(phase == .selectingStory ? "Library" : "Speed Reading")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
        .onChange(of: readMode) { _, newValue in
            timer?.invalidate()
            timer = nil
            if newValue == .auto && phase == .reading {
                toggleAutoPlay()
            }
        }
        .onChange(of: wordsPerMinute) { _, _ in
            if readMode == .auto && timer != nil {
                timer?.invalidate()
                timer = nil
                toggleAutoPlay()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var librarySelectionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose a Story")
                    .font(.neuroHeadline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(ReadingLibrary.stories) { story in
                        Button {
                            startReading(story)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: story.icon)
                                        .font(.title2)
                                        .foregroundColor(.neuroPrimary)
                                    Spacer()
                                    Text("\(story.wordCount) words")
                                        .font(.neuroCaption)
                                        .foregroundColor(.neuroTextMuted)
                                }
                                
                                Text(story.title)
                                    .font(.neuroBody)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Text(story.genre)
                                    .font(.neuroCaption)
                                    .foregroundColor(.neuroPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.neuroPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.neuroSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private func startReading(_ story: ReadingStory) {
        HapticManager.shared.tap()
        selectedStory = story
        currentWordIndex = 0
        wordsRead = 0
        currentQuestionIndex = 0
        quizScore = 0
        readingEndTime = nil
        phase = .reading
        startTime = Date()
        if readMode == .auto {
            toggleAutoPlay()
        }
    }

    @ViewBuilder
    private var readingView: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $readMode) {
                ForEach(ReadMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if readMode == .auto {
                HStack {
                    Text("Speed: \(Int(wordsPerMinute)) WPM")
                        .font(.neuroCaption)
                        .foregroundColor(.neuroTextMuted)
                    Slider(value: $wordsPerMinute, in: 60...400, step: 10)
                        .tint(.neuroPrimary)
                        .frame(width: 150)
                }
            } else if readMode == .tap {
                Text("Tap the word when you've read it")
                    .font(.neuroCaption)
                    .foregroundColor(.neuroTextMuted)
            } else if readMode == .complete {
                Text("Read at your own pace")
                    .font(.neuroCaption)
                    .foregroundColor(.neuroTextMuted)
            }
            
            if readMode == .complete {
                TransformedTextView(text: selectedStory?.text ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button {
                    HapticManager.shared.buttonPress()
                    wordsRead = words.count
                    readingEndTime = Date()
                    phase = .quiz
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("I'm Finished Reading")
                    }
                    .font(.neuroBody)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.neuroPrimary)
                    .clipShape(Capsule())
                    .shadow(color: Color.neuroPrimary.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.bottom, 8)
            } else {
                Spacer()
                
                Button {
                    if readMode == .tap {
                        nextWord()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.neuroSurface)
                            .frame(height: 200)
                        
                        VStack(spacing: 12) {
                            Text(currentWord)
                                .font(Font.appFont(size: 48, weight: .bold, design: .rounded, context: .game))
                                .foregroundColor(.white)
                            
                            if readMode == .tap {
                                Text("tap to continue →")
                                    .font(.neuroCaption)
                                    .foregroundColor(.neuroTextMuted)
                            }
                        }
                    }
                }
                .disabled(readMode == .auto)
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentWordIndex + 1), total: Double(max(1, words.count)))
                        .tint(.neuroPrimary)
                    
                    Text("\(currentWordIndex + 1)/\(words.count) words")
                        .font(.neuroCaption)
                        .foregroundColor(.neuroTextMuted)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                         phase = .selectingStory
                         timer?.invalidate()
                         timer = nil
                    } label: {
                        Image(systemName: "books.vertical")
                            .font(.title2)
                            .foregroundColor(.neuroTextSecondary)
                            .frame(width: 60, height: 60)
                            .background(Color.neuroSurface)
                            .clipShape(Circle())
                    }
                    
                    if readMode == .auto {
                        Button {
                            toggleAutoPlay()
                        } label: {
                            Image(systemName: timer != nil ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.neuroPrimary)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }

    private var quizView: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Question \(currentQuestionIndex + 1)/\(selectedStory?.questions.count ?? 0)")
                    .font(.neuroSubheadline)
                    .foregroundColor(.neuroTextSecondary)
                
                Spacer()
                
                Text("Score: \(quizScore)")
                    .font(.neuroSubheadline)
                    .foregroundColor(.neuroPrimary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.neuroPrimary)
                
                Text("Comprehension Check")
                    .font(.neuroHeadline)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                
                Text(currentQuestion.question)
                    .font(.neuroBody)
                    .foregroundColor(.neuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectAnswer(index)
                    } label: {
                        HStack {
                            Text("•")
                                .font(.title2)
                                .foregroundColor(answerColor(for: index))
                            
                            Text(option)
                                .font(.neuroBody)
                                .foregroundColor(answerColor(for: index))
                                .lineLimit(nil)
                                .minimumScaleFactor(0.7)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if showQuizFeedback && index == currentQuestion.correctIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.neuroSuccess)
                            } else if showQuizFeedback && selectedAnswer == index && index != currentQuestion.correctIndex {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.neuroError)
                            }
                        }
                        .padding()
                        .background(answerBackground(for: index))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(showQuizFeedback)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private func answerColor(for index: Int) -> Color {
        if !showQuizFeedback {
            return selectedAnswer == index ? .white : .neuroTextSecondary
        }
        if index == currentQuestion.correctIndex {
            return .neuroSuccess
        }
        if selectedAnswer == index {
            return .neuroError
        }
        return .neuroTextMuted
    }
    
    private func answerBackground(for index: Int) -> Color {
        if !showQuizFeedback {
            return selectedAnswer == index ? Color.neuroPrimary.opacity(0.3) : Color.neuroSurface
        }
        if index == currentQuestion.correctIndex {
            return Color.neuroSuccess.opacity(0.2)
        }
        if selectedAnswer == index {
            return Color.neuroError.opacity(0.2)
        }
        return Color.neuroSurface
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        showQuizFeedback = true
        
        if index == currentQuestion.correctIndex {
            quizScore += 1
            HapticManager.shared.correctAnswer()
            SoundManager.shared.playCorrect()
        } else {
            HapticManager.shared.wrongAnswer()
            SoundManager.shared.playIncorrect()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showQuizFeedback = false
            selectedAnswer = nil
            
            if let total = selectedStory?.questions.count, currentQuestionIndex < total - 1 {
                currentQuestionIndex += 1
            } else {
                finishGame()
            }
        }
    }
    
    private func nextWord() {
        HapticManager.shared.tap()
        wordsRead += 1
        
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
        } else {
            readingEndTime = Date()
            timer?.invalidate()
            timer = nil
            phase = .quiz
        }
    }
    
    private func toggleAutoPlay() {
        HapticManager.shared.buttonPress()
        
        if timer != nil {
             timer?.invalidate()
             timer = nil
        } else {
             timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                 nextWord()
             }
        }
    }
    
    private func resetGame() {
        HapticManager.shared.tap()
        timer?.invalidate()
        timer = nil
        currentWordIndex = 0
        wordsRead = 0
        startTime = Date()
        readingEndTime = nil
        phase = .reading
        currentQuestionIndex = 0
        quizScore = 0
    }
    
    private func calculateWPM() -> Int {
        let duration = (readingEndTime ?? Date()).timeIntervalSince(startTime)
        guard duration > 0 else { return 0 }
        return Int(Double(wordsRead) / (duration / 60.0))
    }
    
    private func finishGame() {
        phase = .complete
        SoundManager.shared.playCompletion()

        let totalScore = quizScore
        let maxScore = selectedStory?.questions.count ?? 0
        
        let result = ExerciseResult(
            id: UUID(),
            exerciseType: .speedReading,
            score: totalScore,
            maxScore: maxScore,
            completedAt: Date(),
            duration: (readingEndTime ?? Date()).timeIntervalSince(startTime)
        )
        progressManager.recordExerciseResult(result)
    }
}



struct SpeedReadingComplete: View {
    let wordsRead: Int
    let wpm: Int
    let duration: TimeInterval
    let quizScore: Int
    let totalQuestions: Int
    let onDismiss: () -> Void
    
    private var formattedDuration: String {
        let seconds = Int(duration)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }
    
    private var quizPercentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(quizScore) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: quizPercentage >= 67 ? "checkmark.seal.fill" : "bolt.fill")
                .font(.system(size: 60))
                .foregroundColor(.neuroPrimary)
            
            Text("Speed Reading Complete!")
                .font(Font.appFont(size: 28, weight: .bold, design: .rounded, context: .general))
                .foregroundColor(.white)
                .lineLimit(nil)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    VStack {
                        Text("\(wordsRead)")
                            .font(Font.appFont(size: 28, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(.neuroPrimary)
                        Text("Words")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                    }
                    
                    VStack {
                        Text("\(wpm)")
                            .font(Font.appFont(size: 28, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(.neuroSuccess)
                        Text("WPM")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                    }
                    
                    VStack {
                        Text(formattedDuration)
                            .font(Font.appFont(size: 28, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(.neuroAccent)
                        Text("Time")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                VStack(spacing: 8) {
                    Text("Comprehension Quiz")
                        .font(.neuroSubheadline)
                        .foregroundColor(.neuroTextSecondary)
                    
                    HStack(spacing: 8) {
                        Text("\(quizScore)/\(totalQuestions)")
                            .font(Font.appFont(size: 24, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(quizPercentage >= 67 ? .neuroSuccess : .neuroWarning)
                        
                        Text("(\(quizPercentage)%)")
                            .font(.neuroBody)
                            .foregroundColor(.neuroTextMuted)
                    }
                }
            }
            .neuroCard()
            
            Text(quizPercentage >= 67 
                ? "Great comprehension! Keep practicing!"
                : "Try reading more carefully next time!")
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
    }
}


struct LetterDetectiveGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var gameComplete = false
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var isMissed = false
    @State private var startTime = Date()
    @State private var correctFoundIndex: Int? = nil
    
    private let totalRounds = 10
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    private let pairs: [(Character, Character)] = [
        ("b", "d"), ("p", "q"), ("m", "w"), ("n", "u"),
        ("b", "d"), ("p", "q"), ("m", "w"), ("n", "u"),
        ("b", "d"), ("p", "q")
    ]
    
    @State private var currentLetter: Character = "b"
    @State private var gridLetters: [Character] = Array(repeating: "d", count: 25)
    @State private var correctGridIndex: Int = 0
    @State private var timeRemaining = 15
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow
                .opacity(0.3)
                .ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(
                    score: score,
                    maxScore: totalRounds,
                    exerciseType: .letterDetective,
                    onDismiss: { dismiss() }
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Round \(currentRound + 1)/\(totalRounds)")
                                .font(.neuroSubheadline)
                                .foregroundColor(.neuroTextSecondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("\(timeRemaining)s")
                            }
                            .font(.neuroSubheadline)
                            .foregroundColor(timeRemaining <= 5 ? .neuroError : .neuroTextSecondary)
                            
                            Spacer()
                            
                            Text("Score: \(score)")
                                .font(.neuroSubheadline)
                                .foregroundColor(.neuroPrimary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            Text("Find the letter:")
                                .font(.neuroBody)
                                .foregroundColor(.neuroTextSecondary)
                            
                            Text(String(currentLetter))
                                .font(Font.appFont(size: 48, weight: .bold, design: .rounded, context: .game))
                                .foregroundColor(.neuroPrimary)
                                .frame(width: 80, height: 100)
                                .background(Color.neuroSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                                  )
                        }
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(0..<25, id: \.self) { index in
                                let isFound = correctFoundIndex == index
                                Button {
                                    if !showFeedback {
                                        checkAnswer(selectedIndex: index)
                                    }
                                } label: {
                                    Text(String(gridLetters[index]))
                                        .font(Font.appFont(size: 28, weight: .semibold, design: .rounded, context: .game))
                                        .foregroundColor(isFound ? .white : .neuroPrimary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(isFound ? Color.neuroSuccess : Color.neuroSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isFound ? Color.neuroSuccess : Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                }
                                .disabled(showFeedback)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Similar letters can be confusing.\nTrain your eye to spot the difference!")
                            .font(.neuroCaption)
                            .foregroundColor(.neuroTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                    }
                    .padding(.top)
                }
            }
            
            if showFeedback {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: String(currentLetter), isMissed: isMissed)
            }
        }
        .navigationTitle("Letter Detective")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
        .onAppear {
            setupRound()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func setupRound() {
        let pair = pairs[currentRound % pairs.count]
        currentLetter = Bool.random() ? pair.0 : pair.1
        let distractor = (currentLetter == pair.0) ? pair.1 : pair.0
        
        var tempGrid = Array(repeating: distractor, count: 25)
        correctGridIndex = Int.random(in: 0..<25)
        tempGrid[correctGridIndex] = currentLetter
        gridLetters = tempGrid
        correctFoundIndex = nil
        timeRemaining = 15
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                handleTimeOut()
            }
        }
    }
    
    private func handleTimeOut() {
        timer?.invalidate()
        isCorrect = false
        isMissed = true
        HapticManager.shared.wrongAnswer()
        SoundManager.shared.playIncorrect()
        showFeedback = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFeedback = false
            
            if currentRound < totalRounds - 1 {
                currentRound += 1
                setupRound()
                startTimer()
            } else {
                completeGame()
            }
        }
    }
    
    private func checkAnswer(selectedIndex: Int) {
        if selectedIndex == correctGridIndex {
            timer?.invalidate()
            isCorrect = true
            isMissed = false
            correctFoundIndex = selectedIndex
            score += 1
            HapticManager.shared.correctAnswer()
            SoundManager.shared.playCorrect()
            showFeedback = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showFeedback = false
                
                if currentRound < totalRounds - 1 {
                    currentRound += 1
                    setupRound()
                    startTimer()
                } else {
                    completeGame()
                }
            }
        } else {
            // Wrong answer — haptic + sound feedback, no visual change
            HapticManager.shared.tap()
            SoundManager.shared.playIncorrect()
        }
    }
    
    private func completeGame() {
        timer?.invalidate()
        gameComplete = true
        SoundManager.shared.playCompletion()
        
        let result = ExerciseResult(
            id: UUID(),
            exerciseType: .letterDetective,
            score: score,
            maxScore: totalRounds,
            completedAt: Date(),
            duration: Date().timeIntervalSince(startTime)
        )
        progressManager.recordExerciseResult(result)
    }
}

#Preview {
    WordHunterGame()
        .environmentObject(ProgressManager())
}
