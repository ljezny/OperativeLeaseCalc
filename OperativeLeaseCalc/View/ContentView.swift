//
//  ContentView.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 23/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var model = PersistentStorageManager.shared.loadLeaseParams()
    private var history = PersistentStorageManager.shared.loadHistory()
    
    @State var isAdding: Bool = false
    
    @State private var realState: Int? {
        didSet {
            if let realState = self.realState {
              //  self.model.addRealState(realState: realState)
                self.realState = nil
            }
        }
    }
    
    private var yearLimitFormatted: NumberFormatter {
        let f = NumberFormatter()
        f.allowsFloats = false
        f.minimum = 0
        f.numberStyle = .none
        
        return f
    }
    
    var addingRealStateModalView: some View {
        NavigationView {
            VStack{
                Text("Modal")
                TextField("state", value: $realState, formatter: yearLimitFormatted)
            }.navigationBarTitle("xxc")
        }
        
    }
    
    var body: some View {
            TabView{
                NavigationView {
                    Form{
                        Section(header: Text("actualstate.header").font(.subheadline), footer: Text("actualstate.footer").font(.footnote)) {
                            Text("\(model.actualLimitFormatted)").font(.largeTitle)
                        }
                        Section(header: Text("realstate.header").font(.subheadline), footer: Text("realstate.footer").font(.footnote)) {
                            Text("\(model.actualLimitFormatted)").font(.largeTitle)
                            Button("Add") {
                                self.isAdding = true
                            }.sheet(isPresented: $isAdding, content: {
                                self.addingRealStateModalView
                            })
                        }
                        Section(header: Text("lease.params.header").font(.subheadline), footer: Text("lease.params.footer").font(.footnote)){
                            DatePicker(selection: $model.leaseStart, in: ...Date(), displayedComponents: .date) {
                                Text("start.date")
                            }
                            TextField("year.limit", value: $model.yearLimit, formatter: yearLimitFormatted)
                        }
                        Section(header: Text("notifications.header").font(.subheadline), footer: Text("notifications.footer").font(.footnote)){
                            Toggle(isOn: $model.notifications) {
                                Text("notifications.enable")
                            }
                        }
                    }.navigationBarTitle(Text("aa"))
                }.tabItem({ Text("First") })
                NavigationView {
                    List(history) { h in
                        VStack {
                            Text("\(h.state ?? 0) km").font(.body)
                            Text("\(h.date ?? Date())").font(.footnote)
                        }
                    }.navigationBarTitle(Text("Third")).navigationBarItems(trailing:
                            Button("Add") {
                                self.isAdding = true
                            }.sheet(isPresented: $isAdding, content: {
                                self.addingRealStateModalView
                            }))
                }.tabItem({ Text("Second") })
                NavigationView {
                    Form{
                        List {
                            Text("Hello world")
                            Text("Hello world")
                            Text("Hello world")
                        }
                    }.navigationBarTitle(Text("Third"))
                }.tabItem({ Text("Third") })
            }
        //}.navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
