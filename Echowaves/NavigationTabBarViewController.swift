//
//  NavigationTabBarViewController.swift
//  Echowaves
//
//  Created by D on 11/19/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class NavigationTabBarViewController : UITabBarController {
    
    @IBAction func takePicture(sender: AnyObject?) {
        NSLog("taking picture")
        
        self.selectedIndex = 1 // select waving controller
        APP_DELEGATE.wavingViewController!.takePicture(self)
    }
    
    @IBOutlet weak var waveAllButton: UIButton!
    
    @IBAction func waveButtonClicked(sender: AnyObject) {
        let pickAWaveViewController = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("PickAWaveForUpload") as PickWavesForUploadViewController
        self.navigationController?.pushViewController(pickAWaveViewController, animated: true)
    }
    
//    @IBAction func pushUpload(sender: AnyObject?) {
//        NSLog("pushing upload")
//        APP_DELEGATE.checkForInitialViewToPresent()
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        APP_DELEGATE.checkForInitialViewToPresent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APP_DELEGATE.navigationTabBarViewController = self
    }

    func updateWaveButton() -> Void {
        APP_DELEGATE.getPhotosCountSinceLast({ (count) -> Void in
            self.waveAllButton.setTitle("Wave \(count)", forState: .Normal)
            if count > 0 {
                self.waveAllButton.hidden = false
            } else {
                self.waveAllButton.hidden = true
            }
        })
    }
    
}