import Foundation
import FSCalendar
import Then

class CustomCalendar : UIView, FSCalendarDelegate, FSCalendarDataSource {
 
    private var calendar: FSCalendar

    override init(frame: CGRect) {
        self.calendar = FSCalendar(frame: frame)
        super.init(frame: frame)
        setupCalendar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.calendar = FSCalendar(frame: CGRect.zero)
        super.init(coder: aDecoder)
        setupCalendar()
    }
 
    // 클로저
    var didSelectDate: ((Date) -> Void)?
    var didDeselectDate: ((Date) -> Void)?
    
    private func setupCalendar() {
        calendar.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor.MY_BLUE
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        calendar.appearance.selectionColor = UIColor.MY_BLUE
        calendar.appearance.weekdayTextColor = UIColor.MY_BLUE
        calendar.appearance.todayColor = UIColor.MY_RED
        calendar.scrollEnabled = true
        calendar.scrollDirection = .vertical
        calendar.layer.cornerRadius = 10
        calendar.layer.borderColor = UIColor.MY_SKY.cgColor
        calendar.layer.borderWidth = 2
        calendar.clipsToBounds = true
        calendar.delegate = self
        calendar.dataSource = self
        
        addSubview(calendar)
    }
    
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        didSelectDate?(date)  // 클로저 호출
    }
    
    internal func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        didDeselectDate?(date)  // 클로저 호출
    }
    
}
