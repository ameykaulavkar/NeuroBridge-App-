import SwiftUI
import UIKit
import CoreHaptics


class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine failed to start: \(error)")
        }
    }
    
   
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    

    func success() {
        notification(.success)
    }
    
    func error() {
        notification(.error)
    }
    
    func warning() {
        notification(.warning)
    }
    
    func tap() {
        impact(.light)
    }
    
    func buttonPress() {
        impact(.medium)
    }
    
    func celebration() {
        
        Task {
            for _ in 0..<3 {
                impact(.light)
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            notification(.success)
        }
    }
    
    func correctAnswer() {
        impact(.medium)
        Task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            notification(.success)
        }
    }
    
    func wrongAnswer() {
        notification(.error)
    }
}


extension View {
    func hapticTap() -> some View {
        self.onTapGesture {
            HapticManager.shared.tap()
        }
    }
}
