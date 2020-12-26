//
//  HeartRateResultTableViewCell.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/26.
//

import UIKit

class HeartRateResultTableViewCell: UITableViewCell {

    @IBOutlet var colorView: UIView!
    @IBOutlet var firstLb: UILabel!
    @IBOutlet var secondLb: UILabel!
    @IBOutlet var thirdLb: UILabel!
    var mob:HeatRateMob = HeatRateMob(color: 0x000000, firstStr: "", secondStr: "", thirdStr: "") {
        didSet {
            colorView.backgroundColor = .hex(mob.color)
            firstLb.textColor = .hex(mob.color)
            firstLb.text = mob.firstStr
            secondLb.text = mob.secondStr
            thirdLb.text = mob.thirdStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
