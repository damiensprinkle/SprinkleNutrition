//
//  UserDetailsFormViw.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/19/24.
//

import SwiftUI


struct UserDetailsFormView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userManager: UserManager
    
    @AppStorage("optOut") private var optOut: Bool = false
    @AppStorage("weightPreference") private var weightPreference: String = "lbs"
    @AppStorage("userHeightPreference") private var userHeightPreference: String = "inches"
    
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var gender: String = "Other"
    @State private var activityLevel: String = "Exercise 1-3 times/week"
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("The following information is required in order to calculate your BMR. If you don't care about this, simply OPT OUT")) {
                    Picker("Weight Preference", selection: $weightPreference) {
                        Text("lbs").tag("lbs")
                        Text("kg").tag("kg")
                    }
                    Picker("Height Preference", selection: $userHeightPreference) {
                        Text("inches").tag("inches")
                        Text("cm").tag("cm")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Weight")
                            .font(.caption)
                        TextField("Enter weight", text: $weight)
                            .keyboardType(.numberPad)
                    }
        
                    VStack(alignment: .leading) {
                        Text("Height")
                            .font(.caption)
                        TextField("Enter height", text: $height)
                            .keyboardType(.numberPad)
                    }
           
                    VStack(alignment: .leading) {
                        Text("Age")
                            .font(.caption)
                        TextField("Enter age", text: $age)
                            .keyboardType(.numberPad)
                    }
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    VStack(alignment: .leading) {
                        Text("Activity Level")
                            .font(.caption)
                        Picker("Activity", selection: $activityLevel) {
                            Text("Sedentary: little or no exercise").tag("Sedentary: little or no exercise")
                            Text("Exercise 1-3 times/week").tag("Exercise 1-3 times/week")
                            Text("Exercise 4-5 times/week").tag("Exercise 4-5 times/week")
                            Text("Daily exercise or intense exercise 3-4 times/week").tag("Daily exercise or intense exercise 3-4 times/week")
                            Text("Intense exercise 6-7 times/week").tag("Intense exercise 6-7 times/week")
                            Text("Very intense exercise daily, or physical job").tag("Very intense exercise daily, or physical job")
                        }
                    }
        
                }
                
                Section {
                    HStack {
                        Button("Opt Out") {
                            isPresented = false
                            optOut = true
                        }
                        Spacer()
                        Button("Save") {
                            saveUserDetails()
                        }
                    }
                }
            }
            .navigationBarTitle("User Details", displayMode: .inline)
        }
        .onAppear {
            if let userDetails = userManager.userDetails {
                weight = "\(userDetails.weight)"
                height = "\(userDetails.height)"
                age = "\(userDetails.age)"
                gender = userDetails.gender ?? "Other"
                activityLevel = userDetails.activityLevel ?? "Exercise 1-3 times/week"
            }
        }
    }
    
    private func saveUserDetails() {
        if let weightFloat = Float(weight), let heightFloat = Float(height), let ageInt = Int(age) {
            let bmr = calculateBMR(weight: weightFloat, height: heightFloat, age: ageInt, gender: gender)
            let adjustedBMR = adjustBMRForActivity(bmr: bmr)
            
            // Now you have adjustedBMR which you can use
            // For demonstration purposes, let's just print it
            print("Adjusted BMR: \(adjustedBMR)")
            if let weightInt = Int32(weight), let heightInt = Int32(height), let ageInt = Int32(age) {
                userManager.addUser(weight: weightInt, height: heightInt, age: ageInt, gender: gender, activityLevel: activityLevel, bmr: Int32(bmr))
                isPresented = false
            }
        }
    }
    
    private func calculateBMR(weight: Float, height: Float, age: Int, gender: String) -> Float {
        let weightInKg = weightPreference == "lbs" ? (weight * 0.453592) : weight
        let heightInCm = userHeightPreference == "inches" ? (height * 2.54) : height
        
        let bmr: Float = gender == "Male" ?
        (10 * weightInKg) + (6.25 * heightInCm) - (5 * Float(age)) + 5 :
        (10 * weightInKg) + (6.25 * heightInCm) - (5 * Float(age)) - 161
        
        return bmr
    }
    
    private func adjustBMRForActivity(bmr: Float) -> Float {
        switch activityLevel {
        case "Sedentary: little or no exercise":
            return bmr * 1.2
        case "Exercise 1-3 times/week":
            return bmr * 1.375
        case "Exercise 4-5 times/week":
            return bmr * 1.55
        case "Daily exercise or intense exercise 3-4 times/week":
            return bmr * 1.725
        case "Intense exercise 6-7 times/week":
            return bmr * 1.9
        case "Very intense exercise daily, or physical job":
            return bmr * 1.9
        default:
            return bmr // Default case, should not happen
        }
    }
    
}

