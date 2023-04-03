/*
 
 File: App.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
*/

import SwiftUI

@main
struct _App: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List{
                    NavigationLink("ErrorFilterView") {
                        ErrorFilterView()
                    }
                    NavigationLink("PerfomanceFilterView") {
                        PerfomanceFilterView()
                    }
                }
            }
        }
    }
}
