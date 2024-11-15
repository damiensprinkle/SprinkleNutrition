//
//  WorkoutHistory.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/16/24.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var workoutController: WorkoutTrackerController
    @State private var histories: [WorkoutHistory] = []
    
    @State private var deletingWorkoutsHistory: Set<UUID> = []
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                .onChange(of: selectedMonth) { loadHistories() }
                .onChange(of: selectedYear) { loadHistories() }
            Divider()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(histories, id: \.self) { history in
                        WorkoutHistoryCardView(workoutId: history.workoutR!.id!, history: history, onDelete: {
                            deleteWorkoutHistory(history.id!)
                        })
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadHistories()
        }
        .navigationTitle("Workout History")
    }
    
    private func loadHistories() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        let startDate = calendar.date(from: components)!
        
        histories = workoutController.workoutManager.fetchAllWorkoutHistory(for: startDate) ?? []
    }
    
    private func deleteWorkoutHistory(_ historyId: UUID) {
        withAnimation {
            deletingWorkoutsHistory.insert(historyId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    self.workoutController.workoutManager.deleteWorkoutHistory(for: historyId)
                    loadHistories()
                    self.deletingWorkoutsHistory.remove(historyId)
                }
            }
        }
    }
    
}
