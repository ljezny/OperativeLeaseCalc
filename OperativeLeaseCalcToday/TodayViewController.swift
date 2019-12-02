//
//  TodayViewController.swift
//  OperativeLeaseCalcToday
//
//  Created by Lukas Jezny on 23/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftUI
import AppCenter
import AppCenterCrashes

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var idealCaption: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var actualCaption: UILabel!
    @IBOutlet weak var actualLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MSAppCenter.start("6bf308eb-2b84-40bd-b6b0-432d1032595d", withServices:[
          MSCrashes.self
        ])
        
        idealCaption.text = NSLocalizedString("today.ideal.caption", comment: "")
        actualCaption.text = NSLocalizedString("today.actual.caption", comment: "")
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        limitLabel.text = AppModel.shared.leaseParams.idealStateFormatted
        actualLabel.text = AppModel.shared.realStateFormatted
        actualLabel.textColor = AppModel.shared.isOverlimit ? UIColor.red : nil
        completionHandler(NCUpdateResult.newData)
    }
    
}
