/*
 
 File: ErrorMapView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import SwiftUI
import Octopus

struct ErrorMapView: View, ArrayWithFakeElementProvider {
    @State var array: [Fake] = []
    
    var body: some View {
        ErrorWrapperView(
            label: "Map",
            isShowedContent: !self.array.isEmpty,
            multipleTask: multipleTask,
            aloneTask: aloneTask
        )
        .onAppear{
            self.array = self.getArrayWithFakeElement()
        }
    }
    
    func multipleTask() throws {
        let _ = try self.array.parallel().filter { item in
            if item.string == "error" {
                throw ExampleError.example
            } else {
                return true
            }
        }
    }
    
    func aloneTask() throws {
        let _ = try self.array.parallel().filter { item in
            if item.int == 10 && item.string == "error" {
                throw ExampleError.example
            } else {
                return true
            }
        }
    }
    
}
