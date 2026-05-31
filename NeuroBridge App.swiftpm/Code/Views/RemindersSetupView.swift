import SwiftUI

struct RemindersSetupView: View {
    var isSettingsContext: Bool = false
    let onContinue: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var fontManager = FontManager.shared
    @State private var activeDays: Set<Int> = []
    @State private var times: [Date] = []
    @State private var showTimePicker = false
    @State private var selectedTime = Date()
    @State private var showContent = false
    
    let days = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30.adaptive) {
                    Spacer(minLength: 20)
                    
                    VStack(spacing: 8.adaptive) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 40.adaptive))
                            .foregroundColor(.neuroPrimary)
                            
                        Text("Reading Routine")
                            .font(Font.appFont(size: 28, weight: .bold, design: .rounded, context: .general))
                            .foregroundColor(.white)
                            
                        Text("Set gentle reminders to practice")
                            .font(Font.appFont(size: 15, weight: .regular, design: .rounded, context: .general))
                            .foregroundColor(.neuroTextMuted)
                    }
                    .opacity(showContent ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Days Active")
                            .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                            .foregroundColor(.white)
                            
                        HStack(spacing: 8) {
                            ForEach(days, id: \.0) { day in
                                let isActive = activeDays.contains(day.0)
                                Button {
                                    HapticManager.shared.tap()
                                    if isActive {
                                        activeDays.remove(day.0)
                                    } else {
                                        activeDays.insert(day.0)
                                    }
                                } label: {
                                    Text(day.1)
                                        .font(Font.appFont(size: 14, weight: .bold, design: .rounded, context: .general))
                                        .foregroundColor(isActive ? themeManager.currentTheme.textLightColor : .neuroTextSecondary)
                                        .frame(width: 38.adaptive, height: 38.adaptive)
                                        .background(isActive ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.surfaceLightColor)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .background(themeManager.currentTheme.surfaceColor)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(times.enumerated()), id: \.offset) { index, time in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.neuroTextSecondary)
                                Text(time, style: .time)
                                    .font(Font.appFont(size: 20, weight: .bold, design: .rounded, context: .general))
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    HapticManager.shared.buttonPress()
                                    times.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.8))
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(Color.neuroSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        Button {
                            HapticManager.shared.buttonPress()
                            showTimePicker = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.neuroPrimary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    
                    Spacer(minLength: 40)
                    
                    if isSettingsContext {
                        HStack(spacing: 16) {
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                onContinue() // Just dismiss
                            }) {
                                Text("Cancel")
                                    .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 16)
                                    .background(themeManager.currentTheme.surfaceLightColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                            }
                            
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                NotificationManager.shared.requestAuthorization { granted in
                                    if granted {
                                        NotificationManager.shared.scheduleReminders(activeDays: activeDays, times: times)
                                    }
                                    onContinue()
                                }
                            }) {
                                Text("Done")
                                    .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                                    .foregroundColor(themeManager.currentTheme.textLightColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(themeManager.currentTheme.primaryColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                        .opacity(showContent ? 1 : 0)
                    } else {
                        Button(action: {
                            HapticManager.shared.buttonPress()
                      
                            NotificationManager.shared.requestAuthorization { granted in
                                if granted {
                                 
                                    NotificationManager.shared.scheduleReminders(activeDays: activeDays, times: times)
                                }
                 
                                onContinue()
                            }
                        }) {
                            HStack {
                                Text("See It In Action")
                                Image(systemName: "arrow.right")
                            }
                            .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                            .foregroundColor(themeManager.currentTheme.textLightColor)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 50)
                    }
                }
                .frame(width: min(geometry.size.width, UIDevice.current.userInterfaceIdiom == .pad ? 680 : geometry.size.width))
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            activeDays = NotificationManager.shared.activeDays
            times = NotificationManager.shared.times
            
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showTimePicker) {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    HStack {
                        Button {
                            showTimePicker = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.neuroTextMuted)
                        }
                        Spacer()
                        Text("Add Alarm")
                            .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            HapticManager.shared.celebration()
                            times.append(selectedTime)
                            showTimePicker = false
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .padding()
            }
            .presentationDetents([.height(350)])
        }
    }
}
