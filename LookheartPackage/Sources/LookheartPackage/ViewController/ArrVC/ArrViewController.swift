import Foundation
import DGCharts
import UIKit

@available(iOS 13.0, *)
public class ArrViewController : UIViewController {
    
    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End
    
    struct FileDataStruct {
        var hour: Int
        var minutes: Int
        var second: Int
        var arrNumber: Int
    }
    
    private let SELECTED_COLOR = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    private let DESELECTED_COLOR = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
    private let BLACK_COLOR = UIColor.black
    private let HEARTATTACK_COLOR = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    
    private let ARRDATA_FILENAME = "/arrEcgData_"
    private let CSV_EXTENSION = ".csv"
    
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let YESTERDAY = false
    private let TOMORROW = true
    
    private let YEAR_FLAG = true
    private let TIME_FLAG = false
    
    private var calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let screenWidth = UIScreen.main.bounds.width
    
    private var currentYear:String = ""
    private var currentMonth:String = ""
    private var currentDay:String = ""
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var tomorrowDate:String = ""
    private var tomorrowYear:String = ""
    private var tomorrowMonth:String = ""
    private var tomorrowDay:String = ""
    
    private var email = ""
    
    private var arrDateArray:[String] = []
    private var arrFilePath:[String] = []
    private var arrDataEntries:[ChartDataEntry] = []
    
    private var idxButtonList: [UIButton] = []
    private var titleButtonList: [UIButton] = []
    private var arrNumber = 1
    
    private var emergencyIdxButtonList: [UIButton] = []
    private var emergencyTitleButtonList: [UIButton] = []
    private var emergencyList: [String: String] = [:]
    private var emergencyNumber = 1

    private var isArrViewLoaded: Bool = false
    
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    private lazy var calendarButton = UIButton(type: .custom).then {
        $0.setImage(calendarImage, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
    }
    
    //    ----------------------------- FSCalendar -------------------    //
    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
        $0.isHidden = true
    }
    
    //    ----------------------------- Chart -------------------    //
    private lazy var chartView = LineChartView().then {
        $0.xAxis.enabled = false
        $0.noDataText = ""
        $0.leftAxis.axisMaximum = 1024
        $0.leftAxis.axisMinimum = 0
        $0.rightAxis.enabled = false
        $0.legend.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = false
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
        $0.chartDescription.enabled = true
        $0.chartDescription.font = .systemFont(ofSize: 20)
    }
    
    private let arrState = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.isHidden = false
    }
    
    private let arrStateLabel = UILabel().then {
        $0.text = "arrType".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .darkGray
        $0.numberOfLines = 2
        $0.isHidden = false
    }
    
    private let bodyState = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
        $0.isHidden = false
    }
    
    private let bodyStateLabel = UILabel().then {
        $0.text = "arrState".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium) // 크기, 굵음 정도 설정
        $0.textColor = .darkGray
        $0.isHidden = false
    }
    
    
    //    ----------------------------- ARR List Contents -------------------    //
    private let listBackground = UILabel().then {   $0.isUserInteractionEnabled = true   }
    
    private lazy var todayDisplay = UILabel().then {
        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private lazy var tomorrowButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private let scrollView = UIScrollView()
    
    private var arrList = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    // MARK: - Button Event
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        chartView.isHidden = !chartView.isHidden
    }
    
    @objc func shiftDate(_ sender: UIButton) {
        
        switch(sender.tag) {
        case YESTERDAY_BUTTON_FLAG:
            
            dateCalculate(targetDate, 1, YESTERDAY)
        default:    // TOMORROW_BUTTON_FLAG
            dateCalculate(targetDate, 1, TOMORROW)
        }
        
        arrTable()
    }
    
    private func buttonEnable() {
        yesterdayButton.isEnabled = !yesterdayButton.isEnabled
        tomorrowButton.isEnabled = !tomorrowButton.isEnabled
        calendarButton.isEnabled = !calendarButton.isEnabled
    }
    
    // MARK: - viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
        setCalendarClosure()
        
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dissmissCalendar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVar()
        arrTable()
    }
    
    func initVar() {
        
        let currentDate = MyDateTime.shared.getSplitDateTime(.DATE)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        currentYear = currentDate[0]
        currentMonth = currentDate[1]
        currentDay = currentDate[2]
        
        targetDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        targetYear = currentYear
        targetMonth = currentMonth
        targetDay = currentDay
        
        setTomorrow(targetDate)
        
        dissmissCalendar()
    }
    
    //MARK: - setTable
    func arrTable() {
        todayDisplay.text = changeTimeFormat(targetDate, YEAR_FLAG)
        initArray()
        getArrList(email, targetDate, tomorrowDate)
    }
    
    
    
    func getArrList(_ email: String, _ startDate: String, _ endDate: String) {
        activityIndicator.startAnimating()
        NetworkManager.shared.getArrListToServer(startDate: startDate, endDate: endDate){ [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                guard let self = self else { return }
                
                switch(result){
                case .success(let arrDateList):
                    for arrDate in arrDateList {
                        if arrDate.address == nil || arrDate.address == "" { // ARR
                            self.arrDateArray.append(arrDate.writetime)
                        } else {    // HEART ATTACK
                            self.arrDateArray.append(arrDate.writetime)
                            self.emergencyList[arrDate.writetime] = arrDate.address
                        }
                    }
                    self.setArrList()
                case .failure(let error):
                    let errorMessage = NetworkErrorManager.shared.getErrorMessage(error as! NetworkError)
                    self.toastMessage(errorMessage)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - selectArrData
    func selectArrData(_ startDate: String) {
        activityIndicator.startAnimating()
        NetworkManager.shared.selectArrDataToServer(startDate: startDate ) { [self] result in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let arrData):
                    self.arrChart(arrData)
                case .failure(let error):
                    let errorMessage = NetworkErrorManager.shared.getErrorMessage(error as! NetworkError)
                    self.toastMessage(errorMessage)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func setArrList() {
        for arrDateArray in arrDateArray {
            var arrIdxButton = UIButton()
            var arrTitleButton = UIButton()
            let background = UILabel()
            background.isUserInteractionEnabled = true
            
            arrList.addArrangedSubview(background)
            
            if emergencyList[arrDateArray] != nil {
                // Emergency
                arrIdxButton = setEmergencyIdxButton("E")
                arrTitleButton = setEmergencyTitleButton(arrDateArray)
                emergencyIdxButtonList.append(arrIdxButton)
                emergencyTitleButtonList.append(arrTitleButton)
                emergencyNumber += 1
            } else {
                // ARR
                arrIdxButton = setIdxButton(arrNumber)
                arrTitleButton = setTitleButton(arrDateArray)
                idxButtonList.append(arrIdxButton)
                titleButtonList.append(arrTitleButton)
                arrNumber += 1
            }
            
            setButtonConstraint(background, arrIdxButton, arrTitleButton)
                    
        }
        
        if arrNumber >= 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scrollToBottom()
            }
        }
    }
    
    // MARK: - Chart
    private func arrChart(_ arrData: ArrData) {
        
        activityIndicator.stopAnimating()
        
        if arrData.data.count < 400 {   return  }
        
        let ecgDataConversion = EcgDataConversion()
        let conversionFlag = UserProfileManager.shared.conversionFlag
        
        var arrDataEntry: ChartDataEntry
        arrDataEntries = []
        
        stateIsHidden(isHidden: false)
        setState(bodyType: arrData.bodyStatus,
                 arrType: arrData.type)
        
//        setPreEcgData(ecgDataConversion, arrData)   // 초기 ECG 데이터 설정
        
        for i in 0...arrData.data.count - 1{
            
            if conversionFlag {
                // Conversion Ecg Data
                let conversionData = ecgDataConversion.conversionEcgData(arrData.data[i])
                arrDataEntry = ChartDataEntry(x: Double(i), y: Double(conversionData))
            } else {
                // Real Ecg Data
                arrDataEntry = ChartDataEntry(x: Double(i), y: Double(arrData.data[i]))
            }
        
            arrDataEntries.append(arrDataEntry)
        }
        
        let arrChartDataSet = LineChartDataSet(entries: arrDataEntries, label: "Peak")
        arrChartDataSet.drawCirclesEnabled = false
        arrChartDataSet.setColor(NSUIColor.blue)
        arrChartDataSet.mode = .linear
        arrChartDataSet.drawValuesEnabled = false
        
        chartView.data = LineChartData(dataSet: arrChartDataSet)
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.moveViewToX(0)
    }
    
//    private func setPreEcgData(_ ecgDataConversion: EcgDataConversion, _ arrData: ArrData) {
//        let preEcgData = findPreEcgData(arrData.preEcgData, arrData.data)
//        for i in 0...preEcgData.count - 1 {
//            _ = ecgDataConversion.setPeakData(Int(preEcgData[i]))
//        }
//    }
//    private func findPreEcgData(_ ecgData: [Double], _ arrData: [Double]) -> [Double] {
//        let checkArrData = arrData.prefix(14)
//        
//        var startIndex = 0
//        var arrIndex = 0
//        
//        for index in 0...ecgData.count - 1 {
//            if ecgData[index] == checkArrData[arrIndex] {    arrIndex += 1   }
//            else {  arrIndex = 0    }
//            
//            if arrIndex == 14 {
//                startIndex = index - (arrIndex - 1)
//                break
//            }
//        }
//
//        return Array(ecgData.suffix(from: startIndex))
//    }
    
    private func emergencyChart(_ arrDate: String) {
        arrDataEntries = []
        
        stateIsHidden(isHidden: false)
        setEmergencyText(state: "profile3_emergency".localized(), location: String(emergencyList[arrDate] ?? "empty"))
        
        for i in 0...499 {
            let arrDataEntry = ChartDataEntry(x: Double(i), y: 0.0)
            arrDataEntries.append(arrDataEntry)
        }
        
        let arrChartDataSet = LineChartDataSet(entries: arrDataEntries, label: "Peak")
        arrChartDataSet.drawCirclesEnabled = false
        arrChartDataSet.setColor(NSUIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0))
        arrChartDataSet.mode = .linear
        arrChartDataSet.drawValuesEnabled = false
        
        chartView.data = LineChartData(dataSet: arrChartDataSet)
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
        chartView.moveViewToX(0)
    }
    
    private func setState(bodyType: String, arrType: String){
        arrStateLabel.text = "arrType".localized()
        bodyState.text = getBodyType(bodyType)
        arrState.text = getArrType(arrType)
    }
    
    private func getArrType(_ arrType: String ) -> String {
        switch (arrType){
        case "fast":
            return "typeFastArr".localized()
        case "slow":
            return "typeSlowArr".localized()
        case "irregular":
            return "typeHeavyArr".localized()
        default:    // "arr"
            return "typeArr".localized()
        }
    }
    
    private func getBodyType(_ bodyType: String ) -> String {
        switch (bodyType){
        case "E":
            return "type_Exercise".localized()
        case "S":
            return "type_Sleep".localized()
        default:    // "R"
            return "type_Rest".localized()
        }
    }
    
    // MARK: -    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) {
        guard let inputDate = dateFormatter.date(from: date) else { return }

        let dayValue = shouldAdd ? day : -day

        if let arrTargetDate = calendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                targetYear = "\(year)"
                targetMonth = "\(month)"
                targetDay = "\(day)"
                
                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
                setTomorrow(targetDate)
            }
        }
    }
    
    func setTomorrow(_ date: String) {
        guard let inputDate = dateFormatter.date(from: date) else { return }
        
        if let arrTargetDate = calendar.date(byAdding: .day, value: 1, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                tomorrowYear = "\(year)"
                tomorrowMonth = "\(month)"
                tomorrowDay = "\(day)"
                
                tomorrowDate = "\(tomorrowYear)-\(tomorrowMonth)-\(tomorrowDay)"
            }
        }
    }
    
    // MARK: - Arr Button Event
    func setIdxButton(_ idx: Int) -> UIButton {
        let arrIdxButton = UIButton()
        
        arrIdxButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrIdxButton.titleLabel?.textAlignment = .center
        
        arrIdxButton.setTitle("\(idx)", for: .normal)
        arrIdxButton.setTitleColor(.white, for: .normal)
        
        arrIdxButton.backgroundColor = .black
        
        arrIdxButton.layer.cornerRadius = 10
        arrIdxButton.layer.borderWidth = 3
        arrIdxButton.clipsToBounds = true
        arrIdxButton.tag = arrNumber
        
        arrIdxButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return arrIdxButton
    }
    
    func setTitleButton(_ title: String) -> UIButton {
        let arrTitleButton = UIButton()
        
        arrTitleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrTitleButton.titleLabel?.textAlignment = .center
        
        arrTitleButton.setTitle("\(changeTimeFormat(title, TIME_FLAG))", for: .normal)
        arrTitleButton.setTitleColor(.black, for: .normal)
        
        arrTitleButton.setBackgroundColor(.white, for: .normal)
        
        arrTitleButton.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        arrTitleButton.layer.cornerRadius = 10
        arrTitleButton.layer.borderWidth = 3
        arrTitleButton.tag = arrNumber
        
        arrTitleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return arrTitleButton
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        selectArrData(arrDateArray[sender.tag - 1])
        updateButtonColor(sender.tag - 1)
    }
    
    func updateButtonColor(_ tag: Int) {
        // IDX
        for button in idxButtonList {
            if idxButtonList[tag] == button {
                button.backgroundColor = SELECTED_COLOR
                button.layer.borderColor = SELECTED_COLOR.cgColor
            } else {
                button.backgroundColor = BLACK_COLOR
                button.layer.borderColor = BLACK_COLOR.cgColor
            }
        }
        // TITLE
        for button in titleButtonList {
            if titleButtonList[tag] == button {
                button.layer.borderColor = SELECTED_COLOR.cgColor
            } else {
                button.layer.borderColor = DESELECTED_COLOR.cgColor
            }
        }
        allDeSelected(idxList: &emergencyIdxButtonList, titleList: &emergencyTitleButtonList)
    }
    
    // MARK: - Emergency Button Event
    func setEmergencyIdxButton(_ number: String) -> UIButton {
        let arrIdxButton = UIButton()
        
        arrIdxButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrIdxButton.titleLabel?.textAlignment = .center
        
        arrIdxButton.setTitle("\(number)", for: .normal)
        arrIdxButton.setTitleColor(.white, for: .normal)
        
        arrIdxButton.backgroundColor = .black
        
        arrIdxButton.layer.cornerRadius = 10
        arrIdxButton.layer.borderWidth = 3
        arrIdxButton.clipsToBounds = true
        arrIdxButton.tag = emergencyNumber
        
        arrIdxButton.addTarget(self, action: #selector(emergencyButtonTapped(_:)), for: .touchUpInside)
        
        return arrIdxButton
    }
    func setEmergencyTitleButton(_ title: String) -> UIButton {
        let arrTitleButton = UIButton()
        
        arrTitleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrTitleButton.titleLabel?.textAlignment = .center
        
        arrTitleButton.setTitle("\(changeTimeFormat(title, TIME_FLAG))", for: .normal)
        arrTitleButton.setTitleColor(.black, for: .normal)
        
        arrTitleButton.setBackgroundColor(.white, for: .normal)
        
        arrTitleButton.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        arrTitleButton.layer.cornerRadius = 10
        arrTitleButton.layer.borderWidth = 3
        arrTitleButton.tag = emergencyNumber
        
        arrTitleButton.addTarget(self, action: #selector(emergencyButtonTapped(_:)), for: .touchUpInside)
        return arrTitleButton
    }
    
    @objc func emergencyButtonTapped(_ sender: UIButton) {
        emergencyChart(sender.titleLabel?.text ?? "")
        updateEmergencyButtonColor(sender.tag - 1)
    }
    
    func updateEmergencyButtonColor(_ tag: Int) {
        // IDX
        for button in emergencyIdxButtonList {
            if emergencyIdxButtonList[tag] == button {
                button.backgroundColor = HEARTATTACK_COLOR
                button.layer.borderColor = HEARTATTACK_COLOR.cgColor
            } else {
                button.backgroundColor = BLACK_COLOR
                button.layer.borderColor = BLACK_COLOR.cgColor
            }
        }
        // TITLE
        for button in emergencyTitleButtonList {
            if emergencyTitleButtonList[tag] == button {
                button.layer.borderColor = HEARTATTACK_COLOR.cgColor
            } else {
                button.layer.borderColor = DESELECTED_COLOR.cgColor
            }
        }
        
        allDeSelected(idxList: &idxButtonList, titleList: &titleButtonList)
    }
    
    func allDeSelected(idxList: inout [UIButton], titleList: inout [UIButton]) {
        for button in idxList {
            button.backgroundColor = BLACK_COLOR
            button.layer.borderColor = BLACK_COLOR.cgColor
        }
        for button in titleList {
            button.layer.borderColor = DESELECTED_COLOR.cgColor
        }
    }
    
    // MARK: -
    func setButtonConstraint(_ background: UILabel, _ arrIdxButton: UIButton, _ arrTitleButton: UIButton) {
        
        background.snp.makeConstraints { make in
            make.left.right.equalTo(arrList)
            make.height.equalTo(50)
        }
        
        background.addSubview(arrIdxButton)
        arrIdxButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(background)
            make.width.equalTo(screenWidth / 7.0)
        }
        
        background.addSubview(arrTitleButton)
        arrTitleButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(background)
            make.left.equalTo(arrIdxButton.snp.right).offset(10)
            make.right.equalTo(background).offset(-10)
        }
        
    }
    
    func changeTimeFormat(_ dateString: String, _ isYearCheck: Bool) -> String {
        if isYearCheck {
            var dateComponents = dateString.components(separatedBy: "-")
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            
            return dateComponents.joined(separator: "-")
        } else {
            let splitDate = dateString.split(separator: " ")    // 2023-11-09 9:16:18
            var dateComponents = splitDate[1].components(separatedBy: ":")
            let date = changeTimeFormat(String(splitDate[0]), YEAR_FLAG)
            
            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            
            return "\(date) \(dateComponents.joined(separator: ":"))"
        }
    }
    
    func reconstructedPath(_ path: URL) -> String? {
        
        if let documentsIndex = path.pathComponents.firstIndex(of: "arrECGData") {
            let desiredPathComponents = path.pathComponents[(documentsIndex + 1)...]
            return desiredPathComponents.joined(separator: "/")
        }
        return nil
    }
    
    func resetArrList() {
        for  subview in self.arrList.subviews
        {
            subview.removeFromSuperview()
        }
    }
    
    func stateIsHidden(isHidden: Bool) {
        bodyState.isHidden = isHidden
        bodyStateLabel.isHidden = isHidden
        arrState.isHidden = isHidden
        arrStateLabel.isHidden = isHidden
    }
    
    func setEmergencyText(state: String, location: String) {
        arrState.text = "\(location)"
        arrStateLabel.text = "emergencyLocation".localized()
        bodyState.isHidden = true
        bodyStateLabel.isHidden = true
    }
    
    func scrollToBottom() {
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height), animated: true)
    }
    
    func initArray() {
        
        resetArrList()
        dissmissCalendar()
        stateIsHidden(isHidden: true)
        
        chartView.clear()
        
        arrDateArray = []
        arrFilePath = []
        arrDataEntries = []
        
        idxButtonList = []
        titleButtonList = []
        arrNumber = 1
        
        emergencyList = [:]
        emergencyIdxButtonList = []
        emergencyTitleButtonList = []
        emergencyNumber = 1
    }
    
    func toastMessage(_ message: String) {
        // chartView의 중앙 좌표 계산
        let chartViewCenterX = chartView.frame.size.width / 2
        let chartViewCenterY = chartView.frame.size.height / 2

        // 토스트 컨테이너의 크기
        let containerWidth: CGFloat = chartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // 토스트 컨테이너가 chartView 중앙에 오도록 위치 조정
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))

    }
    
    private func setCalendarClosure() {
        fsCalendar.didSelectDate = { [self] date in
            
            let startDate = MyDateTime.shared.getDateFormat().string(from: date)
            let endDate = MyDateTime.shared.dateCalculate(startDate, 1, true)

            todayDisplay.text = changeTimeFormat(startDate, YEAR_FLAG)
            initArray()
            getArrList(email, startDate, endDate)
            
            fsCalendar.isHidden = true
            chartView.isHidden = false
        }
    }
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            chartView.isHidden = false
        }
    }
    
    // MARK: - addViews
    private func addViews() {
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(4.5 / (4.5 + 5.5))
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(chartView)
        }
        
        view.addSubview(arrState)
        arrState.snp.makeConstraints { make in
            make.right.equalTo(safeAreaView).offset(-20)
            make.top.equalTo(chartView.snp.bottom).offset(10)
        }
        
        view.addSubview(arrStateLabel)
        arrStateLabel.snp.makeConstraints { make in
            make.right.equalTo(arrState.snp.left).offset(-10)
            make.top.equalTo(arrState)
        }
        
        view.addSubview(bodyState)
        bodyState.snp.makeConstraints { make in
            make.right.equalTo(arrStateLabel.snp.left).offset(-10)
            make.top.equalTo(arrStateLabel)
        }
        
        view.addSubview(bodyStateLabel)
        bodyStateLabel.snp.makeConstraints { make in
            make.right.equalTo(bodyState.snp.left).offset(-10)
            make.top.equalTo(bodyState)
        }
                
        view.addSubview(listBackground)
        listBackground.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(50)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        listBackground.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
            make.top.equalTo(listBackground)
            make.centerX.equalTo(listBackground)
        }
        
        listBackground.addSubview(calendarButton)
        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(todayDisplay)
            make.left.equalTo(todayDisplay.snp.left).offset(-30)
        }
        
        listBackground.addSubview(yesterdayButton)
        yesterdayButton.snp.makeConstraints { make in
            make.left.equalTo(listBackground).offset(10)
            make.centerY.equalTo(todayDisplay)
        }
        
        listBackground.addSubview(tomorrowButton)
        tomorrowButton.snp.makeConstraints { make in
            make.right.equalTo(listBackground).offset(-10)
            make.centerY.equalTo(todayDisplay)
        }
        
        listBackground.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(todayDisplay.snp.bottom).offset(20)
            make.left.equalTo(listBackground).offset(10)
            make.right.equalTo(listBackground)
            make.bottom.equalTo(listBackground).offset(-10)
        }
        
        scrollView.addSubview(arrList)
        arrList.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(scrollView)
        }
        
        view.addSubview(fsCalendar)
        fsCalendar.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(chartView)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }
}
