//
//  HeartRateResultViewController.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/26.
//

import UIKit

struct HeatRateMob: Codable {
    var color: Int
    var firstStr: String
    var secondStr: String
    var thirdStr: String
}

class HeartRateResultViewController: ViewController {

    @IBOutlet var rateLb: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var contentView: UIView!
    var rateNum:Int?
    var items: [HeatRateMob] = [HeatRateMob]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rateLb.text = String(format: "%d", rateNum ?? 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 25
        tableView.register(nibWithCellClass: HeartRateResultTableViewCell.self)
        loadData();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setViewRadius(view: contentView, corners:UIRectCorner.init(rawValue:  UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 25)
    }

    func loadData() {
        items = [HeatRateMob(color: 0xD8D8D8, firstStr: "静息心率（0%）", secondStr: "52bpm", thirdStr: ""),
                 HeatRateMob(color: 0x6986DC, firstStr: "恢复区（50-60%）", secondStr: "119-132bpm", thirdStr: "本区域促进血液流动，这是维持健康心脏并提高有效锻炼"),
                 HeatRateMob(color: 0x07B69DD, firstStr: "恢复区（60-70%）", secondStr: "132-146bpm", thirdStr: "该区域增强了你体内脂肪和碳水化合物的有效消耗"),
                 HeatRateMob(color: 0x69DDCB, firstStr: "有氧区（70-80%）", secondStr: "146-159bpm", thirdStr: "有效改善有氧运动，并延迟乳酸引起的疲劳"),
                 HeatRateMob(color: 0x9EDD68, firstStr: "厌氧区（80-90%）", secondStr: "159-173bpm", thirdStr: "最大效率开发你的高速运动和最大耐力"),
                 HeatRateMob(color: 0xDCB168, firstStr: "阈值区（90-100%）", secondStr: "173-186bpm", thirdStr: "（仅适用于健身人士和运动员）\n高强度运动短时间爆发力"),
                 HeatRateMob(color: 0xDD8468, firstStr: "最大心率（100%）", secondStr: "186bpm", thirdStr: "")]
        tableView.reloadData()
    }
    

    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        //保存本地数据
        //跟新本地数据的通知
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        //保存本地数据
        //跟新本地数据的通知
    }
    
}

extension HeartRateResultViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 6 {
            return 65.0
        }else {
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HeartRateResultTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        if let item = items[safe: indexPath.row] {
            cell.mob = item
        }
        return cell
    }
    
}
