//
//  RecordViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit

class RecordViewController: ViewController, FSCalendarDelegate, FSCalendarDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var scopeBtn: UIButton!
    @IBOutlet var dateTitleLb: UILabel!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var calendarHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    let gregorian:Calendar = Calendar.init(identifier: .gregorian)
    
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpCalendar()
    }

    func setUpCalendar() {
        self.view.addGestureRecognizer(self.scopeGesture)
        self.scrollView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendarHeight.constant = 200
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.appearance.titleFont = .pingFangMedium(15)
        self.calendar.placeholderType = .none
        self.calendar.scope = .week
        self.calendar.select(Date())
        self.dateTitleLb.text = self.getCanlendarTitle(date: self.calendar.currentPage)
    }
    
    func getCanlendarTitle(date:Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month], from: date)
        let year = components.year
        let month = components.month
        return String(format: "%d年%d月", year!, month!)
    }
    
    // MARK:- Action
    @IBAction func showCalendar(_ sender: UIButton) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        }else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    @IBAction func lastMonth(_ sender: Any) {
        let lastDate = self.gregorian.date(byAdding: .month, value: -1, to: self.calendar.currentPage) ?? Date()
        self.calendar.setCurrentPage(lastDate, animated: true)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        let nextDate = self.gregorian.date(byAdding: .month, value: 1, to: self.calendar.currentPage) ?? Date()
        self.calendar.setCurrentPage(nextDate, animated: true)
    }
    
    // MARK:- UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.scrollView.contentOffset.y <= -self.scrollView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                fatalError()
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
        self.dateTitleLb.text = self.getCanlendarTitle(date: self.calendar.currentPage)
    }

}
