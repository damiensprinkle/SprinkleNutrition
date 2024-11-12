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
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(0..<months.count, id: \.self) { index in
                        Text(self.months[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity) // Take up maximum available width
                
                .accentColor(.myWhite)
                
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(describing: year)).tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity) // Take up maximum available width
                
                .accentColor(.myWhite)
            }
            .padding([.top, .bottom], 5) // Reduce vertical padding to minimize vertical space
            .padding([.leading, .trailing])
            .background(.myBlue)
            .cornerRadius(15.0) // Apply corner radius to the background
        }
        .padding(.horizontal)
    }
}

