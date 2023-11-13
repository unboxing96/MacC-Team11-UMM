//
//  ManualRecordInExpenseView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI
import CoreLocation

struct ManualRecordInExpenseView: View {
    @StateObject var viewModel = ManualRecordInExpenseViewModel()
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.dismiss) var dismiss
    let viewContext = PersistenceController.shared.container.viewContext
    let exchangeHandler = ExchangeRateHandler.shared
    let fraction0NumberFormatter = NumberFormatter()
    let dateGapHandler = DateGapHandler.shared
    
    let given_wantToActivateAutoSaveTimer: Bool
    let given_payAmount: Double
    let given_currency: Int
    let given_info: String?
    let given_infoCategory: ExpenseInfoCategory
    let given_paymentMethod: PaymentMethod
    let given_soundRecordData: Data?
    let given_expense: Expense
    let given_payDate: Date?
    let given_country: Int
    let given_location: String?
    let given_id: ObjectIdentifier
    
    var body: some View {
        ZStack {
            Color(.white)
            VStack(spacing: 0) {
                ScrollView {
                    Spacer()
//                        .frame(height: 107 - 9 + 45)
                        .frame(height: 50)
                    payAmountBlockView
                    Spacer()
                        .frame(height: 64)
                    inSentencePropertyBlockView
                    Divider()
                        .foregroundStyle(.gray200)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                    notInSentencePropertyBlockView
                    Spacer()
                        .frame(height: 150)
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                autoSaveTextView
                Spacer()
                    .frame(height: 16)
                if !viewModel.isSameData {
                    saveButtonView
//                    Spacer()
//                        .frame(height: 45)
                }
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.white, for: .navigationBar)
        .navigationTitle("상세 내역")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButtonView)
        .sheet(isPresented: $viewModel.travelChoiceModalIsShown) {
            TravelChoiceInRecordModal(chosenTravel: $mainVM.chosenTravelInManualRecord)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.categoryChoiceModalIsShown) {
            CategoryChoiceModal(chosenCategory: $viewModel.category)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.countryChoiceModalIsShown) {
            CountryChoiceModal(chosenCountry: $viewModel.country, countryIsModified: $viewModel.countryIsModified, countryArray: viewModel.otherCountryCandidateArray, currentCountry: viewModel.currentCountry)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.dateChoiceModalIsShown) {
            DateChoiceModal(date: $viewModel.payDate, startDate: mainVM.chosenTravelInManualRecord?.startDate ?? Date.distantPast, endDate: mainVM.chosenTravelInManualRecord?.endDate ?? Date.distantFuture)
                .presentationDetents([.height(289 - 34)])
        }
        .alert(Text("저장하지 않고 나가기"), isPresented: $viewModel.showAlert) {
            Button {
                viewModel.backButtonAlertIsShown = false
            } label: {
                Text("취소")
            }
            Button {
                dismiss()
                viewModel.backButtonAlertIsShown = false
                viewModel.isSameData = true
            } label: {
                Text("나가기")
            }
        } message: {
            Text("현재 화면의 정보를 모두 초기화하고 이전 화면으로 돌아갈까요?")
        }
        .onAppear {
            viewModel.wantToActivateAutoSaveTimer = given_wantToActivateAutoSaveTimer
            
            viewModel.payAmount = given_payAmount
            if viewModel.payAmount == -1 {
                viewModel.visiblePayAmount = ""
            } else {
                if abs(viewModel.payAmount - Double(Int(viewModel.payAmount))) < 0.0000001 {
                    viewModel.visiblePayAmount = String(format: "%.0f", viewModel.payAmount)
                } else {
                    viewModel.visiblePayAmount = String(viewModel.payAmount)
                }
            }
            viewModel.info = given_info
            viewModel.visibleInfo = viewModel.info == nil ? "" : viewModel.info!
            viewModel.category = given_infoCategory
            viewModel.paymentMethod = given_paymentMethod
            viewModel.soundRecordData = given_soundRecordData
            viewModel.currency = given_currency
            viewModel.payDate = given_payDate ?? Date()
            viewModel.country = given_country
            viewModel.locationExpression = given_location ?? ""
            viewModel.expenseId = given_id

            DispatchQueue.main.async {
                MainViewModel.shared.chosenTravelInManualRecord = MainViewModel.shared.selectedTravel
            }

            do {
                viewModel.travelArray = try viewContext.fetch(Travel.fetchRequest())
            } catch {
                print("error fetching travelArray: \(error.localizedDescription)")
            }

            if let participantArray = MainViewModel.shared.chosenTravelInManualRecord?.participantArray {
                viewModel.participantTupleArray = [("나", true)] + participantArray.map { ($0, true) }
            } else {
                viewModel.participantTupleArray = [("나", true)]
            }
            
            // 초기값
            MainViewModel.shared.chosenTravelInManualRecord = given_expense.travel
            
            var expenseArray: [Expense] = []
            if let chosenTravel = MainViewModel.shared.chosenTravelInManualRecord {
                do {
                    try expenseArray = viewContext.fetch(Expense.fetchRequest()).filter { expense in
                        if let belongTravel = expense.travel {
                            return belongTravel.id == chosenTravel.id
                        } else {
                            return false
                        }
                    }
                } catch {
                    print("error fetching expenses: \(error.localizedDescription)")
                }
            }
            
            viewModel.otherCountryCandidateArray = Array(Set(expenseArray.map { Int($0.country) })).sorted()

            // MARK: - ^^^
            if viewModel.currentCountry == 3 {
                viewModel.currencyCandidateArray = [4, 0]
            } else {
                let stringCurrencyArray = CountryInfoModel.shared.countryResult[viewModel.currentCountry]?.relatedCurrencyArray ?? []
                viewModel.currencyCandidateArray = []
                for stringCurrency in stringCurrencyArray {
                    for tuple in CurrencyInfoModel.shared.currencyResult where tuple.key != -1 {
                        if tuple.value.isoCodeNm == stringCurrency {
                            viewModel.currencyCandidateArray.append(tuple.key)
                            break
                        }
                    }
                }
                
                if !viewModel.currencyCandidateArray.contains(4) {
                    viewModel.currencyCandidateArray.append(4)
                }
                if !viewModel.currencyCandidateArray.contains(0) {
                    viewModel.currencyCandidateArray.append(0)
                }
            }

            if viewModel.payAmount == -1 || viewModel.currency == -1 {
                viewModel.payAmountInWon = -1
            } else {
                if let exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: CurrencyInfoModel.shared.currencyResult[viewModel.currency]?.isoCodeNm ?? "") {
                    viewModel.payAmountInWon = viewModel.payAmount * exchangeRate
                } else {
                    viewModel.payAmountInWon = -1
                }
            }
            viewModel.soundRecordData = given_soundRecordData

            viewModel.getLocation()
//            viewModel.country = viewModel.currentCountry
            viewModel.countryExpression = CountryInfoModel.shared.countryResult[viewModel.country]?.koreanNm ?? "알 수 없음"
//            viewModel.locationExpression = viewModel.currentLocation
            
            if !viewModel.otherCountryCandidateArray.contains(viewModel.country) {
                viewModel.otherCountryCandidateArray.append(viewModel.country)
            }
            
//            let stringCurrency = CountryInfoModel.shared.countryResult[viewModel.currentCountry]?.relatedCurrencyArray.first ?? "Unknown"
            
//            viewModel.currency =  4 // 미국 달러
            
//            for tuple in CurrencyInfoModel.shared.currencyResult where tuple.key != -1 {
//                if tuple.value.isoCodeNm == stringCurrency {
//                    viewModel.currency = tuple.key
//                    break
//                }
//            }
            
            if viewModel.currentCountry == 3 { // 미국
                viewModel.currencyCandidateArray = [4, 0]
            } else {
                let stringCurrencyArray = CountryInfoModel.shared.countryResult[viewModel.currentCountry]?.relatedCurrencyArray ?? []
                viewModel.currencyCandidateArray = []
                for stringCurrency in stringCurrencyArray {
                    for tuple in CurrencyInfoModel.shared.currencyResult where tuple.key != -1 {
                        if tuple.value.isoCodeNm == stringCurrency {
                            viewModel.currencyCandidateArray.append(tuple.key)
                            break
                        }
                    }
                }
                
                if !viewModel.currencyCandidateArray.contains(4) { // 미국 달러
                    viewModel.currencyCandidateArray.append(4) // 미국 달러
                }
                if !viewModel.currencyCandidateArray.contains(0) { // 한국 원
                    viewModel.currencyCandidateArray.append(0) // 한국 원
                }
            }
            
            if viewModel.payAmount == -1 || viewModel.currency == -1 {
                viewModel.payAmountInWon = -1
            } else {
                if let exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: CurrencyInfoModel.shared.currencyResult[viewModel.currency]?.isoCodeNm ?? "") {
                    viewModel.payAmountInWon = viewModel.payAmount * exchangeRate
                } else {
                    viewModel.payAmountInWon = -1
                }
            }
            
            // MARK: - NumberFormatter
            
            fraction0NumberFormatter.numberStyle = .decimal
            fraction0NumberFormatter.maximumFractionDigits = 0
            
            // MARK: - timer
//            if viewModel.wantToActivateAutoSaveTimer && (viewModel.payAmount != -1 || viewModel.info != nil) {
//                viewModel.secondCounter = 8
//                viewModel.autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//                    if let secondCounter = viewModel.secondCounter {
//                        if secondCounter > 1 {
//                            viewModel.secondCounter! -= 1
//                        } else {
//                            if viewModel.payAmount != -1 || viewModel.info != nil {
//                                viewModel.secondCounter = nil
//                                viewModel.save()
//                                if mainVM.chosenTravelInManualRecord != nil {
//                                    mainVM.selectedTravel = mainVM.chosenTravelInManualRecord
//                                }
//                                viewModel.deleteUselessAudioFiles()
//                                self.dismiss()
//                                timer.invalidate()
//                            } else {
//                                viewModel.secondCounter = nil
//                                timer.invalidate()
//                            }
//                        }
//                    }
//                }
//            }
        }
        .onAppear(perform: UIApplication.shared.hideKeyboard)
        .onAppear {
            viewModel.checkFirstAppear()
            MainViewModel.shared.firstChosenTravelInManualRecord = MainViewModel.shared.chosenTravelInManualRecord
        }
        .onDisappear {
            viewModel.autoSaveTimer?.invalidate()
            viewModel.secondCounter = nil
        }
    }
    
    private var backButtonView: some View {
        Button {
            viewModel.autoSaveTimer?.invalidate()
            viewModel.secondCounter = nil
            viewModel.backButtonAlertIsShown = true
            viewModel.updateAlertState()
            if !viewModel.showAlert {
                dismiss()
            }
            print("back button tapped")
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .foregroundColor(Color.black)
        }
    }
    
    private var payAmountBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Text(viewModel.visiblePayAmount == "" ? "  -  " : viewModel.visiblePayAmount)
                                .lineLimit(1)
                                .font(.display4)
                                .hidden()
                            
                            TextField(" - ", text: $viewModel.visiblePayAmount)
                                .lineLimit(1)
                                .foregroundStyle(.black)
                                .font(.display4)
                                .keyboardType(.decimalPad)
                                .layoutPriority(-1)
                                .tint(.mainPink)
                                .onTapGesture {
                                    viewModel.autoSaveTimer?.invalidate()
                                    viewModel.secondCounter = nil
                                }
                        }
                        
                        ZStack {
                            Picker("화폐", selection: $viewModel.currency) {
                                ForEach(viewModel.currencyCandidateArray, id: \.self) { currency in
                                    Text((CurrencyInfoModel.shared.currencyResult[currency]?.koreanNm ?? "알 수 없음") + " " + (CurrencyInfoModel.shared.currencyResult[currency]?.symbol ?? "-"))
                                }
                            }
                            .onTapGesture {
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                Text((CurrencyInfoModel.shared.currencyResult[viewModel.currency]?.koreanNm ?? "알 수 없음") + " " + (CurrencyInfoModel.shared.currencyResult[viewModel.currency]?.symbol ?? "-"))
                                    .foregroundStyle(.gray400)
                                    .font(.display2)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                            .allowsHitTesting(false)
                        }
                    }
                    
                    if viewModel.payAmount == -1 {
                        Text("( - 원)")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    } else {
                        if let formattedString = fraction0NumberFormatter.string(from: NSNumber(value: viewModel.payAmountInWon)) {
                            Text("(" + formattedString + "원" + ")")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        } else {
                            Text("( - 원)")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        }
                    }
                }
                Spacer()
                
                Group {
                    if viewModel.soundRecordData == nil {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .frame(width: 54, height: 54)
                                .shadow(color: .gray200, radius: 3)
                            
                            Circle()
                                .strokeBorder(.gray200, lineWidth: 1)
                            
                            HStack(spacing: 3) {
                                Capsule()
                                    .foregroundStyle(.gray200)
                                    .frame(width: 1.5, height: 9)
                                Capsule()
                                    .foregroundStyle(.gray200)
                                    .frame(width: 1.5, height: 14)
                                Capsule()
                                    .foregroundStyle(.gray200)
                                    .frame(width: 1.5, height: 19)
                                Capsule()
                                    .foregroundStyle(.gray200)
                                    .frame(width: 1.5, height: 14)
                                Capsule()
                                    .foregroundStyle(.gray200)
                                    .frame(width: 1.5, height: 9)
                            }
                        }
                    } else {
                        if viewModel.playingRecordSound {
                            PlayngRecordSoundView()
                        } else {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.white)
                                    .frame(width: 54, height: 54)
                                    .shadow(color: .gray200, radius: 3)
                                
                                Circle()
                                    .strokeBorder(.gray300, lineWidth: 1)
                                
                                HStack(spacing: 3) {
                                    Capsule()
                                        .foregroundStyle(.black)
                                        .frame(width: 1.5, height: 9)
                                    Capsule()
                                        .foregroundStyle(.black)
                                        .frame(width: 1.5, height: 14)
                                    Capsule()
                                        .foregroundStyle(.black)
                                        .frame(width: 1.5, height: 19)
                                    Capsule()
                                        .foregroundStyle(.black)
                                        .frame(width: 1.5, height: 14)
                                    Capsule()
                                        .foregroundStyle(.black)
                                        .frame(width: 1.5, height: 9)
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.gray200)
                .frame(width: 54, height: 54)
                .onTapGesture {
                    print("소리 재생 버튼")
                    viewModel.autoSaveTimer?.invalidate()
                    viewModel.secondCounter = nil
                    
                    if viewModel.soundRecordData != nil {
                        if !viewModel.playingRecordSound {
                            if let soundRecordData = viewModel.soundRecordData {
                                viewModel.startPlayingAudio(data: soundRecordData)
                                viewModel.playingRecordSound = true
                            } else {
                                print("ManualRecordInExpenseView | payAmountBlockView | Failed to unwrapping soundRecordData")
                            }
                        } else {
                            viewModel.stopPlayingAudio()
                            viewModel.playingRecordSound = false
                        }
                    }
                }
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var inSentencePropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        
                        Text("소비 내역")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack(alignment: .leading) {
//                        높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(.gray100)
                            .layoutPriority(-1)
                        
                        TextField("-", text: $viewModel.visibleInfo)
                            .lineLimit(nil)
                            .foregroundStyle(.black)
                            .font(.body3)
                            .tint(.mainPink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .onTapGesture {
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                            }
                    }
                }
                
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("카테고리")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        HStack(spacing: 8) {
                            Image(viewModel.category.manualRecordImageString)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(viewModel.category.visibleDescription)
                                .foregroundStyle(.black)
                                .font(.body3)
                        }
                    }
                    Spacer()
                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("카테고리 수정 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                            viewModel.categoryChoiceModalIsShown = true
                        }
                    
                }
                
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("결제 수단")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    
                    Group {
                        if viewModel.paymentMethod == .cash {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.black, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("현금")
                                    .foregroundStyle(.black)
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.gray200, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("현금")
                                    .foregroundStyle(Color(0xbfbfbf)) // 색상 디자인 시스템 형식으로 고치기 ^^^
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .onTapGesture {
                        print("현금 선택 버튼")
                        viewModel.autoSaveTimer?.invalidate()
                        viewModel.secondCounter = nil
                        if viewModel.paymentMethod == .cash {
                            viewModel.paymentMethod = .unknown
                        } else {
                            viewModel.paymentMethod = .cash
                        }
                    }
                    
                    Spacer()
                        .frame(width: 6)
                    
                    Group {
                        if viewModel.paymentMethod == .card {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.black, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("카드")
                                    .foregroundStyle(.black)
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.gray200, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("카드")
                                    .foregroundStyle(Color(0xbfbfbf)) // 색상 디자인 시스템 형식으로 고치기 ^^^
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .onTapGesture {
                        print("카드 선택 버튼")
                        viewModel.autoSaveTimer?.invalidate()
                        viewModel.secondCounter = nil
                        if viewModel.paymentMethod == .card {
                            viewModel.paymentMethod = .unknown
                        } else {
                            viewModel.paymentMethod = .card
                        }
                    }
                    
                    Spacer()
                }
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var notInSentencePropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("여행 제목")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        Text(mainVM.chosenTravelInManualRecord?.name != tempTravelName ? mainVM.chosenTravelInManualRecord?.name ?? "-" : "임시 기록")
                            .lineLimit(nil)
                            .foregroundStyle(mainVM.chosenTravelInManualRecord?.name != tempTravelName ? .black : .gray400)
                            .font(.subhead2_1)
                    }
                    Spacer()

                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("여행 선택 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                            viewModel.travelChoiceModalIsShown = true
                        }
                    
                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("결제 인원")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ScrollView(.horizontal) {
                        HStack(spacing: 6) {
                            if viewModel.participantTupleArray.count > 0 {
                                ParticipantArrayView(participantTupleArray: $viewModel.participantTupleArray, autoSaveTimer: $viewModel.autoSaveTimer, secondCounter: $viewModel.secondCounter)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .scrollIndicators(.never)

                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("지출 일시")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        Text("금")
                            .lineLimit(1)
                            .font(.subhead2_2)
                            .padding(.vertical, 6)
                            .hidden()
                        
                        Text(viewModel.payDate.toString(dateFormat: "yy.MM.dd(E) HH:mm"))
                            .foregroundStyle(.black)
                            .font(.subhead2_2)
                    }
                    Spacer()
                    
                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("지출 일시 수정 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                            viewModel.dateChoiceModalIsShown = true
                        }
                }
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            Spacer()
                                .frame(width: 116, height: 1)
                            Text("지출 위치")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        }
                        ZStack {
                            // 높이 설정용 히든 뷰
                            Text("금")
                                .lineLimit(1)
                                .font(.subhead2_2)
                                .padding(.vertical, 6)
                                .hidden()
                            
                            HStack(spacing: 8) {
                                ZStack {
                                    Image(CountryInfoModel.shared.countryResult[viewModel.country]?.flagString ?? "DefaultFlag")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Circle()
                                        .strokeBorder(.gray200, lineWidth: 1.0)
                                }
                                .frame(width: 24, height: 24)
                                
                                if !viewModel.countryIsModified {
                                    Text(viewModel.countryExpression + " " + viewModel.locationExpression)
                                        .foregroundStyle(.black)
                                        .font(.subhead2_2)
                                } else {
                                    Text(viewModel.countryExpression)
                                        .foregroundStyle(.black)
                                        .font(.subhead2_2)
                                }
                                
                            }
                        }
                        
                        Spacer()
                        
                        Image("manualRecordDownChevron")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .onTapGesture {
                                print("지출 위치 수정 버튼")
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                                viewModel.countryChoiceModalIsShown = true
                            }
                    }
                    
                    if viewModel.countryIsModified {
                        HStack(spacing: 0) {
                            ZStack(alignment: .leading) {
                                Spacer()
                                    .frame(width: 116, height: 1)
                                
                                Text(" ")
                                    .foregroundStyle(.gray300)
                                    .font(.caption2)
                            }
                            ZStack(alignment: .leading) {
                                //                        높이 설정용 히든 뷰
                                ZStack {
                                    Text("금")
                                        .foregroundStyle(.black)
                                        .font(.subhead2_1)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                }
                                .hidden()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                
                                TextField("상세 위치를 입력해주세요", text: $viewModel.locationExpression)
                                    .lineLimit(nil)
                                    .foregroundStyle(.black)
                                    .font(.body3)
                                    .tint(.mainPink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .onTapGesture {
                                        viewModel.autoSaveTimer?.invalidate()
                                        viewModel.secondCounter = nil
                                    }
                            }
                        }
                    }
                }
                
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var autoSaveTextView: some View {
        Group {
            if let secondCounter = viewModel.secondCounter {
                if secondCounter > 0 && secondCounter <= 3 {
                    Text("\(secondCounter)초 후 자동 저장")
                        .foregroundStyle(.gray300)
                        .font(.body2)
                } else {
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var saveButtonView: some View {
        ZStack {
            LargeButtonActive(title: "저장하기") {
                viewModel.save()
                var defaultTravel = Travel()
                do {
                    defaultTravel = try viewContext.fetch(Travel.fetchRequest()).filter { $0.name == tempTravelName }.first ?? Travel()
                } catch {
                    print("error fetching default travel: \(error.localizedDescription)")
                }
                if mainVM.chosenTravelInManualRecord != nil {
                    mainVM.selectedTravel = mainVM.chosenTravelInManualRecord
                } else {
                    mainVM.selectedTravel = defaultTravel
                }
                viewModel.deleteUselessAudioFiles()
                dismiss()
            }
            .opacity((viewModel.payAmount != -1 || viewModel.info != nil) ? 1 : 0.0000001)
            .allowsHitTesting(viewModel.payAmount != -1 || viewModel.info != nil)
            
            LargeButtonUnactive(title: "저장하기") { }
                .opacity((viewModel.payAmount != -1 || viewModel.info != nil) ? 0.0000001 : 1)
                .allowsHitTesting(!(viewModel.payAmount != -1 || viewModel.info != nil))
        }
    }
}

//    #Preview {
//        ManualRecordInExpenseView()
//    }
