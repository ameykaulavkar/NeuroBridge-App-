

NeuroBridge

> **Bridging the digital reading gap for neurodivergent minds — a gamified cognitive accessibility platform combining personalized text transformation, dyslexia-friendly typography, on-device AI assistance, and science-backed reading exercises.**

---

## Table of Contents

1. [About NeuroBridge](#about-neurobridge)
2. [Inspiration](#inspiration)
3. [Purpose & Health Domain Impact](#purpose--health-domain-impact)
4. [Key Features](#key-features)
5. [App Architecture & Flow](#app-architecture--flow)
6. [Technology Stack](#technology-stack)
7. [Frameworks & Dependencies](#frameworks--dependencies)
8. [Project Structure](#project-structure)
9. [Core Data Models](#core-data-models)
10. [Screens & Navigation](#screens--navigation)
11. [Games & Exercises (End-to-End)](#games--exercises-end-to-end)
12. [Lexi — On-Device AI Assistant](#lexi--on-device-ai-assistant)
13. [Theming System](#theming-system)
14. [Accessibility & Typography Engine](#accessibility--typography-engine)
15. [Progress & Achievement System](#progress--achievement-system)
16. [Notifications & Reminders](#notifications--reminders)
17. [Installation & Requirements](#installation--requirements)
18. [What We Learned](#what-we-learned)
19. [Challenges We Faced](#challenges-we-faced)
20. [Future Roadmap](#future-roadmap)

---

## About NeuroBridge

**NeuroBridge** is a native iOS application designed as a holistic cognitive health companion for individuals with dyslexia, ADHD, visual processing differences, and other neurodivergent reading challenges. It transforms the everyday reading experience into one that is comfortable, personalized, and empowering — combining a powerful text transformation engine, interactive skill-building games, an on-device AI reading assistant, and a robust habit tracker — all wrapped in a premium, highly accessible interface.

NeuroBridge was built for the **Apple Swift Student Challenge** and submitted to the **Health & Wellness Hackathon Track**.

---

## Inspiration

For approximately **1 in 10 people**, reading is not a natural or effortless activity. Dyslexia, the most common reading-related neurodivergent condition, affects processing of written language — not intelligence. Yet almost all digital reading experiences (e-books, articles, PDFs, educational apps) are built with a one-size-fits-all typography that is hostile to the dyslexic brain: narrow letter-spacing, long unbroken paragraphs, standard serif or sans-serif fonts with visually similar letterforms, and no syllable indicators.

I built NeuroBridge because we believe that with the right tools, every neurodivergent individual can read with confidence. The bridge metaphor is intentional — NeuroBridge meets users exactly where they are and helps them reach where they want to go.

---

## Purpose & Health Domain Impact

NeuroBridge addresses **cognitive and neurological health** by:

- **Reducing reading anxiety** through a pressure-free, personalized reading environment
- **Building cognitive reading skills** through structured, gamified daily practice
- **Encouraging consistent habits** via streak tracking, reminders, and progress milestones
- **Increasing reading comprehension** through syllable segmentation, focus mode, and font customization
- **Providing on-demand emotional support and coaching** via an on-device AI assistant (Lexi)
- **Supporting mental well-being** by reframing dyslexia as a cognitive difference rather than a deficit

NeuroBridge targets:
- **Primary users:** Individuals aged 8–40 with dyslexia, ADHD, or visual processing differences
- **Secondary users:** Parents, educators, and reading coaches who want to support neurodivergent learners

---

## Key Features

### 📖 Reader (Text Transformation Engine)
- **Camera-based text capture:** Point the camera at a physical book, handout, or sign to instantly digitize and reformat text into the user's custom reading layout
- **Library image import:** Select any image from the photo library and extract readable text
- **Real-time text transformation:** Apply OpenDyslexic font, adjustable letter spacing (0–10pt), word spacing, line spacing, font scale (1.0×–2.0×), and background color overlays
- **Syllable splitting:** Dynamically segments every word into syllables with soft separators, helping users decode unfamiliar words
- **Focus Mode:** Dims surrounding text so users can concentrate on the current paragraph only
- **5 Background overlay tints:** None, Cream, Light Blue, Light Green, Lavender, Peach — all scientifically associated with reduced visual stress in dyslexic readers
- **Reading preferences sheet:** A beautifully designed slide-up panel that lets users adjust all settings in real time without leaving the reading view

### 🎮 Cognitive Exercise Hub
8 fully interactive games designed to build specific reading sub-skills:

| Game | Skill Target | Difficulty |
|---|---|---|
| Syllable Splitter | Word decoding & chunking | Easy |
| Word Hunter | Visual scanning & focus | Medium |
| Speed Reading | Reading fluency & comprehension | Medium |
| Letter Detective | Letter recognition & focus | Medium |
| Sentence Builder | Syntax & grammar comprehension | Hard |
| Phonics Match | Phonetic sound-letter mapping | Easy |
| Rhyme Time | Phonological awareness | Easy |
| Right Spell | Spelling & orthographic memory | Hard |

### 🤖 Lexi — On-Device AI Reading Coach
- Powered by **Apple's on-device Foundation Models (FoundationModels framework)**
- Streams responses in real time using a live typing animation
- 4 quick-action prompts: *Explain a Word*, *Reading Tip*, *Practice*, *Motivate Me*
- Strict persona: Lexi stays warm, concise (max 4 sentences), and affirming — never condescending
- Full conversational session with reset/clear chat capability
- Gracefully degrades with clear UI feedback when Apple Intelligence is unavailable

### 📊 Progress & Achievement System
- **Daily session tracking:** Logs reading sessions, words read, and exercise completions
- **Accuracy metrics:** Tracks per-exercise and cumulative accuracy percentages
- **Active days calendar:** Visual streak tracking across weeks
- **12 unlockable achievements:** "Bookworm" (100 words read), "Word Hunter" (game completion), "Reading Champion" (all exercises complete), and more
- **Achievement banners:** Spring-animated drop-in banners when milestones are reached

### 🔔 Reminders & Habit Building
- Configurable daily reading reminders via iOS User Notifications
- Select specific days of the week (Sunday–Saturday)
- Set custom reminder times with a time picker
- Reminders fully persist across app launches

### 🎨 Personalized Theming
- 5 complete visual themes: **Classic** (indigo), **Ocean** (teal), **Luxe** (gold), **Ember** (red), **Meadow** (green)
- Each theme includes a fully coordinated color system: background, surface, primary, secondary, accent, and glow
- Theme selection persists and applies a matching radial glow background effect throughout the app

### 🏃 Onboarding Flow
- Multi-step animated onboarding that collects the user's name and reading level
- Introduces key features (Reader, Games, Lexi, Progress)
- Lets users choose a preferred visual theme before entering the main app
- Smooth animated transitions between onboarding steps

---

## App Architecture & Flow

```
App Launch
    │
    ├─► Onboarding (first launch only)
    │       ├── Welcome → Name Entry → Reading Level → Theme Select → Feature Tour
    │       └── Saves: hasCompletedOnboarding, userName to UserDefaults
    │
    └─► Main Tab View (5 tabs)
            ├──  Home — Dashboard with quick stats, daily tip, quick navigation
            ├──  Reader — Camera/library text input → TransformedTextView
            ├── Exercises — ExerciseHubView + 8 Games
            ├──  Lexi — On-device AI chat interface
            └── Progress — Charts, achievements, streaks
```

**Data Flow:**
- `AppState` (ObservableObject) → manages onboarding state and current text transformation
- `ProgressManager` (ObservableObject) → manages all progress, sessions, and achievements; persists via JSON in UserDefaults
- `ThemeManager` (ObservableObject, Singleton) → manages active theme; persists via UserDefaults
- `FontManager` (ObservableObject, Singleton) → manages dyslexic font variant and usage scope; persists via UserDefaults
- `NotificationManager` (ObservableObject, Singleton) → manages notification scheduling and persistence
- `LexiService` (@Observable) → manages Foundation Models session, streaming, and message history

---

## Technology Stack

| Layer | Technology |
|---|---|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **AI / LLM** | Apple FoundationModels (on-device, iOS 26+) |
| **Camera & Vision** | AVFoundation, Vision (VisionKit text recognition) |
| **Notifications** | UserNotifications |
| **Audio** | AVFoundation (sound effects) |
| **Haptics** | UIFeedbackGenerator (impact, selection, notification types) |
| **Persistence** | UserDefaults with JSON encoding/decoding |
| **Font** | OpenDyslexic OTF (bundled resource) |
| **Platform** | iOS 26.0+ / iPadOS 26.0+ |
| **Build Environment** | Swift Playgrounds 4 / Xcode |
| **Bundle ID** | com.ameyk.neurobridge |

---

## Frameworks & Dependencies

NeuroBridge uses **zero third-party dependencies** — it is built entirely with Apple-native frameworks:

| Framework | Purpose |
|---|---|
| `SwiftUI` | All UI, layout, animations, and navigation |
| `FoundationModels` | Lexi's on-device language model session and streaming |
| `AVFoundation` | Sound effect playback; camera access |
| `UserNotifications` | Scheduling and managing reading reminders |
| `UIKit` | UIFeedbackGenerator for haptics; UINavigationBar styling; UIDevice checks |
| `Vision / VisionKit` | OCR text extraction from camera and photo library images |
| `Combine` | Reactive state updates (via `@Published` / `@Observable`) |

**Bundled Assets:**
- `OpenDyslexic-Regular.otf`
- `OpenDyslexic-Bold.otf`
- `OpenDyslexic-Italic.otf`
- `OpenDyslexic-BoldItalic.otf`
- `correct.mp3`, `incorrect.mp3` (game sound effects)

---

## Project Structure

```
NeuroBridge.swiftpm/
├── Package.swift               # Swift Package manifest (iOS 26.0 target)
├── Resources/
│   ├── OpenDyslexic-*.otf     # Bundled dyslexia-friendly fonts
│   ├── correct.mp3            # Sound effect (correct answer)
│   └── incorrect.mp3          # Sound effect (incorrect answer)
└── Code/
    ├── App/
    │   ├── MyApp.swift         # @main entry point; AppState ObservableObject; environment injection
    │   └── ContentView.swift   # Root view; tab navigation; achievement banner overlay
    │
    ├── Models/
    │   ├── Models.swift        # TextTransformation, ReadingProfile, Achievement, ExerciseResult, ExerciseType
    │   └── ReadingStory.swift  # Built-in reading content library (stories for exercises)
    │
    ├── Services/
    │   ├── LexiService.swift       # @Observable Foundation Models session manager; streaming; quick actions
    │   ├── ProgressManager.swift   # Session logging; achievement logic; stats; JSON persistence
    │   ├── ThemeManager.swift      # AppTheme enum + singleton manager; UserDefaults persistence
    │   ├── NotificationManager.swift # Notification scheduling, days/times config, UserDefaults persistence
    │   ├── Haptics.swift           # HapticManager singleton; buttonPress, selection, success, error patterns
    │   └── SoundManager.swift      # SoundManager singleton; playCorrect(), playIncorrect() via AVFoundation
    │
    ├── Components/
    │   ├── Colors.swift        # Semantic color tokens (neuroBackground, neuroPrimary, etc.) via ThemeManager
    │   ├── Fonts.swift         # FontManager; DyslexicFontVariant; DyslexicFontUsage; Font.appFont(); adaptive sizing
    │   └── Components.swift    # Reusable components: ColorOverlayPicker, ColorButton, ProgressRing, FlowLayout, etc.
    │
    ├── Utilities/
    │   └── (utilities & extensions)
    │
    └── Views/
        ├── OnboardingFlow.swift        # Full multi-step onboarding (Welcome → Name → Level → Theme → Features)
        ├── ReaderView.swift            # Camera OCR, image picker, TransformedTextView, ReadingSettingsView
        ├── ExerciseHubView.swift       # Exercise hub with stats cards; StatCard, ExerciseCard components
        ├── ExtensionGames.swift        # SyllableSplitter, SpeedReading, SentenceBuilder, RightSpell, RhymeTime
        ├── MoreGames.swift             # WordHunter, PhonicsMatch, LetterDetective
        ├── LexiChatView.swift          # Lexi chat UI; streaming bubble; quick-action pills
        ├── ProgressDashboardView.swift # Progress stats, achievement grid, recent activity feed
        └── RemindersSetupView.swift    # Day/time reminder configuration
```

---

## Core Data Models

### `TextTransformation` (Codable, Equatable)
Stores all active reading preferences applied to transformed text:
```swift
struct TextTransformation {
    var useDyslexicFont: Bool       // Apply OpenDyslexic font
    var fontScale: CGFloat          // 1.0–2.0× size multiplier
    var letterSpacing: CGFloat      // 0–10pt tracking
    var wordSpacing: CGFloat        // Word-level spacing
    var lineSpacing: CGFloat        // 4–24pt line height
    var overlayColor: OverlayColor  // Background tint (.cream, .lightBlue, etc.)
    var showSyllables: Bool         // Syllable segmentation markers
    var focusModeEnabled: Bool      // Dim surrounding paragraphs
}
```

### `ExerciseResult` (Codable, Identifiable)
Records every completed exercise session:
```swift
struct ExerciseResult {
    let exerciseType: ExerciseType  // Which game was played
    let score: Int                  // Correct answers
    let maxScore: Int               // Total rounds
    let completedAt: Date           // Timestamp
    let duration: TimeInterval      // Session length
    var accuracy: Double            // Computed percentage
}
```

### `Achievement` (Codable, Identifiable)
12 statically defined achievements with unlock state and timestamp.

---

## Screens & Navigation

###  Home Screen
Displays a personalized greeting, three quick-stat cards (Completed, Accuracy, Active Days), a daily motivational tip, and quick-navigation cards to key app sections.

###  Reader Screen
**Input Options:**
1. **Take Photo** — activates the system camera; Vision OCR extracts and formats text
2. **Choose from Library** — system image picker; same OCR pipeline
3. **Type/Paste text** — manual text entry field

Once text is loaded, the user enters **TransformedTextView**:
- Full-screen scrollable reading area with selected typography settings applied live
- A floating "Reading Preferences" pill at the bottom opens a slide-up settings sheet
- The settings sheet provides: color overlay picker, font toggles (Dyslexic, Syllables, Focus), and Size/Spacing sliders
- Reads words aloud optional via system accessibility

###  Exercises Screen
A scrollable exercise hub showing three quick stats (Completed, Accuracy, Active Days) and a list of 8 exercise cards with difficulty badges. Each card navigates to the corresponding game view.

###  Lexi Screen
A chat-interface powered by Apple Intelligence. Features a scrollable message list with animated streaming bubbles, a text input field at the bottom, and 4 quick-action pill buttons above the keyboard.

### Progress Screen
A dashboard showing: daily reading stats (words read, exercises done, active days), a visual achievement grid (12 badges), and a recent activity list of the last 5 exercise results with accuracy and time.

### Settings (Reading Preferences)
Accessible from the Progress tab's navigation. Includes: App Theme selector, Font Style picker (with live preview), Dyslexic Font Usage (Nowhere / Exercises Only / Throughout App), Typography sliders, Visual Aids toggles, Account editing, Reminder management, and destructive reset options (each with a confirmation alert).

---

## Games & Exercises (End-to-End)

###  Syllable Splitter
**Goal:** Teach word chunking for decoding.  
**Flow:** A word is displayed → user taps the correct number of syllables (1–5 shown as choices) → correct answer advances to next word → 10 rounds total → game complete screen shows score.  
**Difficulty:** Randomly selected from an internal curated word bank organized by syllable count.

###  Word Hunter
**Goal:** Train fast visual scanning and word discrimination.  
**Flow:** A target word is shown at the top → user must find and tap it among a 4×6 grid of similar/decoy words → countdown timer (10–15s per word) → 8 rounds total.  
**Mechanics:** Wrong taps play a haptic + incorrect sound; correct tap highlights green with "Correct!" overlay; timeout shows "Missed!" with the target revealed.

###  Speed Reading
**Goal:** Build reading fluency under timed conditions.  
**Flow:** Short passages appear one at a time → user reads and taps "Done" → comprehension question appears → user selects answer → 5 passages per session.

###  Letter Detective
**Goal:** Develop letter recognition in a low-stress environment.  
**Flow:** A target letter is shown → user finds and taps it among a scrambled 4×6 letter grid → wrong taps play a soft haptic + incorrect sound (no red highlight, no disabling) → correct tap turns green with "Correct!" overlay → 8 rounds.

### Sentence Builder
**Goal:** Improve sentence structure and grammar comprehension.  
**Flow:** A shuffled set of word chips is shown → user drags/taps words into correct order in dotted slot boxes above → submit to check → correct sentences advance to next; 5 sentences per session.  
**UI:** Word chips displayed in a centered FlowLayout below the slots; slots animate on fill.

###  Phonics Match
**Goal:** Map phonetic sounds to written letters.  
**Flow:** A phonetic sound is played → user selects the matching letter cluster from 4 choices → 10 rounds.

###  Rhyme Time
**Goal:** Build phonological awareness through rhyme detection.  
**Flow:** A word is shown → user selects its rhyming match from 4 options → 10 rounds.

### Right Spell
**Goal:** Develop orthographic memory and spelling accuracy.  
**Flow:** A word is spoken (synthesized audio) and its definition shown → user types the correct spelling → immediate feedback with visual highlight → 8 words per session.

All games share a **GameCompleteView** end screen showing: score, accuracy percentage, a themed performance message, and navigation back to the hub. Results are automatically saved to `ProgressManager` and checked for achievement unlocks.

---

## Lexi — On-Device AI Assistant

Lexi is NeuroBridge's built-in reading coach and emotional support companion, powered entirely by **Apple's on-device Foundation Models** — meaning all processing happens locally on the device with no data ever sent to external servers.

**Technical Implementation:**
```swift
// Uses Apple's FoundationModels framework (iOS 26+)
let session = LanguageModelSession(instructions: instructions)
let stream = session.streamResponse(to: userMessage, options: GenerationOptions(temperature: 0.7))

for try await partial in stream {
    currentStreamText = partial.content  // Live streaming to UI
}
```

**Lexi's Persona (enforced via system instructions):**
- Warm, encouraging, and concise (max 4 sentences per response)
- Syllable-breaks any word before explaining it
- Uses at most one emoji per response
- Treats the user as intelligent and capable
- Reframes dyslexia as a cognitive difference, never a limitation

**Availability Handling:** Lexi gracefully handles all `SystemLanguageModel` states: `available`, `deviceNotEligible`, `appleIntelligenceNotEnabled`, and `modelNotReady` — with clear, friendly UI messaging for each.

---

## Theming System

NeuroBridge features a fully coordinated multi-theme design system with **5 themes**:

| Theme | Accent | Mood |
|---|---|---|
| Classic | Indigo / Purple | Original & Vibrant |
| Ocean | Cyan / Steel Blue | Cool & Serene |
| Luxe | Gold / Champagne | Refined & Elegant |
| Ember | Crimson / Coral | Bold & Dynamic |
| Meadow | Forest Green | Calm & Natural |

Each theme defines 7 coordinated colors: `backgroundColor`, `surfaceColor`, `surfaceLightColor`, `primaryColor`, `secondaryColor`, `accentColor`, `textLightColor` — plus computed gradients and a radial `accentGlow` background effect. The active theme is applied globally via a semantic token system (`Color.neuroPrimary`, `Color.neuroBackground`, etc.) that resolves at runtime through `ThemeManager.shared`.

---

## Accessibility & Typography Engine

### OpenDyslexic Font System
NeuroBridge bundles all 4 weights of the **OpenDyslexic** font family (Regular, Bold, Italic, BoldItalic). The font is registered at app launch using `CTFontManagerRegisterFontsForURL`.

### Font Usage Scope (3 Levels)
Users can choose where the dyslexic font applies:
- **Nowhere** — standard system font everywhere; dyslexic font only in the Reader
- **Exercises & Games Only** — dyslexic font during all game and reading sessions
- **Throughout App** — dyslexic font applied to every text element across all screens

### Adaptive Sizing
All text sizes use `.adaptive` scaling that automatically adjusts between iPhone and iPad based on screen size, ensuring a proportional and comfortable reading experience on both platforms.

### Haptic & Audio Feedback
- **HapticManager** provides: `buttonPress()` (medium impact), `selection()` (selection feedback), `success()` (success notification), `error()` (error notification), `tap()` (light impact)
- **SoundManager** provides: `playCorrect()`, `playIncorrect()` via AVFoundation — providing audio reinforcement for learning outcomes without relying solely on visual cues

---

## Progress & Achievement System

### Session Tracking
Every completed reading session or exercise game is recorded as an `ExerciseResult` and persisted via JSON encoding to `UserDefaults`. The `ProgressManager` exposes:
- `wordsRead: Int` — cumulative words read across all sessions
- `exercisesCompleted: Int` — total games finished
- `totalAccuracy: Double` — weighted average accuracy
- `dailyReadingSessions: [Date]` — timestamps of each unique day of activity

### Achievements (12 total)

| Achievement | Trigger |
|---|---|
| First Steps | Complete onboarding |
| Bookworm | Read 100 words |
| Sharp Eye | 100% accuracy in an exercise |
| Syllable Master | Complete Syllable Splitter |
| Word Hunter | Complete Word Hunter |
| Speed Demon | Complete Speed Reading |
| Detective Eye | Complete Letter Detective |
| Sentence Master | Complete Sentence Builder |
| Phonetic Genius | Complete Phonics Match |
| Rhyme Lord | Complete Rhyme Time |
| Perfect Speller | Complete Right Spell |
| Reading Champion | Complete all exercises |

Achievement unlocks are checked automatically after every session and trigger a spring-animated drop-in banner at the top of the screen.

---

## Notifications & Reminders

Users configure daily reading reminders through the **Reminders Setup** screen:
1. **Select active days** — toggle individual days of the week (Monday–Sunday)
2. **Set reminder time** — time picker with scroll-wheel interface
3. **Save** — schedules `UNCalendarNotificationTrigger`-based repeating notifications for each active day × configured time combination

Reminders rotate through 6 motivational messages:  
*"Hey! Time for your daily reading exercises!"*, *"Don't lose your streak! Let's play a game."*, *"Your brain is asking for some words!"*, and more.

All notification configuration persists across app launches via JSON-encoded `UserDefaults` storage.

---

## Installation & Requirements

### Requirements
| Item | Requirement |
|---|---|
| Platform | iPhone or iPad |
| iOS Version | iOS 26.0+ / iPadOS 26.0+ |
| Xcode Version | Xcode 26+ (or Swift Playgrounds 4.6+) |
| Apple Intelligence | Required for Lexi AI (optional for all other features) |
| Camera Permission | Required for camera-based text scanning |

### Running the App

**Option 1: Swift Playgrounds**
1. Open `NeuroBridge.swiftpm` in **Swift Playgrounds 4** on iPad or Mac
2. Tap **Run** — the app compiles and runs directly on the device

**Option 2: Xcode**
1. Open `NeuroBridge.swiftpm` as a Swift Package in **Xcode 26+**
2. Select your target device (physical iPhone/iPad preferred)
3. Sign with your Apple Developer account (free account works)
4. Build & Run (`Cmd + R`)

> **Note:** Lexi's AI features require Apple Intelligence to be enabled in **Settings → Apple Intelligence & Siri** on a compatible device (iPhone 15 Pro or later, or iPad with M-series chip). All other app features work without Apple Intelligence.

### Camera / Photo Permissions
On first use of the Reader's camera or photo library, the app will request:
- **Camera** — `NSCameraUsageDescription`: "NeuroBridge uses your camera to scan text from books and documents."
- **Photo Library** — system-level permission for image picker

---

## What We Learned

Building NeuroBridge deepened our understanding that cognitive accessibility is profoundly personal. What helps one neurodivergent reader (e.g., cream overlays, wide letter-spacing) may actually hinder another. The key insight is **giving users complete, modular control** without overwhelming them with options — presenting those options in a clean, approachable interface.

We also learned that premium, beautiful UI design and deep accessibility support are not mutually exclusive — in fact, a polished design communicates respect for the user and significantly reduces cognitive load at the UI level itself.

Working with Apple's Foundation Models framework taught us how powerful on-device AI can be for sensitive health and accessibility applications where privacy is paramount — all of Lexi's intelligence stays on the device.

---

## Challenges We Faced

1. **Dynamic Typography in Fixed Layouts:** OpenDyslexic is significantly wider than system fonts. Rendering it inside fixed-width game grids (like Letter Detective's 4×6 letter grid) required custom adaptive font sizing and careful frame constraints to prevent clipping.

2. **Centering FlowLayout:** SwiftUI's native `LazyVGrid` always left-aligns partial rows. We implemented a custom `FlowLayout` conforming to the `Layout` protocol using a two-pass row-grouping algorithm — first calculating row membership and widths, then computing per-row x-offsets to achieve true horizontal centering.

3. **Sheet Background Consistency:** iOS sheets apply a system translucent "liquid glass" material by default. Overriding this to apply a solid custom dark theme color (without losing rounded corners or drag indicators) required wrapping sheet contents in a `ZStack` with `Color.ignoresSafeArea()` as the base layer.

4. **Streaming LLM Responses to SwiftUI:** Integrating Foundation Models' async stream into a live-updating SwiftUI view required careful use of `@Observable`, `MainActor`, and progressive `currentStreamText` state to display characters as they arrive from the model.

5. **Haptic + Audio Accessibility Balance:** Designing games (especially Letter Detective) that provide meaningful feedback without using punishing visual cues (red highlights, disabled buttons) required careful UX thinking — ultimately settling on subtle haptics and audio as primary feedback channels.

---

## Future Roadmap

- [ ] **AI Word Simplifier:** Auto-simplify complex vocabulary in the Reader on demand via Lexi
- [ ] **Multi-language Support:** Extend syllable detection and exercises to Spanish, French, Hindi
- [ ] **Classroom Mode:** A teacher dashboard to monitor student progress and assign specific exercises
- [ ] **Text-to-Speech Integration:** Native read-aloud for the Reader view using AVSpeechSynthesizer
- [ ] **iCloud Sync:** Sync progress and preferences across iPhone and iPad
- [ ] **Structured Literacy Curriculum:** Build a sequential exercise path following Orton-Gillingham methodology
- [ ] **watchOS Companion:** Daily word-of-the-day and micro-practice notifications from Apple Watch

---

## Built With

`Swift` · `SwiftUI` · `FoundationModels` · `AVFoundation` · `UserNotifications` · `Vision` · `UIKit` · `OpenDyslexic Font` · `iOS 26+` · `iPadOS 26+`

---

*NeuroBridge — Every mind deserves a bridge to the world of reading.*

