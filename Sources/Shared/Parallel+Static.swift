/*
 
 Project: Octopus
 File: Array+Parallel+StaticProperties.swift
 Created by: Egor Boyko
 Date: 03.04.2023
 
 Status: #Completed | #Not decorated
 
*/

import Foundation

extension Parallel {
    internal static var instanceWasFreedMessage: String {
        let message = "The instance was freed at run time. "
        let ps = "P/S I don’t know how you did it, but if it happened, please share in the GitHub thread :-)"
        return message + ps
    }
}
