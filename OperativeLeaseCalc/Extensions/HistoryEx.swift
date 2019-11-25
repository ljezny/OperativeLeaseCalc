//
//  HistoryEx.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 25/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import Foundation

extension History: Identifiable {
    public var id:String {
        return self.objectID.uriRepresentation().absoluteString
    }
}
