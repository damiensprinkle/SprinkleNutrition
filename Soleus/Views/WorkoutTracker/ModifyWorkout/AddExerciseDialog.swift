import SwiftUI

struct AddExerciseDialog: View {
    @Binding var workoutDetails: [WorkoutDetailInput]
    @Binding var showingDialog: Bool
    @State private var selectedWorkoutQuantifier: String = "Reps"
    @State private var selectedWorkoutMeasurement: String = "Weight"
    
    @State private var exerciseName: String = ""
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 0) // anchor top alignment when sheet grows
            // Header
            VStack(spacing: 8) {
                Text("Add Exercise")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Configure your new exercise")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 20) {
                // Exercise Name
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Exercise Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(exerciseName.count)/30")
                            .font(.caption)
                            .foregroundColor(exerciseName.count >= 30 ? .red : .secondary)
                    }

                    TextField("e.g., Bench Press", text: $exerciseName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .focused($isNameFieldFocused)
                        .onChange(of: exerciseName) {
                            if exerciseName.count > 30 {
                                exerciseName = String(exerciseName.prefix(30))
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                if isNameFieldFocused {
                                    Button("Done") {
                                        isNameFieldFocused = false
                                    }
                                }
                            }
                        }
                        .accessibilityIdentifier(AccessibilityID.exerciseNameField)
                }

                // Quantifier
                VStack(alignment: .leading, spacing: 8) {
                    Text("Track By")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Picker("Track By", selection: $selectedWorkoutQuantifier) {
                        Text("Reps").tag("Reps")
                        Text("Distance").tag("Distance")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier(AccessibilityID.exerciseTrackByPicker)
                }

                // Measurement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Measure With")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Picker("Measure With", selection: $selectedWorkoutMeasurement) {
                        Text("Weight").tag("Weight")
                        Text("Time").tag("Time")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier(AccessibilityID.exerciseMeasureWithPicker)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    self.showingDialog = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .accessibilityIdentifier(AccessibilityID.exerciseDialogCancelButton)

                Button(action: {
                    addNewExercise()
                }) {
                    Text("Add Exercise")
                        .font(.headline)
                        .foregroundColor(.staticWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(exerciseName.isEmpty ? Color.gray : Color.myBlue)
                        .cornerRadius(10)
                }
                .accessibilityIdentifier(AccessibilityID.exerciseDialogAddButton)
                .disabled(exerciseName.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 400)
        .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.myBlue)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
    
    private func addNewExercise() {
        if(exerciseName.isEmpty) {
            return
        }
        else{
            let measurement = selectedWorkoutMeasurement
            let quantifier = selectedWorkoutQuantifier
            let newIndex = workoutDetails.last?.orderIndex ?? 0
            let newDetail = WorkoutDetailInput(
                id: UUID(),
                exerciseName: exerciseName,
                orderIndex: newIndex + 1,
                sets: [SetInput(
                    id: UUID(),
                    reps: 0,
                    weight: 0,
                    time: 0,
                    distance: 0,
                    isCompleted: false,
                    setIndex: 1,
                    exerciseQuantifier: quantifier,
                    exerciseMeasurement: measurement
                )],
                exerciseQuantifier: quantifier,
                exerciseMeasurement: measurement
            )
            workoutDetails.append(newDetail)
            self.showingDialog = false
        }

    }
    
}
