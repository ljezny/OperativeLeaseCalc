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
    @IBOutlet weak var idealCaption: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var actualCaption: UILabel!
    @IBOutlet weak var actualLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idealCaption.text = NSLocalizedString("today.ideal.caption", comment: "")
        actualCaption.text = NSLocalizedString("today.actual.caption", comment: "")
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        limitLabel.text = PersistentStorageManager.shared.loadLeaseParams().actualLimitFormatted
        actualLabel.text = AppModel.shared.realStateFormatted
        completionHandler(NCUpdateResult.newData)
    }
    
}
