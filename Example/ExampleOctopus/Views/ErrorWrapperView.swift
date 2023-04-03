/*
 
 File: ErrorWrapperView.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import SwiftUI

struct ErrorWrapperView: View {
    let label: String
    let isShowedContent: Bool
    let multipleTask: () throws -> ()
    let aloneTask: () throws -> ()
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.3)
            if self.isShowedContent {
                self.content
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }
    
    var content: some View {
        ZStack{
            Color.gray.opacity(0.3)
            VStack(spacing: 30){
                Button("\(self.label) - multiple"){
                    self.work(multiple: true)
                }
                Button("\(self.label) - alone"){
                    self.work(multiple: false)
                }
            }
        }
    }
    
    func work(multiple: Bool){
        if multiple {
            do {
                try self.multipleTask()
            } catch {
                print(error)
            }
        } else {
            do {
                try self.aloneTask()
            } catch {
                print(error)
            }
        }
    }
}
