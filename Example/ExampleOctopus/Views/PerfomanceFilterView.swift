/*
 
 File: PerfomanceFilterView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

import SwiftUI
import Octopus

struct PerfomanceFilterView: View, ArrayWithFakeElementProvider, TaskToFilterProvider {
    @State var text: String = "-"
    @State var array: [Fake] = []
    @State var priority: DispatchQoS.QoSClass = .utility
    
    var body: some View {
        ZStack{
            Color.gray.opacity(text == "" ? 0.3 : 0.7)
            VStack(spacing: 30){
                Text(self.text)
                Picker("Priority", selection: $priority) {
                    Text("utility")
                        .tag(DispatchQoS.QoSClass.utility)
                    Text("userInteractive")
                        .tag(DispatchQoS.QoSClass.userInteractive)
                    Text("userInitiated")
                        .tag(DispatchQoS.QoSClass.userInitiated)
                    Text("unspecified")
                        .tag(DispatchQoS.QoSClass.unspecified)
                    Text("background")
                        .tag(DispatchQoS.QoSClass.background)

                }
                Button("filter - default (sync)"){
                    self.filterSync(parallel: false)
                }
                Button("filter - parallel (sync)"){
                    self.filterSync(parallel: true)
                }
                Button("filter - default (async)"){
                    self.filterAsync(parallel: false)
                }
                Button("filter - parallel (async)"){
                    self.filterAsync(parallel: true)
                }
            }
            .onAppear{
                self.array = self.getArrayWithFakeElement()
            }
        }
    }
    
    func filterSync(parallel: Bool){
        if parallel {
            self.text = ""
            let time = ExampleTimer.start()
            let _ = self.array.parallel()
                .filter(priority: self.priority, self.fakeTask)
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        } else {
            self.text = ""
            let time = ExampleTimer.start()
            let _ = self.array.filter(fakeTask)
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        }
    }
    
    func filterAsync(parallel: Bool){
        if parallel {
            self.text = ""
            DispatchQueue.global().async {
                let time = ExampleTimer.start()
                let _ = self.array.parallel()
                    .filter(priority: self.priority, self.fakeTask)
                let endTime = time.stop()
                print(endTime)
                DispatchQueue.main.async {
                    self.text = "\(endTime.description)"
                }
            }
        } else {
            self.text = ""
            DispatchQueue.global().async {
                let time = ExampleTimer.start()
                let _ = self.array.filter(fakeTask)
                let endTime = time.stop()
                print(endTime)
                DispatchQueue.main.async {
                    self.text = "\(endTime.description)"
                }
            }
        }
    }
}
