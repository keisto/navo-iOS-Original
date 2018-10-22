//
//  SettingsViewController.swift
//  navo
//
//  Created by Tony Keiser on 5/7/18.
//  Copyright © 2018 Tony Keiser. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(request)
    }
}
