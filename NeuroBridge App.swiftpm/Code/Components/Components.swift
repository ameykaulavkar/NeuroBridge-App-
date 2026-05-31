import SwiftUI


struct DyslexiaTextView: View {
    let text: String
    let transformation: TextTransformation
    @State private var currentLineIndex: Int = 0

    private let syllableColors: [Color] = [
        .blue, .purple, .green, .orange, .pink
    ]
    
    private var lines: [String] {
        text.components(separatedBy: ". ").filter { !$0.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: transformation.lineSpacing) {
                if transformation.focusModeEnabled {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        lineView(for: line + (index < lines.count - 1 ? "." : ""))
                            .opacity(index == currentLineIndex ? 1.0 : 0.3)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    currentLineIndex = index
                                }
                                HapticManager.shared.selection()
                            }
                    }
                } else {
                    lineView(for: text)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(transformation.overlayColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private func lineView(for text: String) -> some View {
        if transformation.showSyllables {
            
            syllableHighlightedText(text)
        } else {
            
            Text(text)
                .font(transformation.useDyslexicFont 
                    ? Font.dyslexicOrSystem(size: 18 * transformation.fontScale)
                    : Font.system(size: 18 * transformation.fontScale, design: .rounded))
                .tracking(transformation.letterSpacing)
                .lineSpacing(transformation.lineSpacing)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func syllableHighlightedText(_ text: String) -> some View {
        let words = text.split(separator: " ").map(String.init)
        
        FlowLayout(spacing: 1) { 
            ForEach(Array(generateSyllableItems(words).enumerated()), id: \.offset) { index, item in
                if item.isSpace {
                    Color.clear
                        .frame(width: max(0, transformation.wordSpacing - 2), height: 1)
                } else {
                    Text(item.text)
                        .font(transformation.useDyslexicFont 
                            ? Font.dyslexicOrSystem(size: 18 * transformation.fontScale)
                            : Font.system(size: 18 * transformation.fontScale, design: .rounded))
                        .tracking(transformation.letterSpacing)
                        .foregroundColor(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 2)
                        .background(syllableColors[(item.syllableIndex) % syllableColors.count].opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }
    
   
    struct SyllableItem {
        let text: String
        let isSpace: Bool
        let syllableIndex: Int
    }
    
    private func generateSyllableItems(_ words: [String]) -> [SyllableItem] {
        var items: [SyllableItem] = []
        for (wordIndex, word) in words.enumerated() {
            let syllables = breakIntoSyllables(word)
            for (syllableIndex, syllable) in syllables.enumerated() {
                items.append(SyllableItem(text: syllable, isSpace: false, syllableIndex: syllableIndex))
            }
          
            if wordIndex < words.count - 1 {
                items.append(SyllableItem(text: " ", isSpace: true, syllableIndex: 0))
            }
        }
        return items
    }
    
   
    private func breakIntoSyllables(_ word: String) -> [String] {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"]
        let cleanWord = word.filter { $0.isLetter || $0.isNumber }
        
        guard cleanWord.count > 2 else { return [word] }
        
        var syllables: [String] = []
        var currentSyllable = ""
        var hasVowel = false
        let chars = Array(cleanWord.lowercased())
        
        for (index, char) in chars.enumerated() {
            currentSyllable.append(char)
            
            if vowels.contains(char) {
                hasVowel = true
            }
            
           
            if hasVowel && index < chars.count - 1 {
                let nextChar = chars[index + 1]
                if !vowels.contains(char) && vowels.contains(nextChar) {
                    syllables.append(currentSyllable)
                    currentSyllable = ""
                    hasVowel = false
                }
            }
        }
        
    
        if !currentSyllable.isEmpty {
            if syllables.isEmpty {
                syllables.append(currentSyllable)
            } else {
                syllables[syllables.count - 1] += currentSyllable
            }
        }
        
        
        let suffix = String(word.drop { $0.isLetter || $0.isNumber })
        if !suffix.isEmpty && !syllables.isEmpty {
            syllables[syllables.count - 1] += suffix
        }
        
        return syllables.isEmpty ? [word] : syllables
    }
}


struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var maxHeight: CGFloat = 0
        
        // First pass: group subviews into rows
        var rows: [[Int]] = [[]]
        var rowWidths: [CGFloat] = [0]
        var rowHeights: [CGFloat] = [0]
        var currentX: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                // Start new row
                rows.append([index])
                rowWidths.append(size.width)
                rowHeights.append(size.height)
                currentX = size.width + spacing
            } else {
                rows[rows.count - 1].append(index)
                if currentX > 0 {
                    rowWidths[rowWidths.count - 1] += spacing
                }
                rowWidths[rowWidths.count - 1] += size.width
                rowHeights[rowHeights.count - 1] = max(rowHeights[rowHeights.count - 1], size.height)
                currentX += size.width + spacing
            }
        }
        
        // Second pass: center each row
        positions = Array(repeating: .zero, count: subviews.count)
        var y: CGFloat = 0
        
        for (rowIndex, row) in rows.enumerated() {
            let rowWidth = rowWidths[rowIndex]
            let rowHeight = rowHeights[rowIndex]
            let xOffset = max(0, (maxWidth - rowWidth) / 2)
            var x = xOffset
            
            for subviewIndex in row {
                let size = subviews[subviewIndex].sizeThatFits(.unspecified)
                positions[subviewIndex] = CGPoint(x: x, y: y)
                x += size.width + spacing
            }
            
            y += rowHeight + spacing
            maxHeight = max(maxHeight, y - spacing)
        }
        
        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}


struct ColorOverlayPicker: View {
    @Binding var selectedColor: TextTransformation.OverlayColor
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TextTransformation.OverlayColor.allCases, id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: selectedColor == color,
                            action: {
                                HapticManager.shared.selection()
                                selectedColor = color
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
                .frame(minWidth: geometry.size.width, alignment: .center)
            }
        }
        .frame(height: 74.adaptive)
    }
}

struct ColorButton: View {
    let color: TextTransformation.OverlayColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color == .none ? Color.neuroSurface : color.color.opacity(1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .strokeBorder(isSelected ? Color.neuroPrimary : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Group {
                            if color == .none {
                                Image(systemName: "nosign")
                                    .foregroundColor(.neuroTextMuted)
                            }
                        }
                    )
                
                Text(color.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .neuroPrimary : .neuroTextSecondary)
            }
        }
    }
}


struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    @ObservedObject private var fontManager = FontManager.shared
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 8) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.neuroSurfaceLight, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.neuroPrimary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(Font.appFont(size: size * 0.25, weight: .bold, design: .rounded, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}


struct AchievementBadge: View {
    let achievement: Achievement
    @ObservedObject private var fontManager = FontManager.shared
    
    var body: some View {
        VStack(spacing: 8.adaptive) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked 
                        ? Color.neuroPrimary 
                        : Color.neuroSurface)
                    .frame(width: 60.adaptive, height: 60.adaptive)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 22.adaptive))
                    .foregroundColor(achievement.isUnlocked ? .white : .neuroTextMuted)
            }
            
            Text(achievement.title)
                .font(Font.appFont(size: 12, weight: .medium, context: .general, isAlreadyAdaptive: true))
                .foregroundColor(achievement.isUnlocked ? .white : .neuroTextMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80.adaptive)
        .opacity(achievement.isUnlocked ? 1 : 0.5)
    }
}


struct AnimatedButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonPress()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}


struct SampleTextCard: View {
    let sample: SampleText
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(sample.title)
                        .font(.neuroSubheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.neuroPrimary)
                    }
                    
                    Text(sample.difficulty.rawValue)
                        .font(Font.appFont(size: 12, weight: .medium, context: .general))
                        .foregroundColor(sample.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(sample.difficulty.color.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Text(sample.content)
                    .font(.neuroCaption)
                    .foregroundColor(.neuroTextSecondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "folder")
                        .font(Font.appFont(size: 12, weight: .regular, context: .general))
                    Text(sample.category)
                        .font(Font.appFont(size: 12, weight: .regular, context: .general))
                }
                .foregroundColor(.neuroTextMuted)
            }
            .padding(16)
            .background(isSelected ? Color.neuroPrimary.opacity(0.15) : Color.neuroSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.neuroPrimary : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRing(progress: 0.75)
        
        ColorOverlayPicker(selectedColor: .constant(.cream))
        
        AchievementBadge(achievement: Achievement.allAchievements[0])
    }
    .padding()
    .background(Color.neuroBackground)
}


struct ResponsiveViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 900 : .infinity)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension View {
    func responsiveContent() -> some View {
        modifier(ResponsiveViewModifier())
    }
}

// MARK: - Adaptive Sizes Native Helper
extension CGFloat {
    var adaptive: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? self * DeviceUtility.layoutScale : self
    }
}

extension Double {
    var adaptive: CGFloat {
        CGFloat(self).adaptive
    }
}

extension Int {
    var adaptive: CGFloat {
        CGFloat(self).adaptive
    }
}
