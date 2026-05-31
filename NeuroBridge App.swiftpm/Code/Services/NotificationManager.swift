import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var activeDays: Set<Int> = [2, 3, 4, 5, 6]
    @Published var times: [Date] = [Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!]
    
    
    private let messages = [
        "Hey! Time for your daily reading exercises!",
        "Feeling like a quick read today?",
        "Don't lose your streak! Let's play a game.",
        "Your brain is asking for some words!",
        "Ready to build some sentences?",
        "Let's catch some words today!"
    ]
    
    init() {
        checkAuthorization()
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        if let data = UserDefaults.standard.data(forKey: "activeDays"),
           let savedDays = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            self.activeDays = savedDays
        }
        
        if let data = UserDefaults.standard.data(forKey: "reminderTimes"),
           let savedTimes = try? JSONDecoder().decode([Date].self, from: data) {
            self.times = savedTimes
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion(granted)
            }
        }
    }
    
    func scheduleReminders(activeDays: Set<Int>, times: [Date]) {
        self.activeDays = activeDays
        self.times = times
        
        if let data = try? JSONEncoder().encode(activeDays) {
            UserDefaults.standard.set(data, forKey: "activeDays")
        }
        if let data = try? JSONEncoder().encode(times) {
            UserDefaults.standard.set(data, forKey: "reminderTimes")
        }
        
        cancelAllReminders()
        
        guard isAuthorized else { return }
        
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        for day in activeDays {
            for time in times {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                
                var dateComponents = DateComponents()
                dateComponents.weekday = day // Sunday = 1, Monday = 2...
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let content = UNMutableNotificationContent()
                content.title = "NeuroBridge"
                content.body = messages.randomElement() ?? "Time for your reading exercises!"
                content.sound = .default
                
                let identifier = "reminder-\(day)-\(timeComponents.hour ?? 0)-\(timeComponents.minute ?? 0)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func resetReminders() {
        cancelAllReminders()
        UserDefaults.standard.removeObject(forKey: "activeDays")
        UserDefaults.standard.removeObject(forKey: "reminderTimes")
        self.activeDays = [2, 3, 4, 5, 6]
        self.times = [Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!]
    }
}
