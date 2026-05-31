import SwiftUI

struct ProgressDashboardView: View {
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
                        StatsOverviewCard(progressManager: progressManager)
                        
                        AchievementsSection(achievements: progressManager.achievements)
                        
                        if !progressManager.exerciseResults.isEmpty {
                            RecentActivitySection(results: progressManager.exerciseResults)
                        }
                    }
                    .padding()
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Your Progress")
            .id(FontManager.shared.selectedVariant.rawValue + FontManager.shared.selectedUsage.rawValue)
        }
    }
}


struct StatsOverviewCard: View {
    @ObservedObject var progressManager: ProgressManager
    
    var body: some View {
        VStack(spacing: 20.adaptive) {
            HStack(spacing: 30.adaptive) {
                VStack(spacing: 8.adaptive) {
                    ProgressRing(
                        progress: Double(progressManager.unlockedAchievementsCount) / Double(progressManager.achievements.count),
                        size: 100.adaptive,
                        lineWidth: 10.adaptive
                    )
                    
                    Text("Achievements")
                        .font(.neuroCaption)
                        .foregroundColor(.neuroTextMuted)
                }
                
                VStack(alignment: .leading, spacing: 16.adaptive) {
                    StatRow(
                        icon: "book.fill",
                        value: "\(progressManager.wordsRead)",
                        label: "Words Read"
                    )
                    
                    StatRow(
                        icon: "checkmark.circle.fill",
                        value: "\(progressManager.exercisesCompleted)",
                        label: "Exercises Done"
                    )
                    
                    StatRow(
                        icon: "calendar.badge.clock",
                        value: "\(progressManager.dailyReadingSessions.count) days",
                        label: "Active Days"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .neuroCard()
    }
}


struct StatRow: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 12.adaptive) {
            Image(systemName: icon)
                .font(.system(size: 18.adaptive))
                .foregroundColor(.neuroPrimary)
                .frame(width: 24.adaptive)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(Font.appFont(size: 16, weight: .semibold, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(Font.appFont(size: 11, weight: .regular, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextMuted)
            }
        }
    }
}


struct AchievementsSection: View {
    let achievements: [Achievement]
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.adaptive) {
            HStack {
                Text("Achievements")
                    .font(.neuroHeadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                let unlocked = achievements.filter { $0.isUnlocked }.count
                Text("\(unlocked)/\(achievements.count)")
                    .font(.neuroSubheadline)
                    .foregroundColor(.neuroTextSecondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12.adaptive), count: 3), spacing: 16.adaptive) {
                ForEach(achievements) { achievement in
                    Button {
                        HapticManager.shared.tap()
                        selectedAchievement = achievement
                    } label: {
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .neuroCard()
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
        }
    }
}


struct RecentActivitySection: View {
    let results: [ExerciseResult]
    
    private var recentResults: [ExerciseResult] {
        Array(results.sorted { $0.completedAt > $1.completedAt }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.neuroHeadline)
                .foregroundColor(.white)
            
            ForEach(recentResults) { result in
                ActivityRow(result: result)
            }
        }
        .neuroCard()
    }
}


struct ActivityRow: View {
    let result: ExerciseResult
    

    
    var body: some View {
        HStack(spacing: 12.adaptive) {
            Image(systemName: result.exerciseType.icon)
                .font(.system(size: 20.adaptive))
                .foregroundColor(.white)
                .frame(width: 44.adaptive, height: 44.adaptive)
                .background(result.exerciseType.color)
                .clipShape(RoundedRectangle(cornerRadius: 10.adaptive))
            
            Text(result.exerciseType.rawValue)
                .font(.neuroBody)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2.adaptive) {
                Text("\(result.score)/\(result.maxScore)")
                    .font(.neuroSubheadline)
                    .foregroundColor(.white)
                
                Text(String(format: "%.0f%%", result.accuracy))
                    .font(.caption)
                    .foregroundColor(result.accuracy >= 70 ? .neuroSuccess : .neuroWarning)
            }
        }
        .padding(.vertical, 8.adaptive)
    }
}

struct AchievementDetailSheet: View {
    let achievement: Achievement
    @ObservedObject private var fontManager = FontManager.shared
    
    var body: some View {
        ZStack {
            Color.neuroSurface.ignoresSafeArea()
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.neuroTextMuted.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color.neuroPrimary.opacity(0.2) : Color.neuroSurfaceLight)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 44.adaptive))
                        .foregroundColor(achievement.isUnlocked ? .neuroPrimary : .neuroTextMuted.opacity(0.5))
                }
                .frame(width: 100.adaptive, height: 100.adaptive)
                
                Text(achievement.title)
                    .font(.neuroHeadline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.neuroBody)
                    .foregroundColor(.neuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if achievement.isUnlocked {
                    VStack(spacing: 4) {
                        Text("Achievement Unlocked!")
                            .font(.neuroBody.weight(.bold))
                            .foregroundColor(.neuroSuccess)
                        if let date = achievement.unlockedAt {
                            Text(date.formatted(date: .abbreviated, time: .shortened))
                                .font(.neuroCaption)
                                .foregroundColor(.neuroTextMuted)
                        }
                    }
                } else {
                    Text("Keep playing to unlock this.")
                        .font(.neuroBody)
                        .foregroundColor(.neuroTextMuted)
                }
                
                Spacer()
            }
            .padding()
        }
        .presentationDetents([.height(350)])
    }
}


#Preview {
    ProgressDashboardView()
        .environmentObject(ProgressManager())
        .environmentObject(ThemeManager.shared)
}
