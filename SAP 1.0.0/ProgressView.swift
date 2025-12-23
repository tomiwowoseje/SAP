//
//  ProgressView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

// B-005: Progress Tracking Screen
struct ProgressTrackingView: View {
    @Bindable var appState: AppState
    @State private var selectedViewType: ViewType = .weekly
    @State private var selectedSkillId: UUID?
    @State private var showingExportSheet = false
    @State private var exportText: String = ""
    @State private var showingImportSheet = false
    @State private var importText: String = ""
    @State private var importError: String?
    
    enum ViewType: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
        case annual = "Year"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View type selector
                Picker("View Type", selection: $selectedViewType) {
                    ForEach(ViewType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Progress content
                ScrollView {
                    VStack(spacing: 24) {
                        // Overall statistics
                        overallStatsView
                        
                        // Skills progress grid
                        skillsProgressGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            if let json = appState.exportData() {
                                exportText = json
                                showingExportSheet = true
                            }
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            importText = ""
                            importError = nil
                            showingImportSheet = true
                        } label: {
                            Label("Import Data", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            NavigationStack {
                VStack(alignment: .leading) {
                    Text("Exported Data")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Text("Copy this JSON and save it somewhere safe. You can import it later on this or another device.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $exportText)
                        .font(.system(.footnote, design: .monospaced))
                        .padding(.top, 8)
                        .border(Color.secondary.opacity(0.2))
                }
                .padding()
                .navigationTitle("Export Data")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingExportSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Import Data")
                        .font(.headline)
                    
                    Text("Paste previously exported JSON below, then tap Import.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $importText)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(minHeight: 200)
                        .border(Color.secondary.opacity(0.2))
                    
                    if let error = importError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        do {
                            try appState.importData(from: importText)
                            showingImportSheet = false
                        } catch {
                            importError = "Failed to import data. Please check that the JSON is valid."
                        }
                    } label: {
                        Text("Import")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding()
                .navigationTitle("Import Data")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingImportSheet = false
                        }
                    }
                }
            }
        }
    }
    
    // Overall statistics view
    private var overallStatsView: some View {
        let allProgress = appState.getAllProgress()
        let totalSkills = allProgress.count
        let completedSkills = allProgress.filter { $0.completionPercentage > 0 }.count
        let averageCompletion = allProgress.isEmpty ? 0.0 : allProgress.map { $0.completionPercentage }.reduce(0, +) / Double(allProgress.count)
        
        return VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Skills",
                    value: "\(totalSkills)",
                    color: .blue
                )
                
                StatCard(
                    title: "Active",
                    value: "\(completedSkills)",
                    color: .green
                )
                
                StatCard(
                    title: "Avg. Completion",
                    value: String(format: "%.0f%%", averageCompletion),
                    color: .orange
                )
            }
        }
    }
    
    // Skills progress grid
    private var skillsProgressGrid: some View {
        let allProgress = appState.getAllProgress()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Skills Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(allProgress) { progress in
                SkillProgressCard(
                    progress: progress,
                    viewType: selectedViewType,
                    appState: appState
                )
            }
        }
    }
}

// Stat card component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// Skill progress card with heatmap
struct SkillProgressCard: View {
    let progress: SkillProgress
    let viewType: ProgressTrackingView.ViewType
    let appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Skill name and percentage
            HStack {
                Text(progress.skillName)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f%%", progress.completionPercentage))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            // Streak information
            HStack(spacing: 16) {
                Label("\(progress.currentStreak) day streak", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Label("Longest: \(progress.longestStreak)", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            // Heatmap grid
            heatmapGrid
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Heatmap grid based on view type
    private var heatmapGrid: some View {
        let dates = getDatesForViewType()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: getColumnCount())
        
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(dates, id: \.self) { date in
                let completion = progress.completions.first { completion in
                    Calendar.current.isDate(completion.date, inSameDayAs: date)
                }
                
                let isCompleted = completion?.isCompleted ?? false
                let color = getColorForCompletion(isCompleted: isCompleted, date: date)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(height: 20)
                    .overlay(
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.system(size: 8))
                            .foregroundColor(isCompleted ? .white : .secondary)
                            .opacity(Calendar.current.isDate(date, inSameDayAs: Date()) ? 1 : 0.6)
                    )
            }
        }
    }
    
    // Get dates for the selected view type
    private func getDatesForViewType() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var dates: [Date] = []
        
        switch viewType {
        case .weekly:
            let startDate = calendar.date(byAdding: .day, value: -6, to: now) ?? now
            dates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
            
        case .monthly:
            let startDate = calendar.date(byAdding: .day, value: -29, to: now) ?? now
            dates = (0..<30).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
            
        case .annual:
            // Show last 12 months, one representative day per month (first day)
            let startDate = calendar.date(byAdding: .month, value: -11, to: now) ?? now
            var monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) ?? startDate
            dates = (0..<12).compactMap { _ in
                let date = monthStart
                monthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
                return date
            }
        }
        
        return dates
    }
    
    // Get column count based on view type
    private func getColumnCount() -> Int {
        switch viewType {
        case .weekly: return 7
        case .monthly: return 7 // 5 rows of 7 days
        case .annual: return 6 // 2 rows of 6 months
        }
    }
    
    // Get color for completion state (B-005: Color-code completion states)
    private func getColorForCompletion(isCompleted: Bool, date: Date) -> Color {
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            // Today - highlight
            return isCompleted ? .green.opacity(0.8) : .gray.opacity(0.3)
        } else if date > Date() {
            // Future dates
            return .clear
        } else {
            // Past dates
            if isCompleted {
                return .green.opacity(0.6)
            } else {
                return .red.opacity(0.3) // Missed
            }
        }
    }
}

// Make SkillProgress identifiable for ForEach
extension SkillProgress: Identifiable {
    var id: UUID { skillId }
}

#Preview {
    let appState = AppState()
    return ProgressTrackingView(appState: appState)
}

