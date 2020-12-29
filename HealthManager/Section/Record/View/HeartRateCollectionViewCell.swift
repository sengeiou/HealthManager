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
            colorViewHeight.constant = CGFloat(15 + (heartRate?.num.int ?? 0 / 120 * 100))
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
            colorViewHeight.constant = CGFloat(15 + (bloodPressure?.num.int ?? 0 / 120 * 100))
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
            numLb.text = temperature?.num
            timeLb.text = temperature?.timeString
            colorViewHeight.constant = CGFloat(15 + (temperature?.num.float() / 120 * 100))
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
