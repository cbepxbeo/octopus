/*
 
 File: PerfomanceMapView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

import SwiftUI
import Octopus

struct PerfomanceMapView: View, ArrayWithFakeElementProvider, TaskToMapProvider {
    @State var text: String = "-"
    @State var array: [Fake] = []
    @State var priority: DispatchQoS.QoSClass = .userInteractive
    
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
                Button("map - default (sync)"){
                    self.mapSync(parallel: false)
                }
                Button("map - parallel (sync)"){
                    self.mapSync(parallel: true)
                }
                Button("map - default (async)"){
                    self.mapAsync(parallel: false)
                }
                Button("map - parallel (async)"){
                    self.mapAsync(parallel: true)
                }
            }
            .onAppear{
                self.array = self.getArrayWithFakeElement()
            }
        }
    }
    
    func mapSync(parallel: Bool){
        if parallel {
            self.text = ""
            let time = ExampleTimer.start()
            let _ = self.array.parallel()
                .map(priority: self.priority, self.fakeTask)
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        } else {
            self.text = ""
            let time = ExampleTimer.start()
            let _ = self.array.map(fakeTask)
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        }
    }
    
    func mapAsync(parallel: Bool){
        if parallel {
            self.text = ""
            DispatchQueue.global().async {
                let time = ExampleTimer.start()
                let _ = self.array.parallel()
                    .map(priority: self.priority, self.fakeTask)
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
                let _ = self.array.map(fakeTask)
                let endTime = time.stop()
                print(endTime)
                DispatchQueue.main.async {
                    self.text = "\(endTime.description)"
                }
            }
        }
    }
}
