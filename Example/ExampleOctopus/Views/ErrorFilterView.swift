/*
 
 File: ErrorFilterView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import SwiftUI
import Octopus

struct ErrorFilterView: View, ArrayWithFakeElementProvider {
    @State var array: [Fake] = []
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.3)
            VStack(spacing: 30){
                Button("filter - multiple"){
                    self.filter(multiple: true)
                }
                Button("filter - alone"){
                    self.filter(multiple: false)
                }
            }
            .onAppear{
                self.array = self.getArrayWithFakeElement()
            }
        }
    }
    
    func filter(multiple: Bool){
        if multiple {
            do {
                let _ = try self.array.parallel().filter { item in
                    if item.string == "error" {
                        throw ExampleError.example
                    } else {
                        return true
                    }
                }
            } catch {
                print(error)
            }
        } else {
            do {
                let _ = try self.array.parallel().filter { item in
                    if item.int == 10 && item.string == "error" {
                        throw ExampleError.example
                    } else {
                        return true
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
