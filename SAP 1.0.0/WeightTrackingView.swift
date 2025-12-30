//
//  WeightTrackingView.swift
//  SAP 1.0.0
//
//  Created by Tomiwo Owoseje  on 22/12/2025.
//

import SwiftUI

struct WeightTrackingView: View {
    @Bindable var appState: AppState
    @State private var weightInput: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showAddWeightSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Weight input card
                    weightInputCard
                    
                    // Line graph
                    if !appState.weightEntries.isEmpty {
                        weightLineGraph
                    } else {
                        emptyStateView
                    }
                    
                    // Weight entries list
                    if !appState.weightEntries.isEmpty {
                        weightEntriesList
                    }
                }
                .padding()
            }
            .navigationTitle("Weight Tracking")
            .onAppear {
                // Clean up outdated or invalid weight entries on appear
                appState.cleanupWeightEntries()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let latestWeight = appState.weightEntries.sorted(by: { $0.date > $1.date }).first {
                            weightInput = String(format: "%.1f", latestWeight.weight)
                        } else {
                            weightInput = ""
                        }
                        selectedDate = Date()
                        showAddWeightSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    }
                }
            }
            .sheet(isPresented: $showAddWeightSheet) {
                WeightInputSheet(
                    weight: $weightInput,
                    date: $selectedDate,
                    appState: appState,
                    onSave: {
                        if let weight = Double(weightInput.replacingOccurrences(of: ",", with: ".")) {
                            appState.addWeightEntry(weight: weight, for: selectedDate)
                            // Clear input after saving
                            weightInput = ""
                        }
                        showAddWeightSheet = false
                    }
                )
            }
        }
    }
    
    // Weight input card with trend analysis
    private var weightInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "scalemass")
                    .foregroundColor(.indigo)
                    .font(.title3)
                
                Text("Today's Weight")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let todayWeight = appState.getWeight(for: Date()) {
                    Text(String(format: "%.1f kg", todayWeight))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.indigo)
                }
            }
            
            if appState.getWeight(for: Date()) != nil {
                // Find the most recent entry to show last updated time
                if let latestEntry = appState.weightEntries.sorted(by: { $0.date > $1.date }).first,
                   Calendar.current.isDate(latestEntry.date, inSameDayAs: Date()) {
                    Text("Last updated: \(timeFormatter.string(from: latestEntry.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Last updated: \(dateFormatter.string(from: Date()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Trend analysis
                if let trend = calculateTrend() {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .foregroundColor(trend.color)
                            .font(.caption)
                        Text(trend.text)
                            .font(.caption)
                            .foregroundColor(trend.color)
                    }
                }
            } else {
                Text("No weight recorded for today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // Calculate weight trend (last 7 days)
    private func calculateTrend() -> (text: String, icon: String, color: Color)? {
        let entries = appState.weightEntries.sorted { $0.date < $1.date }
        guard entries.count >= 2 else { return nil }
        
        let recentEntries = entries.suffix(7)
        guard recentEntries.count >= 2 else { return nil }
        
        let firstWeight = recentEntries.first!.weight
        let lastWeight = recentEntries.last!.weight
        let difference = lastWeight - firstWeight
        
        if abs(difference) < 0.1 {
            return ("Stable", "minus.circle.fill", .gray)
        } else if difference > 0 {
            return (String(format: "+%.1f kg", difference), "arrow.up.circle.fill", .red)
        } else {
            return (String(format: "%.1f kg", difference), "arrow.down.circle.fill", .green)
        }
    }
    
    // Weight line graph
    private var weightLineGraph: some View {
        let entries = appState.weightEntries.sorted { $0.date < $1.date }
        let minWeight = entries.map { $0.weight }.min() ?? 0
        let maxWeight = entries.map { $0.weight }.max() ?? 100
        let weightRange = maxWeight - minWeight
        let padding: Double = weightRange > 0 ? weightRange * 0.1 : 5
        let effectiveMin = minWeight - padding
        let effectiveMax = maxWeight + padding
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Weight Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                // Graph
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let graphHeight = height - 30
                    let effectiveRange = effectiveMax - effectiveMin
                    
                    ZStack {
                        // Grid lines
                        ForEach(0..<5) { i in
                            let y = CGFloat(i) * graphHeight / 4
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: width, y: y))
                            }
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        }
                        
                        // Weight line
                        if entries.count > 1 {
                            Path { path in
                                for (index, entry) in entries.enumerated() {
                                    let x = CGFloat(index) * width / CGFloat(entries.count - 1)
                                    let normalizedWeight = (entry.weight - effectiveMin) / effectiveRange
                                    let y = graphHeight - (CGFloat(normalizedWeight) * graphHeight)
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color(red: 0.5, green: 0.3, blue: 0.8), lineWidth: 3)
                            
                            // Data points
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                let x = CGFloat(index) * width / CGFloat(entries.count - 1)
                                let normalizedWeight = (entry.weight - effectiveMin) / effectiveRange
                                let y = graphHeight - (CGFloat(normalizedWeight) * graphHeight)
                                
                                Circle()
                                    .fill(Color(red: 0.5, green: 0.3, blue: 0.8))
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .position(x: x, y: y)
                            }
                        } else if entries.count == 1 {
                            // Single point
                            let normalizedWeight = (entries[0].weight - effectiveMin) / effectiveRange
                            let y = graphHeight - (CGFloat(normalizedWeight) * graphHeight)
                            
                            Circle()
                                .fill(Color(red: 0.5, green: 0.3, blue: 0.8))
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .position(x: width / 2, y: y)
                        }
                    }
                    .frame(height: height)
                }
                .frame(height: 250)
                
                // X-axis labels (dates)
                HStack {
                    let step = max(1, entries.count / 5)
                    ForEach(Array(entries.enumerated().filter { $0.offset % step == 0 || $0.offset == entries.count - 1 }), id: \.element.id) { _, entry in
                        Spacer()
                        Text(dateFormatter.string(from: entry.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.top, 4)
                
                // Y-axis labels (weight)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(String(format: "%.1f kg", effectiveMax))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f kg", effectiveMin))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 250)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    // Weight entries list
    private var weightEntriesList: some View {
        let entries = appState.weightEntries.sorted { $0.date > $1.date }
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Weight History")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(entries) { entry in
                WeightEntryRow(entry: entry, appState: appState)
            }
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No weight data yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add your first weight entry to start tracking")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// Weight entry row
struct WeightEntryRow: View {
    let entry: WeightEntry
    @Bindable var appState: AppState
    @State private var showEditSheet = false
    @State private var weightInput: String = ""
    @State private var selectedDate: Date
    
    init(entry: WeightEntry, appState: AppState) {
        self.entry = entry
        self.appState = appState
        _selectedDate = State(initialValue: entry.date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: entry.date))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(dayOfWeekFormatter.string(from: entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.1f kg", entry.weight))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.indigo)
            
            Button(action: {
                weightInput = String(format: "%.1f", entry.weight)
                selectedDate = entry.date
                showEditSheet = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $showEditSheet) {
            WeightInputSheet(
                weight: $weightInput,
                date: $selectedDate,
                appState: appState,
                onSave: {
                    if let weight = Double(weightInput.replacingOccurrences(of: ",", with: ".")) {
                        appState.addWeightEntry(weight: weight, for: selectedDate)
                    }
                    showEditSheet = false
                }
            )
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var dayOfWeekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
}

// Weight input sheet
struct WeightInputSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weight: String
    @Binding var date: Date
    @Bindable var appState: AppState
    let onSave: () -> Void
    
    private var existingWeight: Double? {
        appState.getWeight(for: date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Weight")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                if let existing = existingWeight {
                    Section(header: Text("Current Weight for This Date")) {
                        Text(String(format: "%.1f kg", existing))
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Saving will update this entry")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(weight.isEmpty ? "Add Weight" : "Edit Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(weight.isEmpty || Double(weight.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
        }
    }
}

#Preview {
    let appState = AppState()
    return WeightTrackingView(appState: appState)
}

