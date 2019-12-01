//
//  ChartViewRepresentable.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 30/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI
import Charts

struct ChartView: UIViewRepresentable {
    @ObservedObject var model: AppModel
    
    func makeUIView(context: Context) -> LineChartView {
        let v = LineChartView()
        
        return v
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        let lineChartData = LineChartData()
        var entries = [ChartDataEntry]()
        let dataSet = LineChartDataSet(entries: entries, label: "aa")
        
        var i = 0
        model.history.forEach { (h) in
           // entries.append(ChartDataEntry.init(x: h.date!.timeIntervalSinceNow, y: Double(h.state!)))
            entries.append(ChartDataEntry.init(x: Double(i), y: Double(i)))
            i += 1
        }
        dataSet.colors = [NSUIColor.blue]
        lineChartData.addDataSet(dataSet)
        uiView.data = lineChartData
    }
}
