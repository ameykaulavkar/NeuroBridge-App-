import SwiftUI

struct ProgressData: Codable {
    var wordsRead: Int
    var exercisesCompleted: Int
    var currentStreak: Int
    var achievements: [Achievement]
    var exerciseResults: [ExerciseResult]
    var lastActiveDate: Date?
    var dailyReadingSessions: [DailyReadingSession]
}

class ProgressManager: ObservableObject {
    @Published var wordsRead: Int = 0
    @Published var exercisesCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var exerciseResults: [ExerciseResult] = []
    @Published var dailyReadingSessions: [DailyReadingSession] = []
    @Published var lastActiveDate: Date?
    @Published var recentlyUnlockedAchievement: Achievement? = nil
    
    init() {
        loadProgress()
    }
    
    // MARK: - Core Tracking

    func addWordsRead(_ count: Int) {
        wordsRead += count

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let index = dailyReadingSessions.firstIndex(where: { calendar.startOfDay(for: $0.date) == today }) {
            dailyReadingSessions[index].wordsRead += count
        } else {
            dailyReadingSessions.append(DailyReadingSession(date: Date(), wordsRead: count))
        }
        
        if currentStreak == 0 {
            currentStreak = 1
        }
        updateStreak()
        checkAchievements()
        saveProgress()
    }

    func recordExerciseResult(_ result: ExerciseResult) {
        exerciseResults.append(result)
        exercisesCompleted += 1

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if !dailyReadingSessions.contains(where: { calendar.startOfDay(for: $0.date) == today }) {
            dailyReadingSessions.append(DailyReadingSession(date: Date(), wordsRead: 0))
        }
        
        if currentStreak == 0 {
            currentStreak = 1
        }
        updateStreak()
        checkAchievements()
        saveProgress()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastActiveDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                currentStreak += 1
            } else if daysDifference > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastActiveDate = Date()
    }
    
    // MARK: - Achievements

    func checkAchievements() {
        if wordsRead >= 100 {
            unlockAchievement(id: "bookworm")
        }

        if exerciseResults.contains(where: { $0.accuracy >= 100 }) {
            unlockAchievement(id: "sharp_eye")
        }
  
        let completedTypes = Set(exerciseResults.map { $0.exerciseType })
        
        if completedTypes.contains(.syllableSplitter) {
            unlockAchievement(id: "syllable_master")
        }
        if completedTypes.contains(.wordHunter) {
            unlockAchievement(id: "word_hunter")
        }
        if completedTypes.contains(.speedReading) {
            unlockAchievement(id: "speed_demon")
        }
        if completedTypes.contains(.letterDetective) {
            unlockAchievement(id: "detective_eye")
        }
        if completedTypes.contains(.sentenceBuilder) {
            unlockAchievement(id: "sentence_master")
        }
        if completedTypes.contains(.phonicsMatch) {
            unlockAchievement(id: "phonetic_genius")
        }
        if completedTypes.contains(.rhymeTime) {
            unlockAchievement(id: "rhyme_lord")
        }
        if completedTypes.contains(.rightSpell) {
            unlockAchievement(id: "perfect_speller")
        }

        if completedTypes.count >= ExerciseResult.ExerciseType.allCases.count {
            unlockAchievement(id: "champion")
        }
    }
    
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedAt = Date()
            recentlyUnlockedAchievement = achievements[index]
            HapticManager.shared.celebration()
            saveProgress()

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if self.recentlyUnlockedAchievement?.id == id {
                    self.recentlyUnlockedAchievement = nil
                }
            }
        }
    }
    
    func unlockFirstSteps() {
        unlockAchievement(id: "first_steps")
    }
    
    // MARK: - Computed Properties

    var totalAccuracy: Double {
        guard !exerciseResults.isEmpty else { return 0 }
        let total = exerciseResults.reduce(0.0) { $0 + $1.accuracy }
        return total / Double(exerciseResults.count)
    }
    
    var unlockedAchievementsCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    // MARK: - Persistence & Resets

    private func saveProgress() {
        let data = ProgressData(
            wordsRead: wordsRead,
            exercisesCompleted: exercisesCompleted,
            currentStreak: currentStreak,
            achievements: achievements,
            exerciseResults: exerciseResults,
            lastActiveDate: lastActiveDate,
            dailyReadingSessions: dailyReadingSessions
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "progressManagerData")
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "progressManagerData"),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: data) {
            self.wordsRead = decoded.wordsRead
            self.exercisesCompleted = decoded.exercisesCompleted
            self.currentStreak = decoded.currentStreak
            self.achievements = decoded.achievements.filter { $0.id != "on_fire" }
            self.exerciseResults = decoded.exerciseResults
            self.lastActiveDate = decoded.lastActiveDate
            self.dailyReadingSessions = decoded.dailyReadingSessions
        }
    }
    
    func resetAllProgress() {
        wordsRead = 0
        exercisesCompleted = 0
        currentStreak = 0
        achievements = Achievement.allAchievements // Reset to locked
        exerciseResults = []
        dailyReadingSessions = []
        lastActiveDate = nil
        saveProgress()
    }
    
    func resetAchievements() {
        achievements = Achievement.allAchievements
        saveProgress()
    }
    
    func resetTodaysProgress() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let beforeExerciseCount = exerciseResults.count
        exerciseResults.removeAll { calendar.startOfDay(for: $0.completedAt) == today }
        let removedExercises = beforeExerciseCount - exerciseResults.count
        exercisesCompleted = max(0, exercisesCompleted - removedExercises)

        if let todaySessionIndex = dailyReadingSessions.firstIndex(where: { calendar.startOfDay(for: $0.date) == today }) {
            let todayWords = dailyReadingSessions[todaySessionIndex].wordsRead
            wordsRead = max(0, wordsRead - todayWords)
            dailyReadingSessions.remove(at: todaySessionIndex)
        }
        
        saveProgress()
    }
}
