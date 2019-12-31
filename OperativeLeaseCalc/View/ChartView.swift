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

class ChartDateFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .short
        df.dateFormat = "dd.MM"
        return df.string(from: Date.init(timeIntervalSince1970: value))
    }
}

struct ChartView: UIViewRepresentable {
    @ObservedObject var model: AppModel
    
    
    func makeUIView(context: Context) -> LineChartView {
        let v = LineChartView()
        v.borderLineWidth = 0
        v.scaleXEnabled = true
        v.scaleYEnabled = false
        v.drawGridBackgroundEnabled = false
        v.drawMarkers = false
        v.dragXEnabled = true
        v.dragYEnabled = false
        v.highlightPerTapEnabled = false
        v.xAxis.valueFormatter = ChartDateFormatter()
        v.gridBackgroundColor = v.gridBackgroundColor.withAlphaComponent(0.1)
        v.xAxis.labelTextColor = NSUIColor.label
        v.noDataTextColor = NSUIColor.label
        v.leftAxis.labelTextColor = NSUIColor.label
        v.rightAxis.labelTextColor = NSUIColor.label
        v.noDataText = ""
        v.legend.textColor = NSUIColor.label
        return v
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        let lineChartData = LineChartData()
        var realEntries = [ChartDataEntry]()
        var realColors = [NSUIColor]()
        var idealEntries = [ChartDataEntry]()
        
        var lastHistory: History? = nil
        model.history.sorted { (a, b) -> Bool in
            a.date! < b.date!
        }.forEach { (h) in
            if lastHistory == nil {
                lastHistory = h
            } else {
                if Calendar.current.startOfDay(for: h.date!) != Calendar.current.startOfDay(for: lastHistory!.date!) {
                    realEntries.append(ChartDataEntry.init(x: lastHistory!.date!.timeIntervalSince1970, y: Double(lastHistory!.state!)))
                    idealEntries.append(ChartDataEntry.init(x: lastHistory!.date!.timeIntervalSince1970, y: Double(h.idealState(leaseParams: model.leaseParams) ?? 0)))
                    realColors.append(h.isOverlimit(leaseParams: model.leaseParams) ? NSUIColor.red : NSUIColor.green)
                }
                lastHistory = h
            }
        }
        
        let realDataSet = LineChartDataSet(entries: realEntries, label: NSLocalizedString("today.actual.caption", comment: ""))
        realDataSet.circleRadius = 0
        realDataSet.lineWidth = 2
        realDataSet.colors = [NSUIColor.red]
        realDataSet.cubicIntensity = 1
        realDataSet.mode = .horizontalBezier
        realDataSet.drawCirclesEnabled = false
        realDataSet.drawValuesEnabled = false
        realDataSet.valueColors = [NSUIColor.red]
        
        let gradientColors = [UIColor.red.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        realDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        realDataSet.drawFilledEnabled = true // Draw the Gradient
        
        lineChartData.addDataSet(realDataSet)
        
        let idealDataSet = LineChartDataSet(entries: idealEntries, label: NSLocalizedString("today.ideal.caption", comment: ""))
        idealDataSet.colors = [NSUIColor.label]
        idealDataSet.lineWidth = 2
        idealDataSet.cubicIntensity = 1
        idealDataSet.mode = .linear
        idealDataSet.drawCirclesEnabled = false
        idealDataSet.drawValuesEnabled = false
        lineChartData.addDataSet(idealDataSet)
        
        uiView.data = lineChartData
    }
}
