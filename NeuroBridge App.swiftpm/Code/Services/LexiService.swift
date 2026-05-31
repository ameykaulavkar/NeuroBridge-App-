import SwiftUI
import FoundationModels

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Quick Action

enum LexiQuickAction: String, CaseIterable, Identifiable {
    case explainWord = "Explain a Word"
    case readingTip = "Reading Tip"
    case practice = "Practice"
    case motivateMe = "Motivate Me"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .explainWord: return "character.book.closed"
        case .readingTip: return "lightbulb.fill"
        case .practice: return "pencil.and.outline"
        case .motivateMe: return "heart.fill"
        }
    }
    
    var prompt: String {
        switch self {
        case .explainWord:
            return "Pick a commonly tricky word for someone with dyslexia and explain it in a simple, fun way. Break it into syllables and give a memorable tip to remember it."
        case .readingTip:
            return "Give me one practical reading tip that helps people with dyslexia read more comfortably. Be specific and actionable."
        case .practice:
            return "Give me a quick vocabulary exercise. Present one word, its meaning, and ask me to use it in a sentence. Keep it encouraging."
        case .motivateMe:
            return "Give me a short, heartfelt motivational message about reading with dyslexia. Remind me that dyslexia is a superpower, not a limitation."
        }
    }
}

// MARK: - Model Availability State

enum LexiAvailability {
    case available
    case deviceNotEligible
    case notEnabled
    case modelNotReady
    case unknownIssue
}

// MARK: - Lexi Service

@Observable
@MainActor
final class LexiService {
    private(set) var messages: [ChatMessage] = []
    private(set) var isGenerating = false
    private(set) var currentStreamText = ""
    private(set) var availability: LexiAvailability = .available
    
    private var session: LanguageModelSession?
    
    private let instructions = Instructions {
        """
        You are Lexi, a friendly reading assistant and coach for people with dyslexia. \
        STRICT RULES: \
        1. Keep EVERY response to 2-4 sentences maximum. Never write more than 4 sentences. \
        2. Use simple, clear language. Be warm and encouraging. \
        3. Use one emoji per response maximum (✨, 📚, 💪, or 🌟).
        """
        
        """
        When explaining a word: \
        1. Break it into syllables first. \
        2. Give ALL known meanings of the word (primary and secondary). \
        3. Give one short example sentence. \
        4. That's it — stop after the example. Do not elaborate further. \
        Treat the user as capable and intelligent. Never be condescending. \
        Dyslexia is a difference, not a limitation.
        """
    }
    
    init() {
        checkAvailability()
        if availability == .available {
            createSession()
        }
    }
    
    // MARK: - Availability
    
    func checkAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            availability = .available
        case .unavailable(.deviceNotEligible):
            availability = .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            availability = .notEnabled
        case .unavailable(.modelNotReady):
            availability = .modelNotReady
        default:
            availability = .unknownIssue
        }
    }
    
    // MARK: - Session Management
    
    private func createSession() {
        session = LanguageModelSession(instructions: instructions)
    }
    
    func resetChat() {
        messages = []
        currentStreamText = ""
        isGenerating = false
        createSession()
    }
    
    // MARK: - Send Message
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isGenerating else { return }
        

        checkAvailability()
        guard availability == .available else {
            let msg = ChatMessage(
                content: "Lexi isn’t ready yet. Please enable Apple Intelligence or try again in a moment.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(msg)
            return
        }
        
    
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        

        isGenerating = true
        currentStreamText = ""
        
        do {
            if session == nil { createSession() }
            guard let session = session else {
                throw NSError(domain: "LexiService", code: -1)
            }

            let options = GenerationOptions(temperature: 0.7)
            let stream = session.streamResponse(to: text, options: options)
            
            for try await partial in stream {
                // Snapshots contain the full-so-far text; only update when non-empty
                if !partial.content.isEmpty {
                    currentStreamText = partial.content
                }
            }
            
            let finalText = currentStreamText.trimmingCharacters(in: .whitespacesAndNewlines)
            let lexiMessage = ChatMessage(
                content: finalText,
                isUser: false,
                timestamp: Date()
            )
            messages.append(lexiMessage)
            currentStreamText = ""
            
        } catch {
            #if DEBUG
            print("Lexi stream error: \(error)")
            if let session = session {
                print("Lexi transcript: \(session.transcript)")
            }
            #endif
            
            // Try a non-stream fallback before giving up
            do {
                if session == nil { createSession() }
                guard let session = session else { throw error }
                let options = GenerationOptions(temperature: 0.7)
                let response = try await session.respond(to: text, options: options)
                let lexiMessage = ChatMessage(
                    content: response.content,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(lexiMessage)
            } catch {
                let errorMessage = ChatMessage(
                    content: "I need a moment to reset. Let's start fresh! 🔄\n\n(Error: \(getErrorMessage(from: error)))",
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(errorMessage)
                createSession() 
            }
        }
        
        isGenerating = false
    }
    
    // MARK: - Error Helper
    
    private func getErrorMessage(from error: Error) -> String {
        if let genError = error as? LanguageModelSession.GenerationError {
            switch genError {
            case .assetsUnavailable(_):
                return "On-device AI model assets are unavailable/still downloading. Please check your internet connection and ensure Apple Intelligence model download has finished in System Settings."
            case .decodingFailure(_):
                return "Failed to decode the AI response (decoding failure)."
            case .exceededContextWindowSize(_):
                return "The chat history is too long and has exceeded the context limit. Please clear/reset the chat using the reset button at the top-right."
            case .guardrailViolation(_):
                return "Safety guardrails were triggered by the prompt or the response."
            case .rateLimited(_):
                return "Lexi is currently busy or rate-limited. Please try again in a moment."
            case .refusal(_, _):
                return "The AI model refused to generate a response for this query."
            case .unsupportedLanguageOrLocale(_):
                return "Language or locale is not supported by the on-device model."
            case .unsupportedGuide(_):
                return "The guided schema is unsupported."
            case .concurrentRequests(_):
                return "Lexi is already generating a response to another message. Please wait until it finishes."
            @unknown default:
                return "Generation failed (Error: \(String(describing: genError)))."
            }
        }
        return error.localizedDescription
    }
    
    // MARK: - Quick Actions
    
    func executeQuickAction(_ action: LexiQuickAction) async {
        await sendMessage(action.prompt)
    }
}
