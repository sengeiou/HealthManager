//
//  RecordViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/21.
//

import UIKit

enum RecordType:Int {
    case heartRate = 0
    case bloodPressure
    case temperature
}

class RecordViewController: ViewController, FSCalendarDelegate, FSCalendarDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var scopeBtn: UIButton!
    @IBOutlet var dateTitleLb: UILabel!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var calendarHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var statisticsDetailLb: UILabel!
    @IBOutlet var typeImageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var averageTitileLb: UILabel!
    @IBOutlet var averageNumLb: UILabel!
    @IBOutlet var averageColorLb: UILabel!
    @IBOutlet var averageUnitLb: UILabel!
    @IBOutlet var maxNumLb: UILabel!
    @IBOutlet var minNumLb: UILabel!
    @IBOutlet var recentTimeLb: UILabel!
    @IBOutlet var ruffierLb: UILabel!
    @IBOutlet var resultColorLb: UILabel!
    var heartRateArr: [HeartRate] = []
    var bloodPressureArr: [BloodPressure] = []
    var temperatureArr: [Temperature] = []
    var recordType:RecordType? {
        didSet {
            self.reloadViewType()
        }
    }
    var averageHeartRate: String = "--"
    var averageBloodPressure: String = "--"
    var averageTemperature: String = "--"
    var maxHeartRate: String = "--"
    var minHeartRate: String = "--"
    var maxBloodPressure: String = "--"
    var minBloodPressure: String = "--"
    var maxTemperature: String = "--"
    var minTemperature: String = "--"
    
    var questionTitleArr = ["平均心率", "平均血压", "平均体温"]
    var questionContentArr = ["心率是人体生命体征中的重要指标，正常情况下成年人的平均心率，安静状态下在60-100次/分，活动状态时心率会升高，体温升高时平均心率也会升高，睡眠后心率会下降，都是人体基本的正常反应，在儿童和或青年人中，心率一般是增高的，随着年龄的增长，心率多会下降，所以平均心率一定要参考年龄、性别，是否规范运动，有无疾病等综合评判，而不能一概而论，通过上述情况，可以判断心率的高低。", "正常人血压的收缩压在90毫米汞柱到140毫米汞柱之间，舒张压在60毫米汞柱到90毫米汞柱之间，您血压的收缩压、舒张压都在正常范围内，但对于青年男性来说，收缩压有点偏低。建议注意运动，合理饮食，避免久坐久站，定期检测血压情况", "正常人体的腋下体温是36.3°到37.2°。如果体温超过37°三，属于发热，超过38.5°，需要服用退热药物退热治疗。发热多是由于感染引起的，主要需要抗感染治疗。感染得到控制，可以稳定体温。"]
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(homeDateChanged), name: APP.homeDateChanged, object: nil)
        
        self.flowLayout.itemSize = CGSize(width: floor((screenWidth-33)/6.0), height: 132.0)
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.sectionInset = UIEdgeInsets(top: 14, left: 1.5, bottom: 14, right: 1.5)
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(nibWithCellClass: HeartRateCollectionViewCell.self)
        
        self.setUpCalendar()
        self.reloadInfo()
        self.recordType = .heartRate
        self.ruffierChanged()
        
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
    
//    func reloadViewData() {
//        homeDateChanged()
//        ruffierChanged()
//    }
    
    /// 根据日期获取当天数据
    func reloadInfo() {
        let selectDateStr = dateFormatter.string(from: self.calendar.selectedDate ?? Date())
        self.heartRateArr.removeAll()
        self.bloodPressureArr.removeAll()
        self.temperatureArr.removeAll()
        self.averageHeartRate = "--"
        self.averageBloodPressure = "--"
        self.averageTemperature = "--"
        self.maxHeartRate = "--"
        self.minHeartRate = "--"
        self.maxBloodPressure = "--"
        self.minBloodPressure = "--"
        self.maxTemperature = "--"
        self.minTemperature = "--"
        self.heartRateArr = HeartRate.query(dateString: selectDateStr) ?? []
        self.bloodPressureArr = BloodPressure.query(dateString: selectDateStr) ?? []
        self.temperatureArr = Temperature.query(dateString: selectDateStr) ?? []
        self.reloadNumData()
        self.collectionView.reloadData()
    }
    
    /// 算出平均值和 最大最小值
    func reloadNumData() {
        var hrNumArr:[Int] = []
        var bpNumArr:[Int] = []
        var tNumArr:[Float] = []
        for heartRate in self.heartRateArr {
            hrNumArr.append(heartRate.num.int ?? 0)
        }
        for bloodPressure in self.bloodPressureArr {
            bpNumArr.append(bloodPressure.num.int ?? 0)
        }
        for temperature in self.temperatureArr {
            tNumArr.append(temperature.num.float() ?? 0.0)
        }
        if hrNumArr.count > 0 {
            let min = hrNumArr.min()
            let max = hrNumArr.max()
            let sum = hrNumArr.reduce(0) { x, y in
                x + y
            }
            let aver = Int(floor(Double(sum/hrNumArr.count)))
            self.minHeartRate = String(min ?? 0)
            self.maxHeartRate = String(max ?? 0)
            self.averageHeartRate = String(aver)
        }
        if bpNumArr.count > 0 {
            let min = bpNumArr.min()
            let max = bpNumArr.max()
            let sum = bpNumArr.reduce(0) { x, y in
                x + y
            }
            let aver = Int(floor(Double(sum/bpNumArr.count)))
            self.minBloodPressure = String(min ?? 0)
            self.maxBloodPressure = String(max ?? 0)
            self.averageBloodPressure = String(aver)
        }
        if tNumArr.count > 0 {
            let min = tNumArr.min()
            let max = tNumArr.max()
            let sum = tNumArr.reduce(0) { x, y in
                x + y
            }
            let aver = sum/Float(tNumArr.count)
            self.minTemperature = String(format: "%.1f", min ?? 0.0)
            self.maxTemperature = String(format: "%.1f", max ?? 0.0)
            self.averageTemperature = String(format: "%.1f", aver)
        }
    }
    
    func reloadViewType() {
        switch self.recordType {
        case .heartRate:
            self.statisticsDetailLb.text = "（心率:bpm）"
            self.averageTitileLb.text = "平均心率"
            self.averageNumLb.text = averageHeartRate
            self.averageUnitLb.text = "bpm"
            if averageHeartRate != "--" {
                if averageHeartRate.int ?? 0 < 60 {
                    self.averageColorLb.text = "心率过缓"
                    self.averageColorLb.textColor = .hex(0x6986DC)
                }else if averageHeartRate.int ?? 0 > 100 {
                    self.averageColorLb.text = "心率过快"
                    self.averageColorLb.textColor = .hex(0xFF1709)
                }else {
                    self.averageColorLb.text = "正常心率"
                    self.averageColorLb.textColor = .hex(0x53A200)
                }
            }else {
                self.averageColorLb.text = "暂无数据"
                self.averageColorLb.textColor = .hex(0x8F8F8F)
            }
            self.maxNumLb.text = maxHeartRate
            self.minNumLb.text = minHeartRate
            //self.averageColorLb.textColor =
            //self.recentTimeLb.text = ""
            break
        case .bloodPressure:
            self.statisticsDetailLb.text = "（血压:mmHg）"
            self.averageTitileLb.text = "平均血压"
            self.averageNumLb.text = averageBloodPressure
            self.averageUnitLb.text = "mmHg"
            if averageBloodPressure != "--" {
                if averageBloodPressure.int ?? 0 < 60 {
                    self.averageColorLb.text = "舒张压偏低"
                    self.averageColorLb.textColor = .hex(0x6986DC)
                }else if averageBloodPressure.int ?? 0 > 89 {
                    self.averageColorLb.text = "舒张压偏高"
                    self.averageColorLb.textColor = .hex(0xFF1709)
                }else {
                    self.averageColorLb.text = "正常舒张压"
                    self.averageColorLb.textColor = .hex(0x53A200)
                }
            }else {
                self.averageColorLb.text = "暂无数据"
                self.averageColorLb.textColor = .hex(0x8F8F8F)
            }
            self.maxNumLb.text = maxBloodPressure
            self.minNumLb.text = minBloodPressure
            //self.averageColorLb.textColor =
            //self.recentTimeLb.text = ""
            break
        case .temperature:
            self.statisticsDetailLb.text = "（体温:°C）"
            self.averageTitileLb.text = "平均体温"
            self.averageNumLb.text = averageTemperature
            self.averageUnitLb.text = "°C"
            logInfo(averageTemperature.float() ?? 0.0)
            if averageTemperature != "--" {
                if averageTemperature.float() ?? 0.0 < 36.0 {
                    self.averageColorLb.text = "体温偏低"
                    self.averageColorLb.textColor = .hex(0x6986DC)
                }else if averageTemperature.float() ?? 0.0 > 37.3 {
                    self.averageColorLb.text = "体温偏高"
                    self.averageColorLb.textColor = .hex(0xFF1709)
                }else {
                    self.averageColorLb.text = "正常体温"
                    self.averageColorLb.textColor = .hex(0x53A200)
                }
            }else {
                self.averageColorLb.text = "暂无数据"
                self.averageColorLb.textColor = .hex(0x8F8F8F)
            }
            self.maxNumLb.text = maxTemperature
            self.minNumLb.text = minTemperature
            //self.averageColorLb.textColor =
            //self.recentTimeLb.text = ""
            break
        case .none: break
        }
        self.collectionView.reloadData()
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
    
    @objc func homeDateChanged() {
        reloadInfo()
        reloadViewType()
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
            self.recordType = .heartRate
            self.typeImageView.image = UIImage(named: "心率-切换")
            break
        case 1:
            //血压
            self.recordType = .bloodPressure
            self.typeImageView.image = UIImage(named: "血压-切换")
            break
        case 2:
            //体温
            self.recordType = .temperature
            self.typeImageView.image = UIImage(named: "体温-切换")
            break
        default: break
        }
    }
    
    @IBAction func questionAction(_ sender: UIButton) {
        switch sender.tag {
        case 5:
            //平均
            let view = QuestionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            view.titleLb.text = questionTitleArr[self.recordType?.rawValue ?? 0]
            view.textView.text = questionContentArr[self.recordType?.rawValue ?? 0]
            view.show()
            break
        case 6:
            //耐力测试
            let view = QuestionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            view.titleLb.text = "耐力测试"
            view.textView.text = "这是一项很简单的测试，可以让您了解自己的心脏耐力情况。这项测试被称为Ruffier测试。\n20至40岁:\n指数在-5到0之间:心脏功能很好;\n指数在0到5之间:心脏功能还可以;\n指数在5到10之间:心脏功能- -般;\n指数在10到20之间:心脏功能弱;\n20以上:心脏功能不正常;\n40岁以上\n指数在-5到10之间:心脏功能很好;\n指数在10到20之间:心脏功能一般;\n20以上:心脏功能弱;"
            view.show()
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
        //let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        self.reloadInfo()
        self.reloadViewType()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
        self.dateTitleLb.text = self.getCanlendarTitle(date: self.calendar.currentPage)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RecordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.recordType == RecordType.heartRate {
            return self.heartRateArr.count < 6 ? 6 : self.heartRateArr.count
        }else if self.recordType == RecordType.bloodPressure {
            return self.bloodPressureArr.count < 6 ? 6 : self.bloodPressureArr.count
        }else {
            return self.temperatureArr.count < 6 ? 6 : self.temperatureArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: HeartRateCollectionViewCell.self, for: indexPath)
        if self.recordType == RecordType.heartRate {
            if indexPath.item + 1 > self.heartRateArr.count {
                let heartRate = HeartRate(num: "0", dateString: "", timeString: "暂无")
                cell.heartRate = heartRate
            }else {
                let heartRate = self.heartRateArr[indexPath.row]
                cell.heartRate = heartRate
            }
        }else if self.recordType == RecordType.bloodPressure {
            if indexPath.item + 1 > self.bloodPressureArr.count {
                let bloodPressure = BloodPressure(num: "0", dateString: "", timeString: "暂无")
                cell.bloodPressure = bloodPressure
            }else {
                let bloodPressure = self.bloodPressureArr[indexPath.row]
                cell.bloodPressure = bloodPressure
            }
        }else {
            if indexPath.item + 1 > self.temperatureArr.count {
                let temperature = Temperature(num: "0", dateString: "", timeString: "暂无")
                cell.temperature = temperature
            }else {
                let temperature = self.temperatureArr[indexPath.row]
                cell.temperature = temperature
            }
        }
        return cell
    }
    
    
}
