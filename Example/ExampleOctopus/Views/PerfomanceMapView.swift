/*
 
 File: PerfomanceMapView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

import SwiftUI
import Octopus

struct PerfomanceMapView: View, ArrayWithFakeElementProvider, TaskToMapProvider {
    @State var array: [Fake] = []
    @State var priority: DispatchQoS.QoSClass = .userInteractive
    
    var body: some View {
        PerfomanceWrrapperView(
            priority: $priority,
            label: "Map",
            isShowedContent: !self.array.isEmpty,
            parallelTask: parallelTask,
            defaultTask: defaultTask
        )
        .onAppear{
            DispatchQueue.global(qos: .userInteractive).async {
                let array = self.getArrayWithFakeElement()
                DispatchQueue.main.async {
                    self.array = array
                }
            }
        }
    }
    
    func parallelTask(){
        let _ = self.array.parallel()
            .map(priority: self.priority, self.fakeTaskToMap)
    }
    
    func defaultTask(){
        let _ = self.array.map(self.fakeTaskToMap)
    }
    
}
