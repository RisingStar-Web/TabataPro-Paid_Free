//
//  TabataViewController.swift
//  CrossfitMe
//
//  Created by Роман Кабиров on 11.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit
import GoogleMobileAds
import StoreKit

class TabataViewController: UIViewController {
    @IBOutlet weak var buttonSound: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonStart: UIButton!
    
    // Ad banner and interstitial views
    var adMobBannerView = GADBannerView()
    let ADMOB_BANNER_UNIT_ID = "ca-app-pub-9088965992169251/3442559407"
    
    var tableViewController: TableViewController?
    var timerViewController: TimerViewController!
    
    var tabata: TabataTimerView?
    
    private var isTimerActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let enabled = UserDefaults.standard.bool(forKey: "timer-sound-enabled")
        let img = enabled ? UIImage(named: "sound-on") : UIImage(named: "sound-off")
        buttonSound.setImage(img, for: .normal)
        
        tableViewController = childViewControllers.first as? TableViewController
        timerViewController = nil
        
        let runCnt = UserDefaults.standard.integer(forKey: "run-count")
        if runCnt > 10 {
            SKStoreReviewController.requestReview()
        } else {
            UserDefaults.standard.set(runCnt + 1, forKey: "run-count")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            // Init AdMob banner
            self.initAdMobBanner()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabata?.stopTimer()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func buttonStart(_ sender: Any) {
        if timerViewController == nil {
            createTimerController()
        }
        
        if isTimerActive {
            timerViewController.stopTimer()
        } else {
            let prepare = tableViewController?.timePrepare
            let work = tableViewController?.timeWork
            let rest = tableViewController?.timeRest
            let cycles = tableViewController?.roundsCount
            let tabatas = tableViewController?.cyclesCount
            
            let c = TabataInfo(prepareSec: prepare!, workSec: work!, restSec: rest!, cycles: cycles!, tabatas: tabatas!)

            timerViewController.startTimer(config: c)
        }
        
        isTimerActive = !isTimerActive
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.updateLayoutAnimation()
        }, completion: nil)
        
        tableViewController?.saveDefaults()
    }
    
    func updateLayoutAnimation() {
        if isTimerActive {
            containerView.frame.origin.x = containerView.frame.width
            timerViewController.view.frame.origin.x = 0
            // red
            // buttonStart.backgroundColor = UIColor.init(red: 227/255, green: 38/255, blue: 54/255, alpha: 1.0)
            buttonStart.backgroundColor = UIColor.init(red: 82/255, green: 82/255, blue: 82/255, alpha: 1.0)
            buttonStart.setTitle("Stop".localized, for: .normal)
        } else {
            containerView.frame.origin.x = 0
            timerViewController.view.frame.origin.x = -timerViewController.view.frame.width
            // green
            buttonStart.backgroundColor = UIColor.init(red: 0/255, green: 144/255, blue: 81/255, alpha: 1.0)
            buttonStart.setTitle("Start".localized, for: .normal)
        }
    }
    
    func createTimerController() {
        timerViewController = storyboard?.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
        timerViewController.delegate = self
        addChildViewController(timerViewController)
        view.addSubview(timerViewController.view)
        
        timerViewController.view.frame = containerView.frame
        timerViewController.view.frame.origin.x = -timerViewController.view.frame.width
        // timerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timerViewController.didMove(toParentViewController: self)
        containerView.autoresizingMask = []
        containerView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    @IBAction func buttonSoundTap(_ sender: Any) {
        let enabled = !UserDefaults.standard.bool(forKey: "timer-sound-enabled")
        UserDefaults.standard.set(enabled, forKey: "timer-sound-enabled")
        let img = enabled ? UIImage(named: "sound-on") : UIImage(named: "sound-off")
        buttonSound.setImage(img, for: .normal)
    }
    
}

extension TabataViewController: TimerViewDelegate {
    func timerFinished() {
        buttonStart(self)
    }
}

// AdMob
extension TabataViewController: GADBannerViewDelegate {
    // MARK: -  ADMOB BANNER
    func initAdMobBanner() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 60)
        }
        
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        // request.testDevices = [ "d4baa6301592705346fee4a9bd374c6d" ]
        
        adMobBannerView.load(request)
    }
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: UIApplication.shared.statusBarFrame.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        hideBanner(adMobBannerView)
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}
