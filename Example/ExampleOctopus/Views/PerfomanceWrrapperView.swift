/*
 
 File: PerfomanceWrrapperView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

import SwiftUI
import Octopus

struct PerfomanceWrrapperView: View {
    @State var text: String = "-"
    @Binding var priority: DispatchQoS.QoSClass
    
    let label: String
    let isShowedContent: Bool
    let parallelTask: () -> ()
    let defaultTask: () -> ()

    var body: some View {
        ZStack{
            Color.gray.opacity(text == "" ? 0.3 : 0.7)
            
            if self.isShowedContent {
                self.content
            } else {
                ProgressView()
            }
      
            ZStack{
                Color.black.opacity(0.3)
                ProgressView()
            }
            .opacity(self.text == "" ? 1 : 0)
            .animation(.spring(), value: self.text)
        }
        .ignoresSafeArea()
    }
    
    var content: some View {
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
            Button("\(self.label) - parallel (async)"){
                self.async(parallel: true)
            }
            Button("\(self.label) - default (async)"){
                self.async(parallel: false)
            }
            Button("\(self.label) - parallel (sync)"){
                self.sync(parallel: true)
            }
            Button("\(self.label) - default (sync)"){
                self.sync(parallel: false)
            }
        }
    }
    
    func sync(parallel: Bool){
        if parallel {
            self.text = ""
            let time = ExampleTimer.start()
            self.parallelTask()
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        } else {
            self.text = ""
            let time = ExampleTimer.start()
            self.defaultTask()
            let endTime = time.stop()
            print(endTime)
            self.text = "\(endTime.description)"
        }
    }
    
    func async(parallel: Bool){
        if parallel {
            self.text = ""
            DispatchQueue.global().async {
                let time = ExampleTimer.start()
                self.parallelTask()
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
                self.defaultTask()
                let endTime = time.stop()
                print(endTime)
                DispatchQueue.main.async {
                    self.text = "\(endTime.description)"
                }
            }
        }
    }
}
