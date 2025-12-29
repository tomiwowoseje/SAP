//
//  HabitTrackingGrid.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct HabitTrackingGrid: View {
    @Bindable var appState: AppState
    let viewType: TrackingViewType
    
    enum TrackingViewType {
        case week
        case month
        case year
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // View title
            Text(viewTypeTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            // Grid view based on type
            switch viewType {
            case .week:
                weekGridView
            case .month:
                monthGridView
            case .year:
                yearGridView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var viewTypeTitle: String {
        switch viewType {
        case .week: return "Week View"
        case .month: return "Month View"
        case .year: return "Year View"
        }
    }
    
    // Week view - 7 days grid
    private var weekGridView: some View {
        let dates = getWeekDates()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(dates, id: \.self) { date in
                DayCellView(
                    date: date,
                    completions: getCompletionsForDate(date),
                    isToday: Calendar.current.isDate(date, inSameDayAs: Date())
                )
            }
        }
    }
    
    // Month view - calendar grid (inspired by Statistics screen)
    private var monthGridView: some View {
        let dates = getMonthDates()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return VStack(spacing: 12) {
            // Month/Year header with navigation
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 8)
            
            // Day headers
            HStack(spacing: 2) {
                ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid with connected dates
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(dates.enumerated()), id: \.element) { index, date in
                    CalendarDayCellView(
                        date: date,
                        completions: getCompletionsForDate(date),
                        isToday: Calendar.current.isDate(date, inSameDayAs: Date()),
                        isInCurrentMonth: Calendar.current.component(.month, from: date) == currentMonth &&
                                        Calendar.current.component(.year, from: date) == currentYear,
                        previousDate: index > 0 ? dates[index - 1] : nil,
                        nextDate: index < dates.count - 1 ? dates[index + 1] : nil,
                        previousCompletions: index > 0 ? getCompletionsForDate(dates[index - 1]) : [],
                        nextCompletions: index < dates.count - 1 ? getCompletionsForDate(dates[index + 1]) : []
                    )
                }
            }
        }
    }
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    // Year view - habit list with progress grids (inspired by Habit Reports screen)
    private var yearGridView: some View {
        let skills = appState.skills
        
        return VStack(alignment: .leading, spacing: 20) {
            // Year selector
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("2025")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Button("Today") {
                    // Navigate to current year
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            
            // Habits list with progress grids
            ForEach(skills) { skill in
                HabitYearProgressView(
                    skill: skill,
                    completions: appState.dailyCompletions.filter { $0.skillId == skill.id }
                )
            }
        }
    }
    
    // Helper functions
    private func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
    
    private func getMonthDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let monthStart = calendar.date(from: components) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysFromMonday = (firstWeekday + 5) % 7
        
        let calendarStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: monthStart) ?? monthStart
        
        // Show 6 weeks (42 days) to fill the grid
        return (0..<42).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: calendarStart)
        }
    }
    
    private func getYearMonths() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        
        return (1...12).compactMap { month in
            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = 1
            return calendar.date(from: components)
        }
    }
    
    private func getCompletionsForDate(_ date: Date) -> [DailyCompletion] {
        return appState.dailyCompletions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: date)
        }
    }
    
    private func getCompletionsForMonth(_ monthStart: Date) -> [DailyCompletion] {
        let calendar = Calendar.current
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }
        
        return appState.dailyCompletions.filter { completion in
            completion.date >= monthStart && completion.date < monthEnd
        }
    }
}

// Calendar day cell with circular background and connecting lines (inspired by Statistics screen)
struct CalendarDayCellView: View {
    let date: Date
    let completions: [DailyCompletion]
    let isToday: Bool
    let isInCurrentMonth: Bool
    let previousDate: Date?
    let nextDate: Date?
    let previousCompletions: [DailyCompletion]
    let nextCompletions: [DailyCompletion]
    
    private var completionLevel: CompletionLevel {
        let fullCompletions = completions.filter { $0.completionLevel == .full }.count
        let partialCompletions = completions.filter { $0.completionLevel == .partial }.count
        
        if fullCompletions > 0 {
            return .full
        } else if partialCompletions > 0 {
            return .partial
        } else {
            return .none
        }
    }
    
    private var hasPreviousCompletion: Bool {
        guard let prevDate = previousDate else { return false }
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: prevDate, to: date).day ?? 0
        return daysDiff == 1 && (previousCompletions.contains { $0.completionLevel != .none })
    }
    
    private var hasNextCompletion: Bool {
        guard let nextDate = nextDate else { return false }
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: date, to: nextDate).day ?? 0
        return daysDiff == 1 && (nextCompletions.contains { $0.completionLevel != .none })
    }
    
    var body: some View {
        ZStack {
            // Connecting lines
            if hasPreviousCompletion || hasNextCompletion {
                HStack(spacing: 0) {
                    if hasPreviousCompletion {
                        Rectangle()
                            .fill(connectionColor)
                            .frame(width: 8, height: 2)
                    }
                    Spacer()
                    if hasNextCompletion {
                        Rectangle()
                            .fill(connectionColor)
                            .frame(width: 8, height: 2)
                    }
                }
            }
            
            // Day number with circular background
            ZStack {
                if completionLevel != .none {
                    Circle()
                        .fill(circleBackgroundColor)
                        .frame(width: 32, height: 32)
                }
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 13, weight: completionLevel != .none ? .semibold : .regular))
                    .foregroundColor(textColor)
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
    }
    
    private var circleBackgroundColor: Color {
        switch completionLevel {
        case .full:
            // Dark purple for full completion
            return Color(red: 0.5, green: 0.3, blue: 0.8)
        case .partial:
            // Light purple for partial completion
            return Color(red: 0.7, green: 0.5, blue: 0.9)
        case .none:
            return Color.clear
        }
    }
    
    private var connectionColor: Color {
        switch completionLevel {
        case .full:
            return Color(red: 0.5, green: 0.3, blue: 0.8)
        case .partial:
            return Color(red: 0.7, green: 0.5, blue: 0.9)
        case .none:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if !isInCurrentMonth {
            return .secondary.opacity(0.4)
        }
        if completionLevel != .none {
            return .white
        }
        return isToday ? Color(red: 0.3, green: 0.6, blue: 1.0) : .primary
    }
}

// Simple day cell for week view
struct DayCellView: View {
    let date: Date
    let completions: [DailyCompletion]
    let isToday: Bool
    var isInCurrentMonth: Bool = true
    
    private var completionLevel: CompletionLevel {
        let fullCompletions = completions.filter { $0.completionLevel == .full }.count
        let partialCompletions = completions.filter { $0.completionLevel == .partial }.count
        
        if fullCompletions > 0 {
            return .full
        } else if partialCompletions > 0 {
            return .partial
        } else {
            return .none
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(textColor)
            
            // Completion indicator
            Circle()
                .fill(completionColor)
                .frame(width: 6, height: 6)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    private var backgroundColor: Color {
        if !isInCurrentMonth {
            return Color.clear
        }
        switch completionLevel {
        case .full:
            return Color(red: 0.1, green: 0.5, blue: 0.2).opacity(0.2)
        case .partial:
            return Color(red: 0.5, green: 0.7, blue: 0.5).opacity(0.2)
        case .none:
            return Color.gray.opacity(0.1)
        }
    }
    
    private var completionColor: Color {
        switch completionLevel {
        case .full:
            return Color(red: 0.1, green: 0.5, blue: 0.2)
        case .partial:
            return Color(red: 0.5, green: 0.7, blue: 0.5)
        case .none:
            return Color.gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if !isInCurrentMonth {
            return .secondary.opacity(0.5)
        }
        return isToday ? .blue : .primary
    }
}

// Habit year progress view (inspired by Habit Reports screen)
struct HabitYearProgressView: View {
    let skill: Skill
    let completions: [DailyCompletion]
    
    private var completionPercentage: Double {
        let calendar = Calendar.current
        let yearStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
        let yearEnd = calendar.date(from: DateComponents(year: 2025, month: 12, day: 31)) ?? Date()
        
        let yearCompletions = completions.filter { completion in
            completion.date >= yearStart && completion.date <= yearEnd
        }
        
        let fullCompletions = yearCompletions.filter { $0.completionLevel == .full }.count
        let partialCompletions = yearCompletions.filter { $0.completionLevel == .partial }.count
        let totalDays = 365
        return Double(fullCompletions + partialCompletions) / Double(totalDays) * 100
    }
    
    private var yearDates: [Date] {
        let calendar = Calendar.current
        let yearStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
        return (0..<365).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: yearStart)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Habit header
            HStack {
                // Checkbox icon with habit color
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(skill.category.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(skill.taskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Percentage
                Text("\(Int(completionPercentage))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Progress grid - small squares
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 53), spacing: 2) {
                ForEach(yearDates, id: \.self) { date in
                    let completion = completions.first { completion in
                        Calendar.current.isDate(completion.date, inSameDayAs: date)
                    }
                    
                    let completionLevel = completion?.completionLevel ?? .none
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(squareColor(for: completionLevel))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func squareColor(for level: CompletionLevel) -> Color {
        switch level {
        case .full:
            // Dark shade of habit color
            return skill.category.color
        case .partial:
            // Light shade of habit color
            return skill.category.color.opacity(0.5)
        case .none:
            return Color.gray.opacity(0.2)
        }
    }
}

struct MonthCellView: View {
    let monthStart: Date
    let completions: [DailyCompletion]
    
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: monthStart)
    }
    
    private var completionPercentage: Double {
        let fullCompletions = completions.filter { $0.completionLevel == .full }.count
        let partialCompletions = completions.filter { $0.completionLevel == .partial }.count
        let totalDays = Calendar.current.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        return Double(fullCompletions + partialCompletions * 2) / Double(totalDays * 2) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthName)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("\(Int(completionPercentage))%")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Progress indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(completionPercentage > 50 ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(completionPercentage / 100), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    let appState = AppState()
    return HabitTrackingGrid(appState: appState, viewType: .week)
        .padding()
}

