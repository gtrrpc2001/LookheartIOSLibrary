import Foundation
import UIKit
import DGCharts

@available(iOS 13.0, *)
class BarChartVC : UIViewController {
    
    private var email = String()
    private var chartType: ChartType = .ARR
    
    enum DateType: Int {
        case DAY = 1
        case WEEK = 2
        case MONTH = 3
        case YEAR = 4
    }
    
    struct HourlyDataStruct {
        var arrCnt: Double = 0.0
        var step: Double = 0.0
        var distance: Double = 0.0
        var cal: Double = 0.0
        var activityCal: Double = 0.0
        
        mutating func updateData(_ data: HourlyData) {
            arrCnt += data.toDouble(data.arrCnt)
            activityCal += data.toDouble(data.activityCal)
            cal += data.toDouble(data.cal)
            step += data.toDouble(data.step)
            distance += data.toDouble(data.distance)
        }
    }

    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End
    
    // ----------------------------- 상수 ------------------- //
    private let weekDays = ["Monday".localized(), "Tuesday".localized(), "Wednesday".localized(), "Thursday".localized(), "Friday".localized(), "Saturday".localized(), "Sunday".localized()]
    
    private let YESTERDAY_BUTTON_FLAG = 1, TOMORROW_BUTTON_FLAG = 2
    private let DAY_FLAG = 1, WEEK_FLAG = 2, MONTH_FLAG = 3, YEAR_FLAG = 4
    
    private let PLUS_DATE = true, MINUS_DATE = false
    // 상수 END
    
    // ----------------------------- UI ------------------- //
    // 보여지는 변수
    private var firstGoal = 0, secondGoal = 0   // 목표값
    
    // UI VAR END
    
    // ----------------------------- DATE ------------------- //
    // 날짜 변수
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var calendar = Calendar.current
    private var startDate = String()
    // DATE END
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var currentButtonFlag: DateType = .DAY   // 현재 버튼 플래그가 저장되는 변수
    private var buttonList:[UIButton] = []
    // CHART END
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    //    ----------------------------- FSCalendar -------------------    //
    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
        $0.isHidden = true
    }
    
    //    ----------------------------- Chart -------------------    //
    // Cal, Step : $0.xAxis.centerAxisLabelsEnabled = true
    private lazy var barChartView = BarChartView().then {
        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
        $0.noDataText = ""
        $0.xAxis.enabled = true
        $0.xAxis.granularity = 1
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.leftAxis.granularityEnabled = true
        $0.leftAxis.granularity = 1.0
        $0.leftAxis.axisMinimum = 0
        $0.rightAxis.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = true
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
    }
    
    private let bottomContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    // CAL, STEP
    private lazy var doubleGraphBottomContents = UIStackView(arrangedSubviews: [topBackground, bottomBackground]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually // default
        $0.alignment = .fill // default
        $0.spacing = 5
    }
    
    // ARR
    private lazy var singleGraphBottomContents = UIStackView(arrangedSubviews: [singleContentsLabel, singleContentsValueLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - top Contents
    private lazy var dayButton = UIButton().then {
        $0.setTitle ("fragment_day".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.isSelected = true
        
        $0.tag = DAY_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var weekButton = UIButton().then {
        $0.setTitle ("fragment_week".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = WEEK_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var monthButton = UIButton().then {
        $0.setTitle ("fragment_month".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
                
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = MONTH_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var yearButton = UIButton().then {
        $0.setTitle ("fragment_year".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = YEAR_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - middle Contents
    private lazy var todayDisplay = UILabel().then {
        $0.text = "-"
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
    
    private lazy var calendarButton = UIButton(type: .custom).then {
        $0.setImage(calendarImage, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    //    ----------------------------- ARR -------------------    //
    private let singleContentsLabel = UILabel().then {
        $0.text = "arrTimes".localized()
        $0.numberOfLines = 2
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let singleContentsValueLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    //    ----------------------------- STEP, CAL -------------------    //
    private lazy var topBackground = UIStackView(arrangedSubviews: [topTitleLabel, topProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private lazy var bottomBackground = UIStackView(arrangedSubviews: [bottomTitleLabel, bottomProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    private let topProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.PROGRESSBAR_RED
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    private let bottomProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.PROGRESSBAR_BLUE
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let topTitleLabel = UILabel().then {
        $0.text = "summaryStep".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomTitleLabel = UILabel().then {
        $0.text = "distance".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
        
    private let topValue = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomValue = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let topValueProcent = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomValueProcent = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomLine = UILabel().then {   $0.backgroundColor = .lightGray }
    private let bottomValueContents = UILabel()
    
    // MARK: - Button Event
    @objc func shiftDate(_ sender: UIButton) {
        
        let targetDate = setStartDate(startDate, sender.tag)
        let endDate = setEndDate(startDate)
        
        getDataToServer(targetDate, endDate)
        setDisplayDateText(targetDate, endDate)
    }
        
    @objc func selectDayButton(_ sender: UIButton) {
        
        var targetDate = startDate
        
        switch (sender.tag) {
        case DAY_FLAG:
            currentButtonFlag = .DAY
        case WEEK_FLAG:
            currentButtonFlag = .WEEK
            targetDate = MyDateTime.shared.dateCalculate(startDate, findMonday(targetDate), MINUS_DATE)
        case MONTH_FLAG:
            currentButtonFlag = .MONTH
            targetDate = String(startDate.prefix(8)) + "01"
        case YEAR_FLAG:
            currentButtonFlag = .YEAR
            targetDate = String(startDate.prefix(4)) + "-01-01"
        default:
            break
        }
        
        let endDate = setEndDate(targetDate)

        getDataToServer(targetDate, endDate)
        setDisplayDateText(targetDate, endDate)
        setButtonColor(sender)
    }
    
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        barChartView.isHidden = !barChartView.isHidden
    }
    
    private func buttonEnable() {
        yesterdayButton.isEnabled = !yesterdayButton.isEnabled
        tomorrowButton.isEnabled = !tomorrowButton.isEnabled
        dayButton.isEnabled = !dayButton.isEnabled
        weekButton.isEnabled = !weekButton.isEnabled
        monthButton.isEnabled = !monthButton.isEnabled
        yearButton.isEnabled = !yearButton.isEnabled
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        setCalendarClosure()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        dissmissCalendar()
    }
    
    public func refreshView(_ type: ChartType) {
        
        chartType = type
        currentButtonFlag = .DAY
        
        startDate = MyDateTime.shared.getCurrentDateTime(.DATE)
        let endDate = MyDateTime.shared.dateCalculate(startDate, 1, PLUS_DATE)
            
        getDataToServer(startDate, endDate)
    
        setUI()
        setDisplayDateText(startDate, endDate)
        setButtonColor(dayButton)
    }
    
    func initVar() {
                
        buttonList = [dayButton, weekButton, monthButton, yearButton]

    }
    
    // MARK: - CHART FUNC
    private func viewChart(_ hourlyDataList: [HourlyData], _ startDate: String) {
        
        let dataDict = groupDataByDate(hourlyDataList)
        
        let sortedDate = sortedKeys(dataDict)
        
        let chartDataSet = getChartDataSet(sortedDate, dataDict, startDate)
        
        setChart(chartData: BarChartData(dataSets: chartDataSet.1), timeTable: chartDataSet.0, labelCnt: chartDataSet.0.count)
        
        activityIndicator.stopAnimating()
        
    }
    
    private func getChartDataSet(_ sortedDate: [String], _ dataDict: [String : HourlyDataStruct], _ startDate: String) -> ([String], [BarChartDataSet]) {
        
        switch (chartType) {
        case .CALORIE, .STEP:
            // double graph
            let entries = createDoubleGraphEntries(sortedDate, dataDict, startDate)
            
            let label1 = chartType == .CALORIE ? "summaryTCal".localized() : "step".localized()
            let label2 = chartType == .CALORIE ? "summaryECal".localized() : "distanceM".localized()
            
            let dataSet1 =  chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: BarChartDataSet(entries: entries.1, label: label1))
            let dataSet2 =  chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: BarChartDataSet(entries: entries.2, label: label2))
            
            let dataSets: [BarChartDataSet] = [dataSet1, dataSet2]
            
            return (entries.0, dataSets)
            
        default:
            // single graph
            let entries = createSingleGraphEntries(sortedDate, dataDict, startDate)
            let dataSet =  chartDataSet(color: NSUIColor.MY_RED, chartDataSet: BarChartDataSet(entries: entries.1, label: "arr".localized()))
            return (entries.0, [dataSet])
        }
    }
    
    private func createDoubleGraphEntries(_ sortedDate: [String], _ dataDict: [String : HourlyDataStruct], _ startDate: String) -> ([String], [BarChartDataEntry], [BarChartDataEntry]) {
        
        let buttonFlag = currentButtonFlag == .WEEK || currentButtonFlag == .YEAR
        var findDate = currentButtonFlag == .YEAR ? String(startDate.prefix(7)) : startDate
        
        let index = getChartIndexCount(sortedDate)
        var weekAndYearIdx = 0
        
        var entries1 = [BarChartDataEntry]()
        var entries2 = [BarChartDataEntry]()
        
        var sumValue1 = 0
        var sumValue2 = 0
        
        var timeTable: [String] = []
        
        for i in 0..<index {
            let time = getTime(buttonFlag ? String(i) : sortedDate[i])
            var yValue1 = 0.0
            var yValue2 = 0.0
            
            if index != sortedDate.count {
                // 고정 index WEEK(7), YEAR(12) 예외 처리
                if dataDict.keys.contains(findDate) {
                    (yValue1, yValue2) = getYValues(for: sortedDate, at: weekAndYearIdx, with: dataDict)

                    weekAndYearIdx += 1
                }
                
                findDate = currentButtonFlag == .YEAR ? getYearDate(findDate) : MyDateTime.shared.dateCalculate(findDate, 1, PLUS_DATE)
            } else {
                (yValue1, yValue2) = getYValues(for: sortedDate, at: i, with: dataDict)
            }
            
            let entry1 = BarChartDataEntry(x: Double(i), y: yValue1)
            let entry2 = BarChartDataEntry(x: Double(i), y: yValue2)
            
            entries1.append(entry1)
            entries2.append(entry2)
            
            sumValue1 += Int(yValue1)
            sumValue2 += Int(yValue2)
            
            timeTable.append(time)
            
        }
        
        setDoubleGraphUI(sumValue1, sumValue2)
        
        return (timeTable, entries1, entries2)
    }
    
    
    private func getYValues(for sortedDate: [String], at index: Int, with dataDict: [String : HourlyDataStruct]) -> (Double, Double) {
        let checkType = chartType == .CALORIE
        let yValue1 = checkType ? dataDict[sortedDate[index]]?.cal ?? 0 :
                                  dataDict[sortedDate[index]]?.step ?? 0
        let yValue2 = checkType ? dataDict[sortedDate[index]]?.activityCal ?? 0 :
                                  dataDict[sortedDate[index]]?.distance ?? 0
        return (yValue1, yValue2)
    }
    
    private func createSingleGraphEntries(_ sortedDate: [String], _ dataDict: [String : HourlyDataStruct], _ startDate: String) -> ([String], [BarChartDataEntry]) {
        
        // ButtonFlag에 따라 x축에 들어가는 time String 설정
        let buttonFlag = currentButtonFlag == .WEEK || currentButtonFlag == .YEAR
        
        // findDate : Week(7), Year(12)는 고정 인덱스를 가지고 있으므로 데이터가 없을 경우를 알기 위한 날짜 변수
        // Year의 경우 Dictionary에 2024-01 형식(prefix(7))
        var findDate = currentButtonFlag == .YEAR ? String(startDate.prefix(7)) : startDate
        
        // Week(7), Year(12)는 고정 인덱스
        let index = getChartIndexCount(sortedDate)
        // sortedDate idx : 값이 있고 값을 넣었을 경우에만 +1
        var weekAndYearIdx = 0
        
        var entries = [BarChartDataEntry]()
        var timeTable: [String] = []
        var sumValue = 0
        
        for i in 0..<index {
            let time = getTime(buttonFlag ? String(i) : sortedDate[i])
            var yValue = 0.0
            
            if index != sortedDate.count {
                // 고정 index WEEK(7), YEAR(12) 예외 처리
                if dataDict.keys.contains(findDate) {
                    yValue = dataDict[sortedDate[weekAndYearIdx]]?.arrCnt ?? 0
                    weekAndYearIdx += 1
                }
                
                findDate = currentButtonFlag == .YEAR ? getYearDate(findDate) : MyDateTime.shared.dateCalculate(findDate, 1, PLUS_DATE)
            } else {
                yValue = dataDict[sortedDate[i]]?.arrCnt ?? 0
            }
            
            let entry = BarChartDataEntry(x: Double(i), y: yValue)
            
            entries.append(entry)
            timeTable.append(time)
            sumValue += Int(yValue)
        }
        
        setSingleGraphUI(sumValue)
        
        return (timeTable, entries)
    }
    
    private func getYearDate(_ date : String) -> String {
        let year = String(date.prefix(5))
        let month = (Int(date.suffix(2)) ?? 0) + 1
        return month > 9 ? year + String(month) : year + "0" + String(month)
    }
    
    private func getChartIndexCount(_ date: [String]) -> Int {
        switch (currentButtonFlag) {
        case .WEEK:
            return 7
        case .YEAR:
            return 12
        default:
            return date.count
        }
    }
    
    private func getTime(_ time: String) -> String{
        switch (currentButtonFlag) {
        case .DAY:
            return time
        case .YEAR:
            return String((Int(time) ?? 0) + 1)
        case .WEEK:
            return weekDays[Int(time) ?? 0]
        case .MONTH:
            return String(time.suffix(2)).first == "0" ? String(time.suffix(1)) : String(time.suffix(2))
        }
    }
    
    private func groupDataByDate(_ dataArray: [HourlyData]) -> [String : HourlyDataStruct] {
        
        var hourlyDataDict:[String : HourlyDataStruct] = [:]
        
        for data in dataArray {
            let dateKey = getKeyForGrouping(for: data)
            var dataStruct = hourlyDataDict[dateKey, default: HourlyDataStruct()]
            dataStruct.updateData(data)
            hourlyDataDict[dateKey] = dataStruct
            
        }
        return hourlyDataDict
    }
    
    private func getKeyForGrouping(for data: HourlyData) -> String {
        switch currentButtonFlag {
        case .DAY:
            return data.hour
        case .YEAR:
            return String(data.date.prefix(7))
        default:
            return data.date
        }
    }

    private func sortedKeys(_ dict : [String : HourlyDataStruct]) -> [String] {
        switch currentButtonFlag {
        case .DAY:
            return dict.keys.map { Int($0) ?? 0 }.sorted().map { String($0) } // [Int] 정렬 -> [String]
        default:
            return dict.keys.sorted()   // 사전식(lexicographical) 정렬
        }
    }
    
    private func getDataToServer(_ startDate: String, _ endDate: String) {
        
        activityIndicator.startAnimating()
        
        initUI()

        NetworkManager.shared.getHourlyDataToServer(startDate: startDate, endDate: endDate) { [self] result in
            switch(result){
            case .success(let hourlyDataList):
                
                viewChart(hourlyDataList, startDate)
                
            case .failure(let error):
                
                let errorMessage = NetworkErrorManager.shared.getErrorMessage(error as! NetworkError)
                toastMessage(errorMessage)
                activityIndicator.stopAnimating()

            }
        }
        
    }
    
    func chartDataSet(color: NSUIColor, chartDataSet: BarChartDataSet) -> BarChartDataSet {
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = chartType == .ARR ? true : false
        
        if chartType == .ARR {
            chartDataSet.valueFormatter = CombinedValueFormatter()
        }
        
        return chartDataSet
    }
    
    func setChart(chartData: BarChartData, timeTable: [String], labelCnt: Int) {
        let monthFlag = currentButtonFlag == .MONTH
        let labelCount = monthFlag ? 14.3 : Double(labelCnt)
        let moveToX = monthFlag ? Double(labelCnt) : 0.0
        
        configureBarChartSettings(chartData: chartData, labelCnt: labelCnt)
        
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        barChartView.setVisibleXRangeMaximum(labelCount)
        barChartView.xAxis.setLabelCount(labelCnt, force: false)
        barChartView.data?.notifyDataChanged()
        barChartView.notifyDataSetChanged()
        barChartView.moveViewToX(moveToX)
        chartZoomOut()
    }
    
    private func configureBarChartSettings(chartData: BarChartData, labelCnt: Int) {
        switch (chartType) {
        case .CALORIE, .STEP:
            
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
            
            chartData.barWidth = barWidth
            
            barChartView.xAxis.axisMinimum = Double(0)
            barChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(labelCnt)  // group count : 2
            chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
            
            barChartView.xAxis.centerAxisLabelsEnabled = true
            
        default:
            
            let defaultBarWidth = 0.85 // 기본 바 너비
            chartData.barWidth = defaultBarWidth
            
            barChartView.xAxis.resetCustomAxisMin()
            barChartView.xAxis.resetCustomAxisMax()

            barChartView.xAxis.centerAxisLabelsEnabled = false
        }
    }
    
    // MARK: - DATE FUNC
    func setStartDate(_ date: String, _ tag : Int) -> String {
        
        let flag = tag == TOMORROW_BUTTON_FLAG ? PLUS_DATE : MINUS_DATE
        
        switch (currentButtonFlag) {
        case .DAY:
            startDate = MyDateTime.shared.dateCalculate(date, 1, flag)
            return startDate
        case .WEEK:
            startDate = MyDateTime.shared.dateCalculate(date, 7, flag)
            return MyDateTime.shared.dateCalculate(startDate, findMonday(startDate), MINUS_DATE)
        case .MONTH:
            startDate = MyDateTime.shared.dateCalculate(date, 1, flag, .month)
            return String(startDate.prefix(8)) + "01"
        case .YEAR:
            startDate = MyDateTime.shared.dateCalculate(date, 1, flag, .year)
            return String(startDate.prefix(4)) + "-01-01"
        }
    }
    
    func setEndDate(_ date: String) -> String {
        switch (currentButtonFlag) {
        case .DAY:
            return MyDateTime.shared.dateCalculate(date, 1, PLUS_DATE)
        case .WEEK:
            return MyDateTime.shared.dateCalculate(date, 7, PLUS_DATE)
        case .MONTH:
            let numDay = MyDateTime.shared.findNumDay(date) ?? 30
            return MyDateTime.shared.dateCalculate(date, numDay, PLUS_DATE)
        case .YEAR:
            let lastDate = String(date.prefix(4)) + "-12-01"
            let numDay = MyDateTime.shared.findNumDay(lastDate) ?? 30
            return MyDateTime.shared.dateCalculate(lastDate, numDay, PLUS_DATE)
        }
    }
    
    func findMonday(_ startDate: String) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let weekdaySymbols = calendar.weekdaySymbols
        
        guard let weekdayName = findWeekday(startDate),
              let weekdayIndex = weekdaySymbols.firstIndex(of: weekdayName) else {
            return 0
        }
        // 'calendar.firstWeekday'로 주의 시작 요일을 고려해 인덱스 조정
        // 그레고리안 캘린더에서 'firstWeekday'는 일반적으로 1(일요일)
        // 월요일을 0으로 만들기 위해, 인덱스에서 1을 빼고, 7로 나눈 나머지를 계산
        let mondayIndex = (weekdayIndex + 7 - calendar.firstWeekday) % 7
        return mondayIndex
    }
    
    func findWeekday(_ startDate: String) -> String? {
        let splitDate = startDate.split(separator: "-")
        var dateComponents = DateComponents()
        dateComponents.year = Int(splitDate[0])
        dateComponents.month = Int(splitDate[1])
        dateComponents.day = Int(splitDate[2])
        
        let calendar = Calendar.current
        
        if let specificDate = calendar.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 로케일 설정
            dateFormatter.dateFormat = "EEEE" // 요일의 전체 이름
            let weekdayName = dateFormatter.string(from: specificDate)

            return weekdayName
        } else {
            return nil
        }
    }
    
    private func setCalendarClosure() {
        fsCalendar.didSelectDate = { [self] date in
                        
            startDate = MyDateTime.shared.getDateFormat().string(from: date)
            
            switch (currentButtonFlag) {
            case .DAY:
                selectDayButton(dayButton)
            case .WEEK:
                selectDayButton(weekButton)
            case .MONTH:
                selectDayButton(monthButton)
            case .YEAR:
                selectDayButton(yearButton)
            }
            
            fsCalendar.isHidden = true
            barChartView.isHidden = false
        }
    }
    
    // MARK: - UI
    private func setDisplayDateText(_ startDate: String, _ endDate: String) {
        var displayText = startDate
        let startDateText = MyDateTime.shared.changeDateFormat(startDate, false)
        let endDateText = MyDateTime.shared.changeDateFormat(MyDateTime.shared.dateCalculate(endDate, 1, false), false)
        
        switch (currentButtonFlag) {
        case .DAY:
            displayText = startDate
        case .WEEK:
            displayText = "\(startDateText) ~ \(endDateText)"
        case .MONTH:
            displayText = "\(startDate.prefix(7))"
        case .YEAR:
            displayText = "\(startDate.prefix(4))"
        }
        
        todayDisplay.text = displayText
    }
    
    func toastMessage(_ message: String) {
        // chartView의 중앙 좌표 계산
        let chartViewCenterX = barChartView.frame.size.width / 2
        let chartViewCenterY = barChartView.frame.size.height / 2

        // 토스트 컨테이너의 크기
        let containerWidth: CGFloat = barChartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // 토스트 컨테이너가 chartView 중앙에 오도록 위치 조정
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))

    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func initUI() {
        barChartView.clear()
        
        singleContentsValueLabel.text = "0"
        
        topValue.text = "-"
        bottomValue.text = "-"
        
        topValueProcent.text = "-"
        bottomValueProcent.text = "-"
        
        topProgress.progress = 0
        bottomProgress.progress = 0
                
        dissmissCalendar()
    }
    
    private func setUI() {
        switch (chartType) {
        case .CALORIE, .STEP:
            // double graph
            doubleGraphBottomContents.isHidden = false
            singleGraphBottomContents.isHidden = true
            
            let type = chartType == .CALORIE
            topTitleLabel.text = (type ? "tCalTitle".localized() : "summaryStep".localized())
            bottomTitleLabel.text = (type ? "eCalTitle".localized() : "distance".localized())
            
            
            firstGoal = type ? UserProfileManager.shared.targetCalorie :
                               UserProfileManager.shared.targetStep
            secondGoal = type ? UserProfileManager.shared.targetActivityCalorie :
                                UserProfileManager.shared.targetDistance
                        
        default:
            // single graph
            singleGraphBottomContents.isHidden = false
            doubleGraphBottomContents.isHidden = true
        }
    }
    
    private func setSingleGraphUI(_ cnt : Int) {
        singleContentsValueLabel.text = String(cnt)
    }
    
    private func setDoubleGraphUI(_ value1 : Int, _ value2 : Int) {
        
        let label1 = chartType == .CALORIE ? "eCalValue2".localized() : "stepValue2".localized()
        let label2 = chartType == .CALORIE ? "eCalValue2".localized() : "distanceValue2".localized()
        let dayCount = getDayCount(for: currentButtonFlag)
        
        // Progress
        let firstGoalProgress = Double(value1) / Double(firstGoal * dayCount)
        topProgress.progress = Float(firstGoalProgress)
        
        let secondGoalProgress = chartType == .STEP ? (Double(value2) / 1000.0) / Double(secondGoal * dayCount) : Double(value2) / Double(secondGoal * dayCount)
        bottomProgress.progress = Float(secondGoalProgress)
        
        // procent
        topValueProcent.text = String(Int(firstGoalProgress * 100)) + "%"
        bottomValueProcent.text = String(Int(secondGoalProgress * 100)) + "%"
        
        // text
        topValue.text = String(value1) + " " + label1
        bottomValue.text = chartType == .STEP ? String(Double(value2) / 1000.0) + " " + label2:
                                                String(value2) + " " + label2
    }
    
    private func getDayCount(for buttonFlag: DateType) -> Int {
        switch buttonFlag {
        case .DAY: return 1
        case .WEEK: return 7
        case .MONTH: return 30
        case .YEAR: return 365
        }
    }
    
    func chartZoomOut() {
        for _ in 0..<20 {
            barChartView.zoomOut()
        }
    }
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            barChartView.isHidden = false
        }
    }
    
    // MARK: - addViews
    private func addViews() {
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(barChartView)
        }
        
        view.addSubview(bottomContents)
        bottomContents.snp.makeConstraints { make in
            make.top.equalTo(barChartView.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        bottomContents.addSubview(topContents)
        topContents.snp.makeConstraints { make in
            make.top.equalTo(bottomContents).offset(10)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        bottomContents.addSubview(middleContents)
        middleContents.snp.makeConstraints { make in
            make.top.equalTo(topContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        // ARR Contents StackView
        bottomContents.addSubview(singleGraphBottomContents)
        singleGraphBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.right.bottom.equalTo(bottomContents)
        }
        
        // CAL, STEP Contents StackView
        bottomContents.addSubview(doubleGraphBottomContents)
        doubleGraphBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(20)
            make.right.equalTo(safeAreaView.snp.centerX).offset(40)
            make.bottom.equalTo(bottomContents).offset(-5)
        }
        
        // --------------------- topContents --------------------- //
        
        topContents.addSubview(weekButton)
        weekButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.right.equalTo(topContents.snp.centerX).offset(-10)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneFourthWidth - 20)
        }
        
        topContents.addSubview(monthButton)
        monthButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(topContents.snp.centerX).offset(10)
        }
        
        topContents.addSubview(dayButton)
        dayButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(safeAreaView).offset(10)
        }
                
        topContents.addSubview(yearButton)
        yearButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.right.equalTo(safeAreaView).offset(-10)
        }
        
        // --------------------- middleContents --------------------- //
        middleContents.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.centerX.equalTo(middleContents).offset(5)
        }
        
        middleContents.addSubview(yesterdayButton)
        yesterdayButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(tomorrowButton)
        tomorrowButton.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(middleContents)
        }
     
        middleContents.addSubview(calendarButton)
        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(todayDisplay)
            make.left.equalTo(todayDisplay.snp.left).offset(-30)
        }
        
        // --------------------- Cal, Step bottomContents --------------------- //
        doubleGraphBottomContents.addSubview(bottomValueContents)
        bottomValueContents.snp.makeConstraints { make in
            make.top.equalTo(doubleGraphBottomContents)
            make.left.equalTo(doubleGraphBottomContents.snp.right)
            make.bottom.right.equalTo(safeAreaView)
        }
        
        doubleGraphBottomContents.addSubview(topValue)
        topValue.snp.makeConstraints { make in
            make.centerX.equalTo(bottomValueContents)
            make.centerY.equalTo(topProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomValue)
        bottomValue.snp.makeConstraints { make in
            make.centerX.equalTo(bottomValueContents)
            make.centerY.equalTo(bottomProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.centerY.equalTo(bottomValueContents)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(1)
        }
        
        doubleGraphBottomContents.addSubview(topValueProcent)
        topValueProcent.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(topProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomValueProcent)
        bottomValueProcent.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(bottomProgress)
        }
        
        view.addSubview(fsCalendar)
        fsCalendar.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(barChartView)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }
}
