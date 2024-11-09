import SwiftUI

struct NutritionHelperMainView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            Divider()
            
            // Date picker with a custom color
            DatePickerView(selectedDate: $selectedDate, cardColor: Color("MyBlue"))

            // Progress bar with calories
            HStack {
                ProgressView(value: 0.5) // Example progress value
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                Text("500 / 2000 cal")
                    .font(.subheadline)
                    .padding(.leading, 10)
            }
            .padding()
            
            // Days of the week
            HStack(spacing: 10) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .overlay(Text(day.prefix(1))) // Display first letter of the day
                        .foregroundColor(day == getDayForSelectedDate() ? .white : .blue)
                        .background(day == getDayForSelectedDate() ? Color.blue : Color.clear)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // Meal type circles with icons
            HStack(spacing: 30) {
                mealIconView(name: "Breakfast", systemImage: "sunrise.fill", color: .yellow)
                mealIconView(name: "Lunch", systemImage: "fork.knife", color: .orange)
                mealIconView(name: "Dinner", systemImage: "moon.fill", color: .purple)
                mealIconView(name: "Snacks", systemImage: "takeoutbag.and.cup.and.straw.fill", color: .green)
            }
            .padding()
            
            Spacer()
            
            // Table for macros: Protein, Carbs, Fats
            VStack {
                Text("Macros")
                    .font(.headline)
                HStack {
                    ForEach(["Protein", "Carbs", "Fats"], id: \.self) { macro in
                        VStack {
                            Text(macro)
                            Text("0g") // Replace with actual values
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            
        }
    }
    
    // Helper function to get the current day of the week
    private func getDayForSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Abbreviated weekday
        return formatter.string(from: selectedDate)
    }
    
    // Custom view for meal icon with name and image
    private func mealIconView(name: String, systemImage: String, color: Color) -> some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: systemImage)
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                )
            Text(name)
                .font(.footnote)
        }
        .onTapGesture {
            // Navigate to corresponding meal view
        }
    }
}

struct NutritionHelperMainView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionHelperMainView()
    }
}
