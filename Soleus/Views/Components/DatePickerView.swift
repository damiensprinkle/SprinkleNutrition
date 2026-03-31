import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    var cardColor: Color
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(DefaultDatePickerStyle())
                    .foregroundColor(.staticWhite)
                    .font(.system(size: 20))
                Spacer()
            }
            .background(cardColor)
            .cornerRadius(15.0)
        }
        .padding()
    }
}
