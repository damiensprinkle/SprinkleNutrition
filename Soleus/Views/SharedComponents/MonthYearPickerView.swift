//
//  MonthYearPickerView.swift
//  FlexSprinkle
//
//  Created by Damien Sprinkle on 2/17/24.
//

import SwiftUI

struct MonthYearPickerView: View {
    private var months: [String] = Calendar.current.monthSymbols
    private var years: [Int] = (2024...2030).map { $0 }
    
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    
    init(selectedMonth: Binding<Int>, selectedYear: Binding<Int>) {
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
    }
    
    var body: some View {
        VStack{
            HStack(spacing: 12) {
                // Month picker
                Menu {
                    Picker("", selection: $selectedMonth) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(self.months[index]).tag(index)
                        }
                    }
                } label: {
                    HStack {
                        Text(months[selectedMonth])
                            .foregroundColor(Color("MyBlack"))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(Color("MyGrey"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("MyGrey").opacity(0.15))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)

                // Year picker
                Menu {
                    Picker("", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(describing: year)).tag(year)
                        }
                    }
                } label: {
                    HStack {
                        Text(String(selectedYear))
                            .foregroundColor(Color("MyBlack"))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(Color("MyGrey"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("MyGrey").opacity(0.15))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

