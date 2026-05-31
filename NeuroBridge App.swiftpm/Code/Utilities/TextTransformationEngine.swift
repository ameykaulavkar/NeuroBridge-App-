import SwiftUI

class TextTransformationEngine: ObservableObject {
    @Published var transformation: TextTransformation
    
    init(transformation: TextTransformation = TextTransformation()) {
        self.transformation = transformation
    }
    
    static let syllableDictionary: [String: [String]] = [

        "butter": ["but", "ter"],
        "happy": ["hap", "py"],
        "garden": ["gar", "den"],
        "window": ["win", "dow"],
        "monkey": ["mon", "key"],
        "table": ["ta", "ble"],
        "paper": ["pa", "per"],

        "butterfly": ["but", "ter", "fly"],
        "elephant": ["el", "e", "phant"],
        "umbrella": ["um", "brel", "la"],
        "computer": ["com", "pu", "ter"],
        "beautiful": ["beau", "ti", "ful"],
        "adventure": ["ad", "ven", "ture"],
        "hamburger": ["ham", "bur", "ger"],
        "telephone": ["tel", "e", "phone"],
        "calendar": ["cal", "en", "dar"],

        "caterpillar": ["cat", "er", "pil", "lar"],
        "watermelon": ["wa", "ter", "mel", "on"],

        "encyclopedia": ["en", "cy", "clo", "pe", "dia"],
        "hippopotamus": ["hip", "po", "pot", "a", "mus"]
    ]
    
    func breakIntoSyllables(_ word: String) -> [String] {
        let lowercasedWord = word.lowercased()
        
    
        if let syllables = TextTransformationEngine.syllableDictionary[lowercasedWord] {
            return syllables
        }

        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        var syllables: [String] = []
        var currentSyllable = ""
        var vowelCount = 0
        
        for (index, char) in lowercasedWord.enumerated() {
            currentSyllable.append(char)
            
            if vowels.contains(char) {
                vowelCount += 1
                
                
                if vowelCount >= 1 && currentSyllable.count >= 2 && index < lowercasedWord.count - 2 {
                    let nextIndex = lowercasedWord.index(lowercasedWord.startIndex, offsetBy: index + 1)
                    let nextChar = lowercasedWord[nextIndex]
                    
                    
                    if !vowels.contains(nextChar) && index + 2 < lowercasedWord.count {
                        let afterNextIndex = lowercasedWord.index(lowercasedWord.startIndex, offsetBy: index + 2)
                        if vowels.contains(lowercasedWord[afterNextIndex]) {
                            syllables.append(currentSyllable)
                            currentSyllable = ""
                            vowelCount = 0
                        }
                    }
                }
            }
        }
   
        if !currentSyllable.isEmpty {
            if syllables.isEmpty {
                syllables.append(currentSyllable)
            } else {
                syllables.append(currentSyllable)
            }
        }
        
        return syllables.isEmpty ? [lowercasedWord] : syllables
    }
    

    func createSyllableHighlightedText(_ text: String) -> AttributedString {
        var result = AttributedString()
        let words = text.split(separator: " ")
        
        let colors: [Color] = [
            .blue.opacity(0.3),
            .purple.opacity(0.3),
            .green.opacity(0.3),
            .orange.opacity(0.3)
        ]
        
        for (wordIndex, word) in words.enumerated() {
            let syllables = breakIntoSyllables(String(word))
            
            for (syllableIndex, syllable) in syllables.enumerated() {
                var syllableStr = AttributedString(syllable)
                let colorIndex = (wordIndex + syllableIndex) % colors.count
                syllableStr.backgroundColor = colors[colorIndex]
                result += syllableStr
            }
            
            if wordIndex < words.count - 1 {
                result += AttributedString(" ")
            }
        }
        
        return result
    }
    

    func transform(_ text: String) -> TransformedText {
        return TransformedText(
            originalText: text,
            transformation: transformation,
            syllableText: transformation.showSyllables ? createSyllableHighlightedText(text) : nil
        )
    }
}


struct TransformedText {
    let originalText: String
    let transformation: TextTransformation
    let syllableText: AttributedString?
    
    var wordCount: Int {
        originalText.split(separator: " ").count
    }
}


extension TextTransformationEngine {
    static let commonWords: [String] = [
        "the", "and", "was", "for", "are", "but", "not", "you", "all",
        "can", "her", "was", "one", "our", "out", "day", "had", "hot",
        "has", "him", "his", "how", "its", "may", "new", "now", "old",
        "see", "two", "way", "who", "oil", "sit", "set", "run", "eat",
        "far", "sea", "draw", "left", "late", "run", "don't", "while",
        "press", "close", "night", "real", "life", "few", "stop"
    ]
    
    static let confusableLetterPairs: [(Character, Character)] = [
        ("b", "d"),
        ("p", "q"),
        ("m", "w"),
        ("n", "u"),
        ("g", "q"),
        ("a", "e")
    ]
    
    static func wordsWithSyllableCount(_ count: Int) -> [String] {
        let words: [Int: [String]] = [
            1: ["cat", "dog", "run", "big", "red", "sun", "hat", "map"],
            2: ["happy", "butter", "garden", "window", "monkey", "table", "paper"],
            3: ["butterfly", "elephant", "umbrella", "computer", "beautiful", "adventure"],
            4: ["caterpillar", "encyclopedia", "hippopotamus", "watermelon"]
        ]
        return words[count] ?? words[2]!
    }
}
