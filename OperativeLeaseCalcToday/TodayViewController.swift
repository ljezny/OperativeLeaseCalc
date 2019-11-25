//
//  TodayViewController.swift
//  OperativeLeaseCalcToday
//
//  Created by Lukas Jezny on 23/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var limitLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        limitLabel.text = PersistentStorageManager.shared.loadLeaseParams().actualLimitFormatted
        completionHandler(NCUpdateResult.newData)
    }
    
}
