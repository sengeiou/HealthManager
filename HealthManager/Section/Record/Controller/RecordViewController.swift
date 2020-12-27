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
    
    
    @IBOutlet var ruffierLb: UILabel!
    @IBOutlet var resultColorLb: UILabel!
    
    
    let gregorian:Calendar = Calendar.init(identifier: .gregorian)
    
    @UserDefaultStringValue(key: "ageStatus", defaultValue: "")
    var ageStatus
    @UserDefaultIntValue(key: "ruffier", defaultValue: 0)
    var ruffier//耐力值
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ruffierChanged), name: APP.ruffierChanged, object: nil)
        
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
    
    func reloadViewData() {
        ruffierChanged()
    }
    
    // MARK: - Notification
    @objc func ruffierChanged() {
        self.ruffierLb.text = String(self.ruffier)
        if self.ageStatus != "" && (Int(self.ageStatus) ?? 0 > 40) {
            if ruffier >= -5 && ruffier < 10 {
                self.resultColorLb.text = "心脏功能很好"
                self.resultColorLb.textColor = .hex(0x54A300)
            }else if ruffier >= 10 && ruffier < 20 {
                self.resultColorLb.text = "心脏功能一般"
                self.resultColorLb.textColor = .hex(0x69DDCB)
            }else {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xFF1709)
            }
        }else {
            if ruffier >= -5 && ruffier < 0 {
                self.resultColorLb.text = "心脏功能很好"
                self.resultColorLb.textColor = .hex(0x54A300)
            }else if ruffier >= 0 && ruffier < 5 {
                self.resultColorLb.text = "心脏功能还可以"
                self.resultColorLb.textColor = .hex(0x69DDCB)
            }else if ruffier >= 5 && ruffier < 10 {
                self.resultColorLb.text = "心脏功能一般"
                self.resultColorLb.textColor = .hex(0x7B69DD)
            }else if ruffier >= 10 && ruffier < 20 {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xDD8468)
            }else {
                self.resultColorLb.text = "心脏功能弱"
                self.resultColorLb.textColor = .hex(0xFF1709)
            }
        }
    }
    
    // MARK: - Action
    @IBAction func showCalendar(_ sender: UIButton) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        }else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    @IBAction func vipAction(_ sender: Any) {
        let vc = VipViewController()
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func lastMonth(_ sender: Any) {
        let lastDate = self.gregorian.date(byAdding: .month, value: -1, to: self.calendar.currentPage) ?? Date()
        self.calendar.setCurrentPage(lastDate, animated: true)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        let nextDate = self.gregorian.date(byAdding: .month, value: 1, to: self.calendar.currentPage) ?? Date()
        self.calendar.setCurrentPage(nextDate, animated: true)
    }
    
    @IBAction func changeViewAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //心率
            break
        case 1:
            //血压
            break
        case 2:
            //体温
            break
        default: break
        }
    }
    
    @IBAction func questionAction(_ sender: UIButton) {
        switch sender.tag {
        case 5:
            //平均
            break
        case 6:
            //耐力测试
            break
        default: break
        }
    }
    
    @IBAction func testAction(_ sender: Any) {
        let vc = enduranceFirstViewController()
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        AppDelegate.shareDelegate?.navigationController .present(nav, animated: true, completion: nil)
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
