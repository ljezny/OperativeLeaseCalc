//
//  AppReviewer.swift
//  MasterThermEasyControl
//
//  Created by Lukas Jezny on 21/06/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit

import Foundation
import StoreKit

class AppReviewer {
    let RUN_COUNT_KEY = "numberOfRuns"  // UserDefauls dictionary key where we store number of runs
    let minimumRunCount = 2                     // Minimum number of runs that we should have until we ask for review

    private func incrementAppRuns() {                   // counter for number of runs for the app. You can call this from App Delegate
        let runs = getRunCounts() + 1
        UserDefaults().setValue(runs, forKey: RUN_COUNT_KEY)
    }

    private func getRunCounts () -> Int {               // Reads number of runs from UserDefaults and returns it.
        return UserDefaults().integer(forKey: RUN_COUNT_KEY)
    }

    func checkReview() {
        let runs = getRunCounts()
        if (runs > minimumRunCount) {
            SKStoreReviewController.requestReview()
        }
        incrementAppRuns()
    }

}
