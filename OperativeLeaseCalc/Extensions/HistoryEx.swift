//
//  HistoryEx.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 25/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import Foundation
import SwiftUI
extension History: Identifiable {
    public var id:String {
        return self.objectID.uriRepresentation().absoluteString
    }
    
    public var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        return df
    }
    
    public func idealState(leaseParams: LeaseParams) -> Int? {
        return leaseParams.computeIdealState(date: date!)
    }
    
    public func isOverlimit(leaseParams: LeaseParams) -> Bool {
        return (idealState(leaseParams: leaseParams) ?? 0) < Int(truncating: state ?? 0)
    }
}
