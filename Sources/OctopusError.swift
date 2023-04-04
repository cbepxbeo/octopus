/*
 
 Project: Octopus
 File: OctopusError.swift
 Created by: Egor Boyko
 Date: 02.04.2023
 
 Status: #Completed | #Decorated
 
*/

///Errors when performing parallel operations
public enum OctopusError: Error {
    ///Returns multiple errors (rethrows).
    case multiple(errors: [(String, Error)])
    ///Returns alone error (rethrows).
    case alone(message: String, error: Error)
    ///Used for unexpected state inside package logic
    case unexpectedState
}
