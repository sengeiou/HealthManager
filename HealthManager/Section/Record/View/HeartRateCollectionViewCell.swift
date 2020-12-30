//
//  HeartRateCollectionViewCell.swift
//  HealthManager
//
//  Created by 赖星果 on 2020/12/28.
//

import UIKit

class HeartRateCollectionViewCell: UICollectionViewCell {

    @IBOutlet var timeLb: UILabel!
    @IBOutlet var colorView: UIView!
    @IBOutlet var numLb: UILabel!
    @IBOutlet var colorViewHeight: NSLayoutConstraint!
    var heartRate: HeartRate? {
        didSet {
            numLb.text = heartRate?.num
            timeLb.text = heartRate?.timeString
            let height = CGFloat(15 + (heartRate?.num.int ?? 0 / 120 * 100))
            if height > 116.0 {
                colorViewHeight.constant = 116.0
            }else {
                colorViewHeight.constant = height
            }
            if colorViewHeight.constant <= 15 {
                colorView.backgroundColor = .hex(0xE3E3E3)
                numLb.isHidden = true
            }else {
                colorView.backgroundColor = .hex(0x516FFF)
                numLb.isHidden = false
            }
        }
    }
    var bloodPressure: BloodPressure? {
        didSet {
            numLb.text = bloodPressure?.num
            timeLb.text = bloodPressure?.timeString
            let height = CGFloat(15 + (bloodPressure?.num.int ?? 0 / 140 * 100))
            if height > 116.0 {
                colorViewHeight.constant = 116.0
            }else {
                colorViewHeight.constant = height
            }
            if colorViewHeight.constant <= 15 {
                colorView.backgroundColor = .hex(0xE3E3E3)
                numLb.isHidden = true
            }else {
                colorView.backgroundColor = .hex(0x516FFF)
                numLb.isHidden = false
            }
        }
    }
    var temperature: Temperature? {
        didSet {
            let nfloat = temperature?.num.float()
            numLb.text = String(format: "%.1f", nfloat ?? 0.0)
            timeLb.text = temperature?.timeString
            let num: Float = temperature?.num.float() ?? 0.0
            let height = CGFloat(15 + ( num / 50 * 100))
            if height > 116.0 {
                colorViewHeight.constant = 116
            }else {
                colorViewHeight.constant = height
            }
            if colorViewHeight.constant <= 15 {
                colorView.backgroundColor = .hex(0xE3E3E3)
                numLb.isHidden = true
            }else {
                colorView.backgroundColor = .hex(0x516FFF)
                numLb.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
