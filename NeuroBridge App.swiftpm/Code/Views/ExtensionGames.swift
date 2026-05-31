import SwiftUI
import AVFoundation

// MARK: - Sentence Builder Game
struct SentenceBuilderGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var gameComplete = false
    
    struct WordItem: Identifiable, Equatable {
        let id = UUID()
        let text: String
    }
    
    private let sentences: [[String]] = [
        ["I", "went", "to", "the", "store"],
        ["The", "dog", "barked", "very", "loudly"],
        ["She", "read", "a", "good", "book"],
        ["We", "walked", "in", "the", "park"],
        ["He", "ate", "a", "red", "apple"],
        ["The", "sun", "is", "very", "bright"],
        ["Cats", "like", "to", "sleep", "all", "day"],
        ["The", "bird", "flew", "over", "the", "tree"],
        ["He", "kicked", "the", "ball", "far", "away"],
        ["She", "has", "a", "new", "blue", "bike"],
        ["We", "will", "go", "to", "the", "beach"],
        ["The", "little", "boy", "ran", "very", "fast"],
        ["I", "saw", "a", "big", "brown", "bear"],
        ["They", "played", "games", "in", "the", "yard"],
        ["Mom", "baked", "a", "sweet", "chocolate", "cake"],
        ["The", "frog", "jumped", "into", "the", "pond"],
        ["He", "found", "a", "shiny", "gold", "coin"],
        ["She", "painted", "a", "beautiful", "picture"],
        ["The", "stars", "shine", "in", "the", "night"],
        ["We", "built", "a", "tall", "sand", "castle"]
    ]
    
    @State private var availableWords: [WordItem] = []
    @State private var builtWords: [WordItem?] = []
    @State private var isCorrect = false
    @State private var showingResult = false
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow.opacity(0.3).ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(score: score, maxScore: sentences.count, exerciseType: .sentenceBuilder, onDismiss: { dismiss() })
            } else {
                VStack(spacing: 24) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(sentences.count)").font(.neuroSubheadline).foregroundColor(.neuroTextSecondary)
                        Spacer()
                        Text("Score: \(score)").font(.neuroSubheadline).foregroundColor(.neuroPrimary)
                    }.padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Build the sentence").font(.neuroHeadline).foregroundColor(.white)
                        
                        // Empty Slots Area
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8.adaptive) {
                                ForEach(Array(builtWords.enumerated()), id: \.offset) { index, item in
                                    if let item = item {
                                        Button {
                                            returnWord(item, from: index)
                                        } label: {
                                            Text(item.text)
                                                .font(.neuroBody)
                                                .foregroundColor(.white)
                                                .fixedSize()
                                                .padding(.horizontal, 16.adaptive)
                                                .padding(.vertical, 12.adaptive)
                                                .background(Color.neuroPrimary)
                                                .clipShape(RoundedRectangle(cornerRadius: 12.adaptive))
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 12.adaptive)
                                            .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                            .frame(height: 44.adaptive)
                                            .frame(minWidth: 60.adaptive)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 12.adaptive)
                        .background(Color.neuroSurfaceLight.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                    }
                    
                    // Available Words Area - centered
                    FlowLayout(spacing: 12) {
                        ForEach(availableWords) { item in
                            Button {
                                placeWord(item)
                            } label: {
                                Text(item.text)
                                    .font(.neuroBody)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 24)
                                    .background(Color.neuroSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        checkAnswer()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Check Sentence")
                        }
                    }
                    .buttonStyle(NeuroButtonStyle())
                    .disabled(builtWords.contains(nil))
                    .opacity(builtWords.contains(nil) ? 0.5 : 1)
                }.padding()
            }
            
            if showingResult {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: sentences[currentRound].joined(separator: " "))
            }
        }
        .navigationTitle("Sentence Builder")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
        .onAppear { setupRound() }
    }
    
    private func setupRound() {
        let currentTarget = sentences[currentRound]
        availableWords = currentTarget.map { WordItem(text: $0) }.shuffled()
        builtWords = Array(repeating: nil, count: currentTarget.count)
    }
    
    private func placeWord(_ item: WordItem) {
        HapticManager.shared.tap()
        guard let itemIndex = availableWords.firstIndex(where: { $0.id == item.id }) else { return }
        
        if let emptyIndex = builtWords.firstIndex(of: nil) {
            builtWords[emptyIndex] = item
            availableWords.remove(at: itemIndex)
        }
    }
    
    private func returnWord(_ item: WordItem, from index: Int) {
        HapticManager.shared.tap()
        guard builtWords[index]?.id == item.id else { return }
        
        builtWords[index] = nil
        availableWords.append(item)
    }
    
    private func checkAnswer() {
        let target = sentences[currentRound].joined(separator: " ")
        let userSentence = builtWords.compactMap { $0?.text }.joined(separator: " ")
        
        isCorrect = (target == userSentence)
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
            if currentRound < sentences.count - 1 {
                currentRound += 1
                setupRound()
            } else {
                finishGame()
            }
        }
    }
    
    private func finishGame() {
        gameComplete = true
        SoundManager.shared.playCompletion()
        let result = ExerciseResult(id: UUID(), exerciseType: .sentenceBuilder, score: score, maxScore: sentences.count, completedAt: Date(), duration: 0)
        progressManager.recordExerciseResult(result)
    }
}

// MARK: - Rhyme Time Game
struct RhymeTimeGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var gameComplete = false
    @State private var showingResult = false
    @State private var isCorrect = false
    
    private var totalRounds: Int { questions.count }
    
    struct RhymeQuestion: Hashable {
        let word: String
        let options: [String]
        let correctOption: String
    }
    
    private let questions: [RhymeQuestion] = [
        RhymeQuestion(word: "Night", options: ["Note", "Late", "Bite", "Cat"], correctOption: "Bite"),
        RhymeQuestion(word: "Train", options: ["Team", "Brain", "Tree", "Town"], correctOption: "Brain"),
        RhymeQuestion(word: "Boat", options: ["Boot", "Coat", "Bought", "Beat"], correctOption: "Coat"),
        RhymeQuestion(word: "Sky", options: ["See", "Snow", "Cry", "Say"], correctOption: "Cry"),
        RhymeQuestion(word: "Round", options: ["Sound", "Road", "Room", "Run"], correctOption: "Sound"),
        RhymeQuestion(word: "Cat", options: ["Cut", "Cot", "Bat", "Car"], correctOption: "Bat"),
        RhymeQuestion(word: "Tree", options: ["Try", "True", "See", "Tear"], correctOption: "See"),
        RhymeQuestion(word: "Cake", options: ["Cook", "Bake", "Car", "Can"], correctOption: "Bake"),
        RhymeQuestion(word: "Dog", options: ["Log", "Dig", "Dot", "Door"], correctOption: "Log"),
        RhymeQuestion(word: "Book", options: ["Back", "Look", "Box", "Boot"], correctOption: "Look"),
        RhymeQuestion(word: "Pig", options: ["Peg", "Pug", "Dig", "Pie"], correctOption: "Dig"),
        RhymeQuestion(word: "Sun", options: ["Son", "Fun", "Sin", "Sad"], correctOption: "Fun"),
        RhymeQuestion(word: "Car", options: ["Cat", "Far", "Can", "Core"], correctOption: "Far"),
        RhymeQuestion(word: "Sing", options: ["Song", "Ring", "Sink", "Sand"], correctOption: "Ring"),
        RhymeQuestion(word: "House", options: ["Mouse", "Horse", "Hose", "Home"], correctOption: "Mouse"),
        RhymeQuestion(word: "Play", options: ["Plan", "Stay", "Plow", "Plot"], correctOption: "Stay"),
        RhymeQuestion(word: "Bear", options: ["Beer", "Bare", "Care", "Bird"], correctOption: "Care"),
        RhymeQuestion(word: "Tall", options: ["Tell", "Fall", "Tail", "Tool"], correctOption: "Fall"),
        RhymeQuestion(word: "Jump", options: ["Dump", "Bump", "Jam", "Joke"], correctOption: "Bump"),
        RhymeQuestion(word: "Fast", options: ["Fist", "Last", "Fact", "Fest"], correctOption: "Last")
    ]
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow.opacity(0.3).ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(score: score, maxScore: totalRounds, exerciseType: .rhymeTime, onDismiss: { dismiss() })
            } else {
                VStack(spacing: 32) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(totalRounds)").font(.neuroSubheadline).foregroundColor(.neuroTextSecondary)
                        Spacer()
                        Text("Score: \(score)").font(.neuroSubheadline).foregroundColor(.neuroPrimary)
                    }.padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("What rhymes with").font(.neuroBody).foregroundColor(.neuroTextSecondary)
                        Text(questions[currentRound].word)
                            .font(Font.appFont(size: 64, weight: .bold, design: .rounded, context: .game))
                            .foregroundColor(.neuroPrimary)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(questions[currentRound].options, id: \.self) { option in
                            Button {
                                checkAnswer(option)
                            } label: {
                                Text(option)
                                    .font(Font.appFont(size: 28, weight: .medium, design: .rounded, context: .game))
                                    .foregroundColor(.white)
                                    .frame(minHeight: 100)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.neuroSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 2))
                            }
                        }
                    }.padding(.horizontal, 24)
                    
                    Spacer()
                }.padding()
            }
            
            if showingResult {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: questions[currentRound].correctOption)
            }
        }
        .navigationTitle("Rhyme Time")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
    }
    
    private func checkAnswer(_ selected: String) {
        let correct = questions[currentRound].correctOption
        isCorrect = (selected == correct)
        
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
            if currentRound < totalRounds - 1 {
                currentRound += 1
            } else {
                gameComplete = true
                SoundManager.shared.playCompletion()
                let result = ExerciseResult(id: UUID(), exerciseType: .rhymeTime, score: score, maxScore: totalRounds, completedAt: Date(), duration: 0)
                progressManager.recordExerciseResult(result)
            }
        }
    }
}

// MARK: - Right Spell Game
struct RightSpellGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var gameComplete = false
    @State private var showingResult = false
    @State private var isCorrect = false
    
    private var totalRounds: Int { questions.count }
    
    struct SpellQuestion: Hashable {
        let prefix: String
        let suffix: String
        let options: [String]
        let correctOption: String
    }
    
    private let questions: [SpellQuestion] = [
        SpellQuestion(prefix: "They left", suffix: "books on the table.", options: ["there", "their", "they're"], correctOption: "their"),
        SpellQuestion(prefix: "She", suffix: "to the store yesterday.", options: ["whent", "went", "want"], correctOption: "went"),
        SpellQuestion(prefix: "I have", suffix: "apples in my bag.", options: ["too", "to", "two"], correctOption: "two"),
        SpellQuestion(prefix: "Can you", suffix: "the dog?", options: ["sea", "see", "cee"], correctOption: "see"),
        SpellQuestion(prefix: "He is a very", suffix: "friend.", options: ["good", "gud", "gowd"], correctOption: "good"),
        SpellQuestion(prefix: "Can I come", suffix: "?", options: ["to", "too", "two"], correctOption: "too"),
        SpellQuestion(prefix: "Look over", suffix: "!", options: ["their", "there", "they're"], correctOption: "there"),
        SpellQuestion(prefix: "We", suffix: "happy to be here.", options: ["where", "were", "we're"], correctOption: "are"),
        SpellQuestion(prefix: "The cat licked", suffix: "paws.", options: ["its", "it's", "it"], correctOption: "its"),
        SpellQuestion(prefix: "Do you know", suffix: "book this is?", options: ["who's", "whose", "who"], correctOption: "whose"),
        SpellQuestion(prefix: "She", suffix: "away the trash.", options: ["threw", "through", "true"], correctOption: "threw"),
        SpellQuestion(prefix: "We walked", suffix: "the dark forest.", options: ["threw", "through", "though"], correctOption: "through"),
        SpellQuestion(prefix: "He", suffix: "the ball very hard.", options: ["hitt", "hit", "hid"], correctOption: "hit"),
        SpellQuestion(prefix: "She has", suffix: "hair.", options: ["fair", "fare", "fear"], correctOption: "fair"),
        SpellQuestion(prefix: "He wrote a", suffix: "to his friend.", options: ["letter", "lettar", "letur"], correctOption: "letter"),
        SpellQuestion(prefix: "The sky is", suffix: "today.", options: ["blew", "blue", "bloo"], correctOption: "blue"),
        SpellQuestion(prefix: "I", suffix: "about that story.", options: ["knew", "new", "noo"], correctOption: "knew"),
        SpellQuestion(prefix: "Please give me a", suffix: "of cake.", options: ["peace", "piece", "pease"], correctOption: "piece"),
        SpellQuestion(prefix: "We", suffix: "a great time.", options: ["had", "hed", "hud"], correctOption: "had"),
        SpellQuestion(prefix: "He", suffix: "out the candles.", options: ["blue", "blew", "blow"], correctOption: "blew")
    ]
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow.opacity(0.3).ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(score: score, maxScore: totalRounds, exerciseType: .rightSpell, onDismiss: { dismiss() })
            } else {
                VStack(spacing: 32) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(totalRounds)").font(.neuroSubheadline).foregroundColor(.neuroTextSecondary)
                        Spacer()
                        Text("Score: \(score)").font(.neuroSubheadline).foregroundColor(.neuroPrimary)
                    }.padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        Text("Fill in the blank").font(.neuroHeadline).foregroundColor(.white)
                        
                        Text("\(questions[currentRound].prefix) _____ \(questions[currentRound].suffix)")
                            .font(Font.appFont(size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24, weight: .bold, design: .serif, context: .game))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(Color.neuroSurfaceLight.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(questions[currentRound].options, id: \.self) { option in
                            Button {
                                checkAnswer(option)
                            } label: {
                                Text(option)
                                    .font(Font.appFont(size: 24, weight: .medium, design: .rounded, context: .game))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color.neuroSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 2))
                            }
                        }
                    }.padding(.horizontal, 24)
                    
                    Spacer()
                }.padding()
            }
            
            if showingResult {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: questions[currentRound].correctOption)
            }
        }
        .navigationTitle("Right Spell")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
    }
    
    private func checkAnswer(_ selected: String) {
        let correct = questions[currentRound].correctOption
        isCorrect = (selected == correct)
        
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
            if currentRound < totalRounds - 1 {
                currentRound += 1
            } else {
                gameComplete = true
                SoundManager.shared.playCompletion()
                let result = ExerciseResult(id: UUID(), exerciseType: .rightSpell, score: score, maxScore: totalRounds, completedAt: Date(), duration: 0)
                progressManager.recordExerciseResult(result)
            }
        }
    }
}

// MARK: - Phonics Match Game
struct PhonicsMatchGame: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRound = 0
    @State private var score = 0
    @State private var gameComplete = false
    @State private var showingResult = false
    @State private var isCorrect = false
    
    private var totalRounds: Int { questions.count }
    private let synthesizer = AVSpeechSynthesizer()
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    struct PhonicsQuestion: Hashable {
        let phoneme: String
        let speechText: String
        let options: [String]
        let correctOption: String
    }
    
    private let questions: [PhonicsQuestion] = [
        PhonicsQuestion(phoneme: "sh", speechText: "shhhhh", options: ["ch", "sh", "th", "ph"], correctOption: "sh"),
        PhonicsQuestion(phoneme: "ch", speechText: "chuh", options: ["sh", "ch", "th", "wh"], correctOption: "ch"),
        PhonicsQuestion(phoneme: "th", speechText: "thuh", options: ["ph", "ch", "th", "sh"], correctOption: "th"),
        PhonicsQuestion(phoneme: "ph", speechText: "fff", options: ["th", "wh", "ph", "gh"], correctOption: "ph"),
        PhonicsQuestion(phoneme: "wh", speechText: "wuh", options: ["wh", "th", "sh", "ch"], correctOption: "wh"),
        PhonicsQuestion(phoneme: "ee", speechText: "eeeee", options: ["ea", "ee", "ey", "ie"], correctOption: "ee"),
        PhonicsQuestion(phoneme: "oo", speechText: "oooo", options: ["ou", "ow", "oo", "ue"], correctOption: "oo"),
        PhonicsQuestion(phoneme: "ar", speechText: "arrrr", options: ["er", "or", "ur", "ar"], correctOption: "ar"),
        PhonicsQuestion(phoneme: "or", speechText: "orrrr", options: ["ar", "er", "ur", "or"], correctOption: "or"),
        PhonicsQuestion(phoneme: "er", speechText: "errrr", options: ["ar", "or", "ur", "er"], correctOption: "er"),
        PhonicsQuestion(phoneme: "ou", speechText: "oww", options: ["ow", "ou", "oo", "oa"], correctOption: "ou"),
        PhonicsQuestion(phoneme: "ow", speechText: "owww", options: ["ou", "ow", "oo", "aw"], correctOption: "ow"),
        PhonicsQuestion(phoneme: "oi", speechText: "oyyy", options: ["oy", "oi", "ou", "oo"], correctOption: "oi"),
        PhonicsQuestion(phoneme: "oy", speechText: "oyyyyy", options: ["oi", "oy", "ou", "ow"], correctOption: "oy"),
        PhonicsQuestion(phoneme: "aw", speechText: "awww", options: ["au", "aw", "ou", "ow"], correctOption: "aw"),
        PhonicsQuestion(phoneme: "au", speechText: "auuuu", options: ["aw", "au", "ou", "oa"], correctOption: "au"),
        PhonicsQuestion(phoneme: "ew", speechText: "ewww", options: ["ue", "ew", "oo", "ui"], correctOption: "ew"),
        PhonicsQuestion(phoneme: "ue", speechText: "ueeee", options: ["ew", "ue", "oo", "ou"], correctOption: "ue")
    ]
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow.opacity(0.3).ignoresSafeArea()
            
            if gameComplete {
                GameCompleteView(score: score, maxScore: totalRounds, exerciseType: .phonicsMatch, onDismiss: { dismiss() })
            } else {
                VStack(spacing: 32) {
                    HStack {
                        Text("Round \(currentRound + 1)/\(totalRounds)").font(.neuroSubheadline).foregroundColor(.neuroTextSecondary)
                        Spacer()
                        Text("Score: \(score)").font(.neuroSubheadline).foregroundColor(.neuroPrimary)
                    }.padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        HapticManager.shared.tap()
                        playSound()
                    } label: {
                        VStack(spacing: 24) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.neuroPrimary)
                                .padding(60)
                                .background(Color.neuroSurface)
                                .clipShape(Circle())
                                .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 20)
                                
                            Text("Tap to Hear Sound")
                                .font(.neuroHeadline)
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 10) {
                        ForEach(questions[currentRound].options, id: \.self) { option in
                            Button {
                                checkAnswer(option)
                            } label: {
                                Text(option)
                                    .font(Font.appFont(size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 26, weight: .bold, design: .rounded, context: .game))
                                    .foregroundColor(.white)
                                    .lineLimit(nil)
                                    .minimumScaleFactor(0.5)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 64)
                                    .background(Color.neuroSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 2))
                            }
                        }
                    }.padding(.horizontal)
                    
                    Spacer()
                }.padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        playSound()
                    }
                }
            }
            
            if showingResult {
                ResultOverlay(isCorrect: isCorrect, correctAnswer: questions[currentRound].correctOption)
            }
        }
        .navigationTitle("Phonics Match")
        .navigationBarTitleDisplayMode(.inline)
        .gameContext()
    }
    
    private func playSound() {
        let question = questions[currentRound]
        // Checks if Custom Asset exists, otherwise uses Synthesizer
        if let url = Bundle.main.url(forResource: question.phoneme + "_sound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                fallbackToSynthesizer(text: question.speechText)
            }
        } else {
            fallbackToSynthesizer(text: question.speechText)
        }
    }
    
    private func fallbackToSynthesizer(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    private func checkAnswer(_ selected: String) {
        let correct = questions[currentRound].correctOption
        isCorrect = (selected == correct)
        
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
            if currentRound < totalRounds - 1 {
                currentRound += 1
                playSound()
            } else {
                gameComplete = true
                SoundManager.shared.playCompletion()
                let result = ExerciseResult(id: UUID(), exerciseType: .phonicsMatch, score: score, maxScore: totalRounds, completedAt: Date(), duration: 0)
                progressManager.recordExerciseResult(result)
            }
        }
    }
}

