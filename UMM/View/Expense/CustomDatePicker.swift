//
//  TestView.swift
//  UMM
//
//  Created by 김태현 on 10/20/23.
//

import SwiftUI

struct CustomDatePicker: View {
    @EnvironmentObject var mainVM: MainViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Binding var selectedDate: Date
    var pickerId: String
    let startDateOfTravel: Date
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { self.expenseViewModel.selectedDate.addTimeInterval(-86400)}, label: {
                Image(systemName: "chevron.left")
            })
            
            ZStack {
                Button {
                    expenseViewModel.triggerDatePickerPopover(pickerId: pickerId)
                } label: {
                    Text("\(expenseViewModel.selectedDate, formatter: dateFormatterWithDay)")
                        .foregroundStyle(.black)
                }
                
                // 안 보이게 하고 Button으로 호출
                DatePicker("", selection: $expenseViewModel.selectedDate,
                           in: expenseViewModel.datePickerRange(),
                           displayedComponents: [.date])
                    .labelsHidden()
                    .accessibilityIdentifier(pickerId)
                    .onReceive(expenseViewModel.$selectedDate) { _ in
                        DispatchQueue.main.async {
                            expenseViewModel.filteredTodayExpenses = expenseViewModel.getFilteredTodayExpenses()
                            expenseViewModel.groupedTodayExpenses = Dictionary(grouping: expenseViewModel.filteredTodayExpenses, by: { $0.country })
                        }
                    }
                    .colorInvert()
                    .colorMultiply(Color.clear)
            }
            
            Button { self.selectedDate.addTimeInterval(86400)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
}

//  #Preview {
//      CustomDatePicker()
//  }
