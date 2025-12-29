//
//  MorningRoutineView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct MorningRoutineView: View {
    @Bindable var appState: AppState
    @State private var selectedDate: Date = Date()
    
    // Morning routine habits
    private let morningHabits: [MorningHabit] = [
        MorningHabit(id: UUID(), name: "Read 10 pages", icon: "book.fill", color: .purple),
        MorningHabit(id: UUID(), name: "Stretch", icon: "figure.flexibility", color: .blue),
        MorningHabit(id: UUID(), name: "Track weight", icon: "scalemass", color: .indigo),
        MorningHabit(id: UUID(), name: "Drink 500ml water", icon: "drop.fill", color: .cyan)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Morning Routine")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Habits grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(morningHabits) { habit in
                    MorningHabitCard(
                        habit: habit,
                        isCompleted: isHabitCompleted(habit.id, for: selectedDate),
                        completionLevel: getCompletionLevel(habit.id, for: selectedDate),
                        onToggle: {
                            toggleHabit(habit.id, for: selectedDate)
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func isHabitCompleted(_ habitId: UUID, for date: Date) -> Bool {
        let key = habitKey(habitId: habitId, date: date)
        return appState.morningRoutineCompletions[key] == .full
    }
    
    private func getCompletionLevel(_ habitId: UUID, for date: Date) -> CompletionLevel {
        let key = habitKey(habitId: habitId, date: date)
        return appState.morningRoutineCompletions[key] ?? .none
    }
    
    private func toggleHabit(_ habitId: UUID, for date: Date) {
        let key = habitKey(habitId: habitId, date: date)
        let currentLevel = appState.morningRoutineCompletions[key] ?? .none
        
        switch currentLevel {
        case .none:
            appState.morningRoutineCompletions[key] = .partial
        case .partial:
            appState.morningRoutineCompletions[key] = .full
        case .full:
            appState.morningRoutineCompletions[key] = CompletionLevel.none
        }
        
        appState.saveMorningRoutineCompletions()
    }
    
    private func habitKey(habitId: UUID, date: Date) -> String {
        let dateString = dateFormatter.string(from: date)
        return "\(habitId.uuidString)_\(dateString)"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

struct MorningHabit: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
}

struct MorningHabitCard: View {
    let habit: MorningHabit
    let isCompleted: Bool
    let completionLevel: CompletionLevel
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(completionLevel == .full ? 0.3 : 0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: habit.icon)
                        .font(.title3)
                        .foregroundColor(completionLevel == .full ? habit.color : habit.color.opacity(0.6))
                }
                
                // Habit name
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Completion indicator
                HStack(spacing: 4) {
                    if completionLevel == .partial {
                        Circle()
                            .fill(habit.color.opacity(0.5))
                            .frame(width: 8, height: 8)
                        Text("Partial")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else if completionLevel == .full {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(habit.color)
                            .font(.caption)
                        Text("Done")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Circle()
                            .stroke(habit.color.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 8, height: 8)
                        Text("Not started")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(completionLevel == .full ? habit.color.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(completionLevel == .full ? habit.color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let appState = AppState()
    return MorningRoutineView(appState: appState)
        .padding()
}

