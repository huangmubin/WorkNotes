//
//  VideoControlView.swift
//  VideoControlView
//
//  Created by 黄穆斌 on 16/7/28.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol VideoConsoleDelegate: NSObjectProtocol {
    func videoConsoleSliderValueChanged(console: VideoConsole, value: CGFloat)
    func videoConsolePlayStatusChanged(console: VideoConsole, play: Bool)
    func videoConsoleFullStatusChanged(console: VideoConsole, full: Bool)
}

// MARK: - Enum

enum VideoConsoleType {
    case SingleLine
}

// MARK: - VideoConsole
/*
 视频播放器控制台视图
 
 */
class VideoConsole: UIView {

    
    
    // MARK: Values
    
    /// 代理
    weak var delegate: VideoConsoleDelegate?
    
    /// 显示类型
    var type: VideoConsoleType = .SingleLine
    
    
    /// 视频总时长
    var duration: CGFloat = 3600
    /// 当前时长
    var current: CGFloat = 0 {
        didSet {
            lLabel.text = format(current / 3600) + ":" + format(current / 60) + ":" + format(current)
            let t = duration - current
            rLabel.text = format(t / 3600) + ":" + format(t / 60) + ":" + format(t)
            lLabel.sizeToFit()
            rLabel.sizeToFit()
            delegate?.videoConsoleSliderValueChanged(self, value: current)
        }
    }
    
    func format(time: CGFloat) -> String {
        let t = Int(time) % 60
        if t < 10 {
            return String(format: "0%d", t)
        } else {
            return String(format: "%d", t)
        }
    }
    
    // MARK: Sub Views
    
    var slider: LineSlider = LineSlider()
    var lLabel: UILabel = UILabel()
    var rLabel: UILabel = UILabel()
    var playButton: UIButton = UIButton()
    var fullButton: UIButton = UIButton()
    
    // MARK: Deploy
    
    func deploy() {
        switch type {
        case .SingleLine:
            self.backgroundColor = UIColor.clearColor()
            self.layer.backgroundColor = UIColor.darkGrayColor().CGColor
            self.layer.cornerRadius = 4
            
            playButton.setImage(UIImage(named: "Play_W"), forState: .Normal)
            playButton.setImage(UIImage(named: "Stop_W"), forState: .Selected)
            fullButton.setImage(UIImage(named: "Full_W"), forState: .Normal)
            fullButton.setImage(UIImage(named: "UnFull_W"), forState: .Selected)
            
            playButton.frame = CGRect(x: 0, y: frame.height / 2 - 15, width: 30, height: 30)
            playButton.addTarget(self, action: #selector(playAction), forControlEvents: .TouchUpInside)
            
            addSubview(playButton)
            fullButton.frame = CGRect(x: frame.width - 30, y: frame.height / 2 - 15, width: 30, height: 30)
            fullButton.addTarget(self, action: #selector(fullAction), forControlEvents: .TouchUpInside)
            addSubview(fullButton)
            
            lLabel.text = "00:00:00"
            rLabel.text = "00:00:00"
            lLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize() - 4)
            rLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize() - 4)
            lLabel.textColor = UIColor.whiteColor()
            rLabel.textColor = UIColor.whiteColor()
            lLabel.sizeToFit()
            rLabel.sizeToFit()
            lLabel.center = CGPoint(x: 60, y: frame.height / 2)
            rLabel.center = CGPoint(x: frame.width - 60, y: frame.height / 2)
            addSubview(lLabel)
            addSubview(rLabel)
            
            slider.frame = CGRect(x: 90, y: frame.height / 2 - 10, width: frame.width - 180, height: 20)
            slider.deploy()
            addSubview(slider)
        }
    }
    
    // MARK: Action
    
    func playAction(sender: UIButton) {
        sender.selected = !sender.selected
        delegate?.videoConsolePlayStatusChanged(self, play: sender.selected)
    }
    
    func fullAction(sender: UIButton) {
        sender.selected = !sender.selected
        delegate?.videoConsoleFullStatusChanged(self, full: sender.selected)
    }
    
}


// MARK: - Slider

class LineSlider: UIView {
    
    // MARK: Layers
    
    var schedule: CAShapeLayer = CAShapeLayer()
    var pointer: CALayer = CALayer()
    var backSchedule: CAShapeLayer = CAShapeLayer()
    
    // MARK: Values
    
    /// 控件值，0 - 1。
    var value: CGFloat = 0.5 {
        didSet {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            pointer.position.x = (frame.width - 20) * value + 10
            schedule.strokeEnd = value
            CATransaction.commit()
            if let console = superview as? VideoConsole {
                console.current = value * console.duration
            }
        }
    }
    
    // MARK: Draw Values
    
    var scheduleWidth: CGFloat = 2
    
    // MARK: Draw Colors
    
    var scheduleBackColor: UIColor = UIColor.blackColor()
    var scheduleFrontColor: UIColor = UIColor.grayColor()
    var pointerColor: UIColor = UIColor.whiteColor()
    
    // MARK: deploy
    
    func deploy() {
        //
        self.backgroundColor = UIColor.clearColor()
        
        //
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 10, y: frame.height / 2))
        path.addLineToPoint(CGPoint(x: frame.width - 10, y: frame.height / 2))
        
        //
        backSchedule.frame = bounds
        backSchedule.path = path.CGPath
        backSchedule.strokeColor = scheduleBackColor.CGColor
        backSchedule.lineWidth = scheduleWidth
        backSchedule.lineCap = kCALineCapRound
        self.layer.addSublayer(backSchedule)
        
        //
        schedule.frame = bounds
        schedule.path = path.CGPath
        schedule.strokeEnd = value
        schedule.strokeColor = scheduleFrontColor.CGColor
        schedule.lineWidth = scheduleWidth
        schedule.lineCap = kCALineCapRound
        self.layer.addSublayer(schedule)
        
        //
        pointer.frame = CGRect(x: 0, y: 0, width: 2, height: frame.height)
        pointer.cornerRadius = 1
        pointer.position = CGPoint(x: (frame.width - 20 - scheduleWidth) * value + 10 + scheduleWidth / 2, y: frame.height / 2)
        pointer.backgroundColor = pointerColor.CGColor
        self.layer.addSublayer(pointer)
        
        self.setNeedsDisplay()
    }
    
    // MARK: Touch
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let x = touches.first?.locationInView(self).x {
            switch x {
            case -CGFloat.max ..< 10:
                value = 0
            case frame.width - 10 ... CGFloat.max:
                value = 1
            default:
                value = (x - 10) / (frame.width - 20)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let x = touches.first?.locationInView(self).x {
            switch x {
            case -CGFloat.max ..< 10:
                value = 0
            case frame.width - 10 ... CGFloat.max:
                value = 1
            default:
                value = (x - 10) / (frame.width - 20)
            }
        }
    }
}