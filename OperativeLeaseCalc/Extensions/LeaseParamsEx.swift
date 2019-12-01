//
//  LeaseParamsEx.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 25/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import Foundation

extension LeaseParams {
    
    func computeIdealState(date: Date) -> Int? {
        let calendar = Calendar.current
        
        guard let startDate = startDate else {
            return nil
        }
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents(Set<Calendar.Component>.init(arrayLiteral: .day), from: date1, to: date2)
               
        let dayLimit = Int(yearLimit ?? 0) / 365
        return Int(components.day! * dayLimit)
    }
    
    var idealState: Int? {
        computeIdealState(date: Date())
    }
    
    var idealStateFormatted: String {
        return "\(idealState ?? 0) km"
    }
    
    var leaseStart:Date {
        get{
            return startDate ?? Date()
        }
        set(v){
            startDate = v
        }
    }
    
}

