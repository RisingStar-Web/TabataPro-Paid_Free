//
//  TimerViewController.swift
//  TabataProFree
//
//  Created by Роман Кабиров on 16.06.2018.
//  Copyright © 2018 Logical Mind. All rights reserved.
//

import UIKit
import AVFoundation

protocol TimerViewDelegate {
    func timerFinished()
}

class TimerViewController: UIViewController {
    var delegate: TimerViewDelegate?
    var soundEnabled = true
    var config: TabataInfo?

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelMode: UILabel!
    @IBOutlet weak var labelRounds: UILabel!
    @IBOutlet weak var labelTabatas: UILabel!
    
    private var currentTimerSec = 0
    private var currentTimerMSec = 0
    private var timer: Timer?
    
    private var currentCycle: Int = 0
    private var currentTabata: Int = 0
    private var timerMode: TabataTimerMode = .prepare

    private var player: AVAudioPlayer?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // labelTime.font = UIFont.monospacedDigitSystemFont(ofSize: 144.0, weight: .thin)
        labelTime.font = UIFont.monospacedDigitSystemFont(ofSize: 86.0, weight: .thin)
        labelTime.adjustsFontSizeToFitWidth = true
        labelTime.minimumScaleFactor = 0.2

    }

    func startTimer(config: TabataInfo) {
        soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
        self.config = config
        timerMode = .prepare
        currentTimerSec = config.prepareSec - 1
        currentCycle = config.cycles
        currentTabata = config.tabatas
        updateCurrentModeLabel()
        updateTimeLabel()
        startActualTimer()
    }

    func stopTimer() {
        timer?.invalidate()
        player?.stop()
    }
    
    
}

extension TimerViewController {
    func startActualTimer() {
        timer?.invalidate()
        
        labelRounds?.text = String((config?.cycles)!)
        labelTabatas?.text = String((config?.tabatas)!)
        updateTimeLabel()
        currentTimerMSec = 100
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
    }

    
    @IBAction func timerEvent() {
        currentTimerMSec -= 1
        if currentTimerMSec > 0 {
            updateTimeLabel()
            return
        }
        
        currentTimerMSec = 100
        currentTimerSec -= 1

        /*
        if (timerMode == .prepare) || (timerMode == .rest) {
            if currentTimerSec == 5 { playSound("five_en") } else
                if currentTimerSec == 4 { playSound("four_en") } else
                    if currentTimerSec == 3 { playSound("three_en") } else
                        if currentTimerSec == 2 { playSound("two_en") } else
                            if currentTimerSec == 1 { playSound("one_en") } else
                                if currentTimerSec == 0 { playSound("go_en") }
        }
        */
        
        if currentTimerSec < 0 {
            if timerMode == .prepare {
                soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
                if soundEnabled {
                    AudioServicesPlayAlertSound(SystemSoundID(1313))
                }

                timerMode = .work
                updateCurrentModeLabel()
                currentTimerSec = (config?.workSec)! - 1
            }
            else
                if timerMode == .work {
                    currentCycle -= 1
                    labelRounds?.text = String(currentCycle)
                    
                    if currentCycle <= 0 {
                        currentTabata -= 1
                        currentCycle = (config?.cycles)!
                        labelRounds?.text = String(currentCycle)
                        labelTabatas?.text = String(currentTabata)
                        
                        soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
                        if currentTabata <= 0 {
                            if soundEnabled {
                                AudioServicesPlayAlertSound(SystemSoundID(1322))
                            }
                            timer?.invalidate()
                            delegate?.timerFinished()
                        } else {
                            // playSound("ding")
                            if soundEnabled {
                                AudioServicesPlayAlertSound(SystemSoundID(1313))
                            }
                        }
                        
                    } else {
                        // playSound("ding")
                        soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
                        if soundEnabled {
                            AudioServicesPlayAlertSound(SystemSoundID(1313))
                        }
                    }
                    timerMode = .rest
                    updateCurrentModeLabel()
                    currentTimerSec = (config?.restSec)! - 1
                }
                else
                    if timerMode == .rest {
                        soundEnabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
                        if soundEnabled {
                            AudioServicesPlayAlertSound(SystemSoundID(1313))
                        }

                        timerMode = .work
                        updateCurrentModeLabel()
                        currentTimerSec = (config?.workSec)! - 1
            }
        }
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        // let rand = Int(arc4random_uniform(2) + 5)
        let rand = 4
        if currentTimerMSec % rand != 0 {
            return
        }
        
        let min = Int(currentTimerSec / 60)
        let sec = Int(currentTimerSec % 60)
        var msec = currentTimerMSec
        if msec >= 100 {
            msec = 99
        }

        let minStr = String.init(format: "%02d", min)
        let secStr = String.init(format: "%02d", sec)
        let msecStr = String.init(format: "%02d", msec)
        labelTime.text = minStr + ": " + secStr + ", " + msecStr
    }
    
    func updateCurrentModeLabel() {
        switch timerMode {
        case .prepare:
            labelMode?.text = "Prepare".localized
            labelMode?.textColor = UIColor.orange
        case .work:
            labelMode?.text = "Work".localized
            labelMode?.textColor = .red
        case .rest:
            labelMode?.text = "Rest".localized
            labelMode?.textColor = UIColor.init(red: 65/255, green: 147/255, blue: 5/255, alpha: 1.0)
        }
        labelTime?.textColor = labelMode?.textColor
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
}
