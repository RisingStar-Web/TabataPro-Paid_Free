//
//  TimerView.swift
//  CrossfitMe
//
//  Created by Роман Кабиров on 26.11.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit
import AVFoundation

class TabataTimerView: UIView {
    var soundEnabled = true
    
    private let bg = UIImage(named: "timer-background")
    private var currentTimerSec = 0
    private var timer: Timer?
    var segments: [CAShapeLayer] = []
    var labelSeconds: UILabel?
    var labelCaptionSec: UILabel?
    var info: TabataInfo?
    
    var labelCurrentCycle: UILabel?
    var labelCurrentTabata: UILabel?
    var labelCurrentMode: UILabel?
    
    var currentCycle: Int = 0
    var currentTabata: Int = 0

    var timerMode: TabataTimerMode = .prepare
    
    let colorGray: CGColor = UIColor(red:0.7,  green:0.7,  blue:0.7, alpha:0.5).cgColor
    let colorYellow: CGColor = UIColor(red:0.7,  green:0.7,  blue:0.1, alpha: 0.7).cgColor
    let colorRed: CGColor = UIColor(red:0.7,  green:0.1,  blue:0.1, alpha: 1.0).cgColor
    let colorGreen: CGColor = UIColor(red:0,  green:0.8,  blue:0.1, alpha:1).cgColor
    
    var player: AVAudioPlayer?
    

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
        player?.stop()
    }
    
    func playSound(_ name: String) {
        if !soundEnabled {
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "tabata-sounds") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loaded() {
        backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.94)
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
        
        
        
        // header
        let labelCycles = UILabel(frame: CGRect(x: 30, y: 40, width: 100, height: 30))
        labelCycles.text = "Cycle".localized
        labelCycles.textColor = .white
        labelCycles.font = UIFont.systemFont(ofSize: 16, weight: .light)
        labelCycles.textAlignment = .center
        addSubview(labelCycles)

        
        
        labelCurrentCycle?.removeFromSuperview()
        labelCurrentCycle = UILabel(frame: CGRect(x: 30, y: 80, width: 100, height: 60))
        labelCurrentCycle?.text = "8"
        labelCurrentCycle?.textAlignment = .center

        // labelCurrentCycle?.backgroundColor = .red
        labelCurrentCycle?.textColor = .white
        labelCurrentCycle?.font = UIFont.systemFont(ofSize: 72, weight: .medium)
        addSubview(labelCurrentCycle!)
        
        
        let labelTabatas = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 100 - 30, y: 40, width: 100, height: 30))
        labelTabatas.text = "Tabatas".localized
        labelTabatas.textAlignment = .center
        labelTabatas.textColor = .white
        labelTabatas.font = UIFont.systemFont(ofSize: 16, weight: .light)
        addSubview(labelTabatas)
        
        
        
        labelCurrentTabata?.removeFromSuperview()
        labelCurrentTabata = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 100 - 30, y: 80, width: 100, height: 60))
        labelCurrentTabata?.text = "1"
        labelCurrentTabata?.textAlignment = .center

        // labelCurrentTabata?.backgroundColor = .red
        labelCurrentTabata?.textColor = .white
        labelCurrentTabata?.font = UIFont.systemFont(ofSize: 72, weight: .medium)
        addSubview(labelCurrentTabata!)
        
        labelCurrentMode?.removeFromSuperview()
        labelCurrentMode = UILabel(frame: CGRect(x: 100, y: 95, width: UIScreen.main.bounds.width - 200, height: 30))
        labelCurrentMode?.text = "Prepare".localized
        labelCurrentMode?.textAlignment = .center
        
        // labelCurrentTabata?.backgroundColor = .red
        labelCurrentMode?.textColor = .white
        labelCurrentMode?.font = UIFont.systemFont(ofSize: 20, weight: .light)
        addSubview(labelCurrentMode!)

        
        
        createSegments()
        
        // startTimer(30)
    }
    
    func startTimer(_ info: TabataInfo) {
        soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
        self.info = info
        timerMode = .prepare
        currentTimerSec = info.prepareSec
        currentCycle = info.cycles
        currentTabata = info.tabatas
        startActualTimer()
    }
    
    func startActualTimer() {
        labelCaptionSec?.isHidden = false
        timer?.invalidate()
        
        labelCurrentCycle?.text = String((info?.cycles)!)
        labelCurrentTabata?.text = String((info?.tabatas)!)

        updateSegments()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
    }
    
    @IBAction func timerEvent() {
        currentTimerSec -= 1
        
        if (timerMode == .prepare) || (timerMode == .rest) {
            if currentTimerSec == 5 { playSound("five_en") } else
            if currentTimerSec == 4 { playSound("four_en") } else
            if currentTimerSec == 3 { playSound("three_en") } else
            if currentTimerSec == 2 { playSound("two_en") } else
            if currentTimerSec == 1 { playSound("one_en") } else
            if currentTimerSec == 0 { playSound("go_en") }
        }
        
        if currentTimerSec <= 0 {
            if timerMode == .prepare {
                timerMode = .work
                updateCurrentModeLabel()
                currentTimerSec = (info?.workSec)!
            }
            else
            if timerMode == .work {
                currentCycle -= 1
                labelCurrentCycle?.text = String(currentCycle)

                if currentCycle <= 0 {
                    currentTabata -= 1
                    currentCycle = (info?.cycles)!
                    labelCurrentCycle?.text = String(currentCycle)
                    labelCurrentTabata?.text = String(currentTabata)
                    if currentTabata <= 0 {
                        playSound("final_sound")
                        timer?.invalidate()
                    } else {
                        playSound("ding")
                    }
                } else {
                    playSound("ding")
                }
                timerMode = .rest
                updateCurrentModeLabel()
                currentTimerSec = (info?.restSec)!
            }
            else
            if timerMode == .rest {
                timerMode = .work
                updateCurrentModeLabel()
                currentTimerSec = (info?.workSec)!
            }
        }
        updateSegments()
    }
    
    func updateCurrentModeLabel() {
        switch timerMode {
        case .prepare: labelCurrentMode?.text = "Prepare".localized
        case .work: labelCurrentMode?.text = "Work".localized
        case .rest: labelCurrentMode?.text = "Rest".localized
        }
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

            if i < currentTimerSec {
                switch timerMode {
                case .prepare: s.strokeColor = colorRed; break
                case .work: s.strokeColor = colorGreen; break
                case .rest: s.strokeColor = colorYellow; break
                }
            } else {
                s.strokeColor = colorGray
            }

            
        }
        labelSeconds?.text = "\(currentTimerSec)"
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

struct TabataInfo {
    var prepareSec = 10
    var workSec = 20
    var restSec = 10
    var cycles = 8
    var tabatas = 1
}

enum TabataTimerMode {
    case prepare
    case work
    case rest
}

