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
    @State private var appearedCards: Set<UUID> = []

    @State private var deletingWorkoutsHistory: Set<UUID> = []

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                .onChange(of: selectedMonth) { loadHistories() }
                .onChange(of: selectedYear) { loadHistories() }

            // Summary header
            if !histories.isEmpty {
                HStack {
                    Text("\(histories.count) workout\(histories.count == 1 ? "" : "s") completed")
                        .font(.subheadline)
                        .foregroundColor(Color("MyGrey"))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Divider()
            if histories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No workout history yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Your past workouts will appear here once you complete them.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            else{
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(Array(histories.enumerated()), id: \.element) { index, history in
                            if let workoutId = history.workoutR?.id,
                               let historyId = history.id {
                                WorkoutHistoryCardView(workoutId: workoutId, history: history, onDelete: {
                                    deleteWorkoutHistory(historyId)
                                })
                                .opacity(appearedCards.contains(historyId) ? 1 : 0)
                                .offset(y: appearedCards.contains(historyId) ? 0 : 20)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.1)) {
                                        _ = appearedCards.insert(historyId)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.myWhite)
        .onAppear {
            loadHistories()
        }
    }
    
    private func loadHistories() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1

        guard let startDate = calendar.date(from: components) else {
            print("Error: Unable to create date from components - year: \(selectedYear), month: \(selectedMonth + 1)")
            histories = []
            return
        }

        appearedCards.removeAll()
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
