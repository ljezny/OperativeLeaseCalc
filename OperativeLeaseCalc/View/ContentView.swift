//
//  ContentView.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 23/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model = AppModel.shared
    @State private var realState: Int?
    
    private var distanceFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.allowsFloats = false
        f.minimum = 0
        f.numberStyle = .none
        return f
    }
    
    var body: some View {
            TabView{
                NavigationView {
                    Form{
                        Section(header: Text("actualstate.header").font(.headline), footer: Text("actualstate.footer").font(.footnote)) {
                            Text("\(model.leaseParams.idealStateFormatted)").font(.largeTitle)
                        }
                        Section(header: Text("realstate.header").font(.headline), footer: Text("realstate.footer").font(.footnote)) {
                            Text(AppModel.shared.realStateFormatted).font(.largeTitle).foregroundColor(model.isOverlimit ? Color.red : Color.green)
                            TextField("realstate.add", value: $realState, formatter: distanceFormatter, onEditingChanged: { (b) in
                            }) {
                                if let state = self.realState {
                                    AppModel.shared.addState(state: state)
                                    self.realState = nil
                                }
                            }.keyboardType(.numbersAndPunctuation)
                        }
                        Section(header: Text("lease.params.header").font(.headline), footer: Text("lease.params.footer").font(.footnote)) {
                            DatePicker(selection: $model.leaseParams.leaseStart, in: ...Date(), displayedComponents: .date) {
                                Text("start.date")
                            }
                            TextField("year.limit", value: $model.leaseParams.yearLimit, formatter: distanceFormatter).keyboardType(.numbersAndPunctuation)
                        }
                        
                    }.navigationBarTitle(Text("general.appname"))
                }.tabItem({
                    Image("tab_note")
                    Text("tab.overview")
                })
                NavigationView {
                    Form{
                        List(AppModel.shared.history) { h in
                            VStack(alignment: .leading) {
                                Text("\(h.dateFormatter.string(from: h.date ?? Date()))").font(.footnote)
                                HStack{
                                    Text("\(h.state ?? 0) km").font(.subheadline).foregroundColor(h.isOverlimit(leaseParams: self.model.leaseParams) ? Color.red : Color.green)
                                    Spacer()
                                    Text("\(h.idealState(leaseParams: self.model.leaseParams) ?? 0) km").font(.subheadline)
                                }
                            }
                        }
                    }.navigationBarTitle(Text("tab.history"))
                }.tabItem({
                    Image("tab_history")
                    Text("tab.history") })
                ChartView(model: model).frame(width: 200, height: 200).navigationBarTitle(Text("Third")).tabItem({
                    Image("tab_graph")
                    Text("tab.history")
                })
                NavigationView {
                    Form{
                        Section(header: Text("notifications.header").font(.headline), footer: Text("notifications.footer").font(.footnote)){
                            Toggle(isOn: $model.notifications) {
                                Text("notifications.enable")
                            }
                        }
                        Section(header: Text("obd.purchase.header").font(.headline), footer: Text("obd.purchase.footer").font(.footnote)) {
                            Button("obd.purchase.action") {
                                UIApplication.shared.open(URL(string: "https://www.sunnysoft.cz/zbozi/166PCI-852/autodiagnostika-obd-ii-bluetooth-4-0-nizke-provedeni-ekv-elm-327-pro-android-cz-sw-zdarma.html")!, options: [:], completionHandler: nil)
                            }
                        }
                        Section(header: Text("obd.enable.header").font(.headline), footer: Text("obd.enable.footer").font(.footnote)) {
                            Toggle(isOn: $model.obdEnabled) {
                                Text("obd.enable.toggle")
                            }
                        }
                        Section(header: Text("obd.offset.header").font(.headline), footer: Text("obd.offset.footer").font(.footnote)) {
                            Text(model.lastOBD2StateFormatted)
                            TextField("obd.offset", value: $model.leaseParams.obdOffset, formatter: distanceFormatter).keyboardType(.decimalPad)
                        }
                    }.navigationBarTitle(Text("tab.settings"))
                }.tabItem({
                    Image("tab_settings")
                    Text("tab.settings")
                })
        }.accentColor(Color.red)
        //}.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
