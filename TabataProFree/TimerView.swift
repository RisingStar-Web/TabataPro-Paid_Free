//
//  TimerView.swift
//  CrossfitMe
//
//  Created by Роман Кабиров on 26.11.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

protocol TimerViewDelegate {
    func timerDone()
}

class TimerView: UIView {
    private let bg = UIImage(named: "timer-background")
    private var currentTimerSec = 0
    private var timer: Timer?
    var delegate: TimerViewDelegate?
    var segments: [CAShapeLayer] = []
    var labelSeconds: UILabel?
    var labelCaptionSec: UILabel?
    var prestartMode: TimerMode = .normal
    var secMax: Int = 0

    let colorGray: CGColor = UIColor(red:0.7,  green:0.7,  blue:0.7, alpha:0.5).cgColor
    let colorYellow: CGColor = UIColor(red:0.7,  green:0.7,  blue:0.1, alpha: 0.7).cgColor
    let colorRed: CGColor = UIColor(red:0.7,  green:0.1,  blue:0.1, alpha: 1.0).cgColor
    let colorGreen: CGColor = UIColor(red:0,  green:0.8,  blue:0.1, alpha:1).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loaded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loaded()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func loaded() {
        backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.88)
        let frame = CGRect(x: 10, y: UIScreen.main.bounds.height - 34, width: UIScreen.main.bounds.width - 20, height: 28)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.text = "Double-tap to cancel".localized
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = .white
        addSubview(label)

        let bigFontSize = (UIScreen.main.bounds.width * 104) / 414
        let smallFontSize = (UIScreen.main.bounds.width * 30) / 414
        let bigHeight = (UIScreen.main.bounds.width * 90) / 414
        
        let frameBigLabel = CGRect(x: 50, y: (UIScreen.main.bounds.height / 2) - (UIScreen.main.bounds.height * 0.08), width: UIScreen.main.bounds.width - 100, height: bigHeight)
        labelSeconds = UILabel(frame: frameBigLabel)
        labelSeconds?.textAlignment = .center
        labelSeconds?.text = "15"

        // labelSeconds?.font = UIFont.systemFont(ofSize: bigFontSize, weight: .medium)
        labelSeconds?.font = UIFont.monospacedDigitSystemFont(ofSize: bigFontSize, weight: .medium)
        
        
        labelSeconds?.textColor = .white
        addSubview(labelSeconds!)

        let frameSmallLabel = CGRect(x: 50, y: (UIScreen.main.bounds.height / 2) + (UIScreen.main.bounds.height * 0.05), width: UIScreen.main.bounds.width - 100, height: 30)
        labelCaptionSec = UILabel(frame: frameSmallLabel)
        labelCaptionSec?.textAlignment = .center
        labelCaptionSec?.text = "sec".localized
        labelCaptionSec?.font = UIFont.systemFont(ofSize: smallFontSize, weight: .medium)
        labelCaptionSec?.textColor = .white
        addSubview(labelCaptionSec!)
        labelCaptionSec?.isHidden = true

        
        createSegments()
        
        // startTimer(30)
    }
    
    func startTimer(_ sec: Int) {
        secMax = sec

        prestartMode = .yellowDown
        currentTimerSec = 59
        timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(timerPrestartEvent),    userInfo: nil, repeats: true)

        /*
        
        if Data.settings.pauseBeforeTimer == 0 {
            prestartMode = .yellowDown
            currentTimerSec = 59
            timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(timerPrestartEvent),    userInfo: nil, repeats: true)

            /*
            prestartMode = .prestartPause
            currentTimerSec = Data.settings.pauseBeforeTimer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerPrestartEvent),    userInfo: nil, repeats: true)
            */
            
        } else {
            labelCaptionSec?.isHidden = false
            currentTimerSec = Data.settings.pauseBeforeTimer + 1
            prestartMode = .prestartPause
            timerPrestartEvent()
            updateSegments()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerPrestartEvent),    userInfo: nil, repeats: true)
        }
         */
        
        /*
        timer?.invalidate()
        currentTimerSec = sec
        updateSegments()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        */
    }
    
    @IBAction func timerPrestartEvent() {
        if prestartMode == .yellowUp {
            currentTimerSec += 1
            if currentTimerSec > 59 {
                prestartMode = .yellowDown
            }
        } else
        if prestartMode == .yellowDown {
            currentTimerSec -= 1
            if currentTimerSec <= 0 {
                prestartMode = .yellowStart
            }
        } else
        if prestartMode == .prestartPause {
            currentTimerSec -= 1
            if currentTimerSec <= 0 {
                startActualTimer()
            }
        }
        else
        if prestartMode == .yellowStart {
            currentTimerSec += 1
            if (currentTimerSec > secMax) || (currentTimerSec > 59) {
                startActualTimer()
            }
        }
        updateSegments()
    }
    
    func startActualTimer() {
        prestartMode = .normal
        labelCaptionSec?.isHidden = false
        
        timer?.invalidate()
        currentTimerSec = secMax
        updateSegments()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
    }
    
    @IBAction func timerEvent() {
        currentTimerSec -= 1
        if currentTimerSec <= 0 {
            timer?.invalidate()
            delegate?.timerDone()
        }
        updateSegments()
    }
    
    func drawBackground(_ rect: CGRect) {
        bg?.draw(in: rect)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let width = frame.width - 20
        let height = width
        let center = (frame.height / 2)  - (width / 2)
        let rect = CGRect(x: 10, y: center, width: width, height: height)

        drawBackground(rect)

        // segments
        // let leftOffset : CGFloat = 58
        let leftOffset : CGFloat = frame.width * (58 / 320)
        let size = frame.width - (leftOffset * 2)
        let strokeWidth: CGFloat = 48
        
        

        // center gradient circle
        let context = UIGraphicsGetCurrentContext()

        context!.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let centerPoint: CGPoint = CGPoint(x: (frame.width / 2) + (size / 4), y: (frame.height / 2) - (size / 4) )
        let radius: CGFloat = ((size - strokeWidth) / 2) + 0.1
        var colors:[CGColor] = [UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1.0).cgColor, UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.8])
        let endPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
        context!.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0.0, endCenter: endPoint, endRadius: radius, options: CGGradientDrawingOptions(rawValue: 0))
    }
    
    func updateSegments() {
        for i in 0...59 {
            let s = segments[i] as CAShapeLayer
            let c = Int(currentTimerSec / 60)
            
            let maxCurrentTime = currentTimerSec > 59 ? (currentTimerSec - (60 * c)) : currentTimerSec
            
            if i < (maxCurrentTime) {
                if prestartMode == .normal {
                    s.strokeColor = colorGreen
                } else {
                    if prestartMode == .prestartPause {
                        s.strokeColor = colorRed
                    } else {
                        s.strokeColor = colorYellow
                    }
                }
            }
            else {
                if c > 0 {
                    s.strokeColor = colorYellow
                } else {
                    s.strokeColor = colorGray
                }
            }
        }
        if (prestartMode == .normal) || (prestartMode == .prestartPause) {
            labelSeconds?.text = "\(currentTimerSec)"
        } else {
            labelSeconds?.text = ""
        }
    }
    
    func createSegments() {
        
        // let leftOffset : CGFloat = 58
        let leftOffset : CGFloat = frame.width * (58 / 320)
        let size = frame.width - (leftOffset * 2)
        let strokeWidth: CGFloat = 48

        let circleCenter = (frame.height / 2)  - (size / 2)

        let circleRect = CGRect(x: leftOffset, y: circleCenter, width: size, height: size)
        // let circlePath = UIBezierPath.init(ovalIn: circleRect)

        let circleRect2 = CGRect(x: 0, y: 0, width: size, height: size)
        let circlePath = UIBezierPath.init(ovalIn: circleRect2)

        
        // let circlePath = UIBezierPath(ovalInRect: CGRect(x: 200, y: 200, width: 150, height: 150))
        // var segments: [CAShapeLayer] = []
        // let segmentAngle: CGFloat = (360 * 0.125) / 360
        // let angleFactor: CGFloat = 125 / 3000
        // let segmentAngle: CGFloat = (360 * 0.125) / 360
        //         let segmentAngle: CGFloat = (360 * angleFactor) / 360
        
        let segmentAngle: CGFloat = 0.01666
        // let startAngle: CGFloat = segmentAngle * 45
        // let angleMax: CGFloat = segmentAngle * 59
        

        let tickLayer = CALayer()
        tickLayer.frame = circleRect
        tickLayer.backgroundColor = UIColor.clear.cgColor
        
        for i in 0...59 {
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            // start angle is number of segments * the segment angle
            circleLayer.strokeStart = (segmentAngle  * CGFloat(i)) // + startAngle
            
            /*
            if circleLayer.strokeStart > angleMax {
                circleLayer.strokeStart = angleMax - (segmentAngle  * CGFloat(i))
            }
             */
            let gapSize: CGFloat = 0.002
            circleLayer.strokeEnd = circleLayer.strokeStart + segmentAngle - gapSize
            
            circleLayer.lineWidth = strokeWidth
            circleLayer.fillColor = UIColor.clear.cgColor
            
            // add the segment to the segments array and to the view
            
            //segments.insert(circleLayer, at: i)
            
            segments.append(circleLayer)
            tickLayer.addSublayer(segments[i])
            // view.layer.addSublayer(segments[i])
            
        }
        tickLayer.setAffineTransform(CGAffineTransform(rotationAngle: -1 * .pi / 2))
        layer.addSublayer(tickLayer)
        

        /*
        for i in 0...59 {
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            // start angle is number of segments * the segment angle
            circleLayer.strokeStart = (segmentAngle  * CGFloat(i)) + startAngle
            
            if circleLayer.strokeStart > angleMax {
                circleLayer.strokeStart = angleMax - (segmentAngle  * CGFloat(i))
            }
            let gapSize: CGFloat = 0.002
            circleLayer.strokeEnd = circleLayer.strokeStart + segmentAngle - gapSize
            
            circleLayer.lineWidth = strokeWidth
            circleLayer.fillColor = UIColor.clear.cgColor
            
            // add the segment to the segments array and to the view
            segments.insert(circleLayer, at: i)
            layer.addSublayer(segments[i])
            // view.layer.addSublayer(segments[i])

        }
         */
    
    }
    
}

enum TimerMode {
    case normal
    case yellowUp
    case yellowDown
    case yellowStart
    case prestartPause
}
