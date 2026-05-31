import SwiftUI


struct TextTransformation: Codable, Equatable {
    var useDyslexicFont: Bool = true
    var fontScale: CGFloat = 1.2
    var letterSpacing: CGFloat = 2.0
    var wordSpacing: CGFloat = 4.0
    var lineSpacing: CGFloat = 12.0
    var overlayColor: OverlayColor = .cream
    var showSyllables: Bool = false
    var focusModeEnabled: Bool = false
    var highlightCurrentLine: Bool = false
    
    enum OverlayColor: String, Codable, CaseIterable {
        case none = "None"
        case cream = "Cream"
        case lightBlue = "Light Blue"
        case lightGreen = "Light Green"
        case lavender = "Lavender"
        case peach = "Peach"
        
        var color: Color {
            switch self {
            case .none: return .clear
            case .cream: return Color(red: 1.0, green: 0.98, blue: 0.9).opacity(0.15)
            case .lightBlue: return Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.15)
            case .lightGreen: return Color(red: 0.7, green: 1.0, blue: 0.7).opacity(0.15)
            case .lavender: return Color(red: 0.9, green: 0.7, blue: 1.0).opacity(0.15)
            case .peach: return Color(red: 1.0, green: 0.8, blue: 0.7).opacity(0.15)
            }
        }
    }
}


struct ReadingProfile: Codable {
    var name: String = ""
    var age: Int = 0
    var readingLevel: ReadingLevel = .beginner
    var preferredTransformation: TextTransformation = TextTransformation()
    var createdAt: Date = Date()
    
    enum ReadingLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}


struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_steps", title: "First Steps", description: "Complete the onboarding", icon: "star.fill"),
        Achievement(id: "bookworm", title: "Bookworm", description: "Read 100 words", icon: "book.fill"),
        Achievement(id: "sharp_eye", title: "Sharp Eye", description: "Get 100% accuracy in an exercise", icon: "eye.fill"),
        Achievement(id: "syllable_master", title: "Syllable Master", description: "Complete Syllable Splitter", icon: "textformat.size"),
        Achievement(id: "word_hunter", title: "Word Hunter", description: "Complete Word Hunter", icon: "magnifyingglass"),
        Achievement(id: "speed_demon", title: "Speed Demon", description: "Complete Speed Reading", icon: "hare.fill"),
        Achievement(id: "detective_eye", title: "Detective Eye", description: "Complete Letter Detective", icon: "eye.trianglebadge.exclamationmark"),
        Achievement(id: "sentence_master", title: "Sentence Master", description: "Complete Sentence Builder", icon: "text.alignleft"),
        Achievement(id: "phonetic_genius", title: "Phonetic Genius", description: "Complete Phonics Match", icon: "ear"),
        Achievement(id: "rhyme_lord", title: "Rhyme Lord", description: "Complete Rhyme Time", icon: "music.note"),
        Achievement(id: "perfect_speller", title: "Perfect Speller", description: "Complete Right Spell", icon: "character.book.closed"),
        Achievement(id: "champion", title: "Reading Champion", description: "Complete all exercises", icon: "trophy.fill")
    ]
}


struct ExerciseResult: Identifiable, Codable {
    let id: UUID
    let exerciseType: ExerciseType
    let score: Int
    let maxScore: Int
    let completedAt: Date
    let duration: TimeInterval
    
    var accuracy: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore) * 100
    }
    
    enum ExerciseType: String, Codable, CaseIterable {
        case syllableSplitter = "Syllable Splitter"
        case wordHunter = "Word Hunter"
        case speedReading = "Speed Reading"
        case letterDetective = "Letter Detective"
        case sentenceBuilder = "Sentence Builder"
        case phonicsMatch = "Phonics Match"
        case rhymeTime = "Rhyme Time"
        case rightSpell = "Right Spell"
        
        var icon: String {
            switch self {
            case .syllableSplitter: return "textformat.abc"
            case .wordHunter: return "magnifyingglass"
            case .speedReading: return "gauge.with.dots.needle.67percent"
            case .letterDetective: return "eye.trianglebadge.exclamationmark"
            case .sentenceBuilder: return "text.alignleft"
            case .phonicsMatch: return "ear"
            case .rhymeTime: return "music.note"
            case .rightSpell: return "character.book.closed"
            }
        }
        
        var color: Color {
            switch self {
            case .syllableSplitter: return .blue
            case .wordHunter: return .green
            case .speedReading: return .orange
            case .letterDetective: return .purple
            case .sentenceBuilder: return .indigo
            case .phonicsMatch: return .teal
            case .rhymeTime: return .pink
            case .rightSpell: return .cyan
            }
        }
    }
}


struct SampleText: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let difficulty: Difficulty
    let category: String
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            }
        }
    }
    
    static let samples: [SampleText] = [
        // EASY
        SampleText(
            id: "1",
            title: "The Friendly Dog",
            content: "The big brown dog ran across the green grass. He was happy to see his friend. They played together all day long. When the sun started to set, the dog lay down under the old oak tree and watched the stars come out one by one.",
            difficulty: .easy,
            category: "Stories"
        ),
        SampleText(
            id: "2",
            title: "A Day at School",
            content: "Every morning, children walk to school with their backpacks. They learn many things like reading, writing, and mathematics. The teacher helps them understand new ideas. At lunch, they sit together and share stories about their weekends.",
            difficulty: .easy,
            category: "Stories"
        ),
        SampleText(
            id: "5",
            title: "The Butterfly Garden",
            content: "Butterflies flutter gently between bright flowers. Each one has beautiful patterns on its wings. Some are orange, some are blue, and some have spots like tiny eyes. If you sit very still, one might land on your hand.",
            difficulty: .easy,
            category: "Nature"
        ),
        SampleText(
            id: "6",
            title: "My Pet Cat",
            content: "My cat Whiskers likes to sleep in sunny spots. She purrs when I pet her soft fur. In the morning she waits by her bowl for breakfast. At night she curls up at the end of my bed and keeps my feet warm.",
            difficulty: .easy,
            category: "Stories"
        ),
        SampleText(
            id: "7",
            title: "Rainy Day Fun",
            content: "When it rains, I like to sit by the window and watch the drops race down the glass. Sometimes I draw pictures or build towers with blocks. My little brother and I make paper boats and float them in puddles outside.",
            difficulty: .easy,
            category: "Stories"
        ),
        SampleText(
            id: "8",
            title: "The Little Seed",
            content: "A tiny seed fell into the dark soil. Rain came and gave it water. The warm sun shone down every day. Slowly, a small green sprout pushed up through the earth. Weeks later, it grew into a tall sunflower reaching for the sky.",
            difficulty: .easy,
            category: "Nature"
        ),
        // MEDIUM
        SampleText(
            id: "3",
            title: "The Ocean Adventure",
            content: "The submarine descended into the deep blue ocean. Colorful fish swam past the windows, their scales shimmering in the dim light. The captain carefully navigated through the underwater canyon, avoiding jagged rocks that jutted out from the walls. A giant manta ray glided overhead, casting a shadow across the vessel. The crew held their breath as they spotted something glowing in the distance — an ancient shipwreck covered in coral and sea anemones.",
            difficulty: .medium,
            category: "Adventure"
        ),
        SampleText(
            id: "9",
            title: "The Mountain Trail",
            content: "Elena laced up her hiking boots and set off before dawn. The mountain trail wound through pine forests where morning mist hung like curtains between the trees. As she climbed higher, the air grew thin and crisp. By midday she reached a rocky ledge overlooking a valley filled with wildflowers. Eagles circled overhead, riding invisible currents of warm air. She unpacked her lunch and sat quietly, feeling like the only person in the world.",
            difficulty: .medium,
            category: "Adventure"
        ),
        SampleText(
            id: "10",
            title: "How Volcanoes Work",
            content: "Deep beneath the surface of the Earth, temperatures are hot enough to melt rock. This melted rock, called magma, sometimes rises through cracks in the Earth's crust. When pressure builds up enough, the magma bursts through the surface in an eruption. The magma that flows out is called lava. Over thousands of years, layers of hardened lava build up to form the cone shape of a volcano. Some volcanoes are dormant, meaning they have not erupted in a very long time but could erupt again.",
            difficulty: .medium,
            category: "Science"
        ),
        SampleText(
            id: "11",
            title: "The Robot's First Day",
            content: "Unit-7 opened its optical sensors for the first time and saw a laboratory filled with blinking screens and humming machines. A scientist named Dr. Park smiled and said, 'Good morning.' Unit-7 searched its vocabulary database and replied, 'Good morning, Dr. Park. What is my purpose?' She laughed. 'Today you learn. Tomorrow you help.' Unit-7 found this answer incomplete but stored it in memory anyway, along with a note: humans often give answers that create more questions.",
            difficulty: .medium,
            category: "Sci-Fi"
        ),
        SampleText(
            id: "12",
            title: "The Night Market",
            content: "The night market came alive as the sun disappeared behind the hills. Strings of golden lights zigzagged above the crowded lanes. Vendors called out from their stalls, offering grilled corn, sweet rice cakes, and cups of spiced tea. Musicians played drums and flutes near the fountain while children chased each other between the tables. The air smelled of cinnamon and roasted chestnuts. Maria wandered from stall to stall, her eyes wide with wonder at all the colors and sounds.",
            difficulty: .medium,
            category: "Fiction"
        ),
        SampleText(
            id: "13",
            title: "Life in the Coral Reef",
            content: "Coral reefs are sometimes called the rainforests of the sea because they are home to an incredible variety of life. Tiny polyps — the animals that build the reef — create hard skeletons of calcium carbonate over many years. Fish, sea turtles, octopuses, and thousands of other creatures depend on the reef for food and shelter. Unfortunately, rising ocean temperatures cause coral bleaching, which can kill entire reef systems if conditions do not improve.",
            difficulty: .medium,
            category: "Nature"
        ),
        // HARD
        SampleText(
            id: "4",
            title: "Space Exploration",
            content: "Astronauts aboard the International Space Station conduct numerous scientific experiments in microgravity. They study the effects of weightlessness on various biological systems and physical phenomena, contributing valuable knowledge to humanity's understanding of the universe. Research areas include crystal growth, fluid dynamics, and the long-term effects of space travel on the human body. These findings are crucial for planning future missions to Mars and beyond, where astronauts will spend years away from Earth.",
            difficulty: .hard,
            category: "Science"
        ),
        SampleText(
            id: "14",
            title: "The Quantum Garden",
            content: "Professor Nakamura's laboratory existed in a state of controlled chaos. Banks of supercooled processors hummed behind reinforced glass, maintaining qubits in delicate superposition. Her latest experiment attempted to simulate photosynthesis at the quantum level — the mysterious process by which plants convert sunlight into energy with near-perfect efficiency. If she succeeded, the implications for renewable energy would be staggering. But quantum decoherence remained her nemesis, collapsing fragile states before meaningful data could be extracted. She adjusted the electromagnetic shielding and prepared to try once more.",
            difficulty: .hard,
            category: "Sci-Fi"
        ),
        SampleText(
            id: "15",
            title: "The Art of Memory",
            content: "Ancient Greek orators developed sophisticated mnemonic techniques that modern neuroscience is only beginning to understand. The 'method of loci,' also known as the memory palace, involves mentally placing items to be remembered along a familiar walking route. Functional MRI studies reveal that this technique activates the hippocampus and spatial navigation centres simultaneously, essentially hijacking the brain's powerful spatial memory system to store non-spatial information. Championship memory athletes can memorise the order of a shuffled deck of cards in under twenty seconds using these classical methods.",
            difficulty: .hard,
            category: "Non-Fiction"
        ),
        SampleText(
            id: "16",
            title: "The Last Library",
            content: "In the year 2147, physical books had become relics. Most knowledge existed as streams of light in the Global Archive. But in a forgotten corner of Edinburgh, an old stone building still held thousands of paper volumes on wooden shelves. Mira discovered it by accident while sheltering from an acid rain storm. She pulled a leather-bound volume from the shelf and felt the rough texture of real pages between her fingers — something she had never experienced before. The words inside were printed in an obsolete typeface, but she could still read them. It was a novel about a girl who discovered a hidden library. Mira laughed at the coincidence and kept reading.",
            difficulty: .hard,
            category: "Sci-Fi"
        ),
        SampleText(
            id: "17",
            title: "Migration Patterns",
            content: "Every autumn, approximately two billion birds migrate across the Mediterranean Sea, navigating by starlight, Earth's magnetic field, and inherited genetic maps passed down through countless generations. The Arctic Tern holds the record for the longest migration of any animal, travelling roughly seventy thousand kilometres each year from Arctic to Antarctic and back. Scientists have discovered that migratory birds can perceive magnetic fields through specialised proteins called cryptochromes in their eyes, effectively giving them a built-in compass that overlays directional information onto their visual field.",
            difficulty: .hard,
            category: "Nature"
        )
    ]
}

struct DailyReadingSession: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var wordsRead: Int
}
