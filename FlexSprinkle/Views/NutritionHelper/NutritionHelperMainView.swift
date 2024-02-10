import SwiftUI

struct NutritionHelperMainView: View {
    @State private var selectedDate = Date()
    
    
    var body: some View {
        VStack {
            Divider()
            DatePickerView(selectedDate: $selectedDate, cardColor: Color("MyBlue"))
            Spacer()
        }
    }
}

