/*
 
 File: PerfomanceFilterView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import Foundation

import SwiftUI
import Octopus

struct PerfomanceFilterView: View, ArrayWithFakeElementProvider, TaskToFilterProvider {
    @State var array: [Fake] = []
    @State var priority: DispatchQoS.QoSClass = .userInteractive
    
    var body: some View {
        PerfomanceWrrapperView(
            priority: $priority,
            label: "Filter",
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
            .filter(priority: self.priority, self.fakeTaskToFilter)
    }
    
    func defaultTask(){
        let _ = self.array.filter(fakeTaskToFilter)
    }
}
