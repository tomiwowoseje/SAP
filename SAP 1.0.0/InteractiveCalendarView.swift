//
//  InteractiveCalendarView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct InteractiveCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentWeekStart: Date
    
    // Purple/blue color scheme
    private let primaryColor = Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
    private let secondaryColor = Color(red: 0.3, green: 0.6, blue: 1.0) // Blue
    private let accentColor = Color(red: 0.7, green: 0.5, blue: 1.0) // Light purple
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7 // Convert to Monday = 0
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        _currentWeekStart = State(initialValue: calendar.startOfDay(for: weekStart))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Week header with navigation
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(primaryColor)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Week range display
                Text(weekRangeText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(primaryColor)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 8)
            
            // Day names header
            HStack(spacing: 0) {
                ForEach(dayNames, id: \.self) { dayName in
                    Text(dayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // Days grid
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: Calendar.current.isDate(date, inSameDayAs: Date()),
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        accentColor: accentColor
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var dayNames: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return weekDays.map { formatter.string(from: $0).uppercased() }
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: currentWeekStart)
        }
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        if let firstDay = weekDays.first, let lastDay = weekDays.last {
            let firstMonth = Calendar.current.component(.month, from: firstDay)
            let lastMonth = Calendar.current.component(.month, from: lastDay)
            
            if firstMonth == lastMonth {
                return "\(formatter.string(from: firstDay)) - \(Calendar.current.component(.day, from: lastDay))"
            } else {
                return "\(formatter.string(from: firstDay)) - \(formatter.string(from: lastDay))"
            }
        }
        return ""
    }
    
    private func previousWeek() {
        let calendar = Calendar.current
        if let newStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) {
            currentWeekStart = calendar.startOfDay(for: newStart)
        }
    }
    
    private func nextWeek() {
        let calendar = Calendar.current
        if let newStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) {
            currentWeekStart = calendar.startOfDay(for: newStart)
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium))
                .foregroundColor(textColor)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
        )
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return primaryColor.opacity(0.2)
        } else if isToday {
            return accentColor.opacity(0.15)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return primaryColor
        } else if isToday {
            return secondaryColor
        } else {
            return .primary
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return primaryColor
        } else if isToday {
            return secondaryColor
        } else {
            return Color.clear
        }
    }
}

#Preview {
    InteractiveCalendarView(selectedDate: .constant(Date()))
        .padding()
}

