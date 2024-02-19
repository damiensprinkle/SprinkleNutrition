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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("The following information is required in order to calculate your BMR. If you don't care about this, simply OPT OUT")) {
                    VStack(alignment: .leading) {
                        Text("Weight")
                            .font(.caption)
                        TextField("Enter weight", text: $weight)
                            .keyboardType(.numberPad)
                    }
                    Picker("Weight Preference", selection: $weightPreference) {
                        Text("lbs").tag("lbs")
                        Text("kg").tag("kg")
                    }
                    VStack(alignment: .leading) {
                        Text("Height")
                            .font(.caption)
                        TextField("Enter height", text: $height)
                            .keyboardType(.numberPad)
                    }
                    Picker("Height Preference", selection: $userHeightPreference) {
                        Text("inches").tag("inches")
                        Text("cm").tag("cm")
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
            }
        }
    }

    private func saveUserDetails() {
        if let weightInt = Int32(weight), let heightInt = Int32(height), let ageInt = Int32(age) {
            userManager.addUser(weight: weightInt, height: heightInt, age: ageInt, gender: gender)
            isPresented = false
        }
    }
}
