# Parallel Sequence for Swift. 

Use to achieve better performance on mutations and sequence transformations.  
Catch all errors with information about the occurrence interval.
## Implemented

- Array
  - Parallel filter 
  - Parallel map
  - Parallel async filter
  - Parallel async map

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

## Usage
### Array
#### Filter

```swift
import Octopus

let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
let result = exampleArray.parallel().filter{ $0 == 21 }

// .. With a limit of threads to execute.

let result = exampleArray
    .parallel()
    .filter(requiredNumber: 4){ $0 == 21 } //from 2 to all active (default all active)
    
// .. With priority for execution.
    
let result = exampleArray
    .parallel()
    .filter(priority: .utility){ $0 == 21 } //default userInteractive
    
// .. Error processing.  

do {
    let result = try self.exampleArray.parallel().filter { item in
        if item == 0 {
            throw MyError.example
        } else {
            return item == 21
        }
    }
} catch {
    print(error) //prints all errors to the console
}

// .. Async without errors.

let result = await self.exampleArray.parallel().filter{ $0 == 21 }

// .. Async with errors.

do {
    let result = try await self.exampleArray.parallel().filter{ item throws -> Bool in
        if item == 0 {
            throw MyError.example
        } else {
             return item == 21
        }
    }
}
catch {
    print(error) //prints all errors to the console
}

```


#### Map

```swift
import Octopus

let exampleArray: [Int] = [5, 8, 13, 21, 34, 55, 89 ]
let result: [String] = exampleArray.parallel().map{ "\($0)" }

// .. With a limit of threads to execute.

let result: [String] = exampleArray
    .parallel()
    .map(requiredNumber: 4){ "\($0)" } //from 2 to all active (default all active)
    
// .. With priority for execution.
    
let result: [String] = exampleArray
    .parallel()
    .map(priority: .utility){ "\($0)" } //default userInteractive
    
// .. Error processing.  

do {
    let result: [String] = try self.exampleArray.parallel().map { item in
        if item == 0 {
            throw MyError.example
        } else {
            return "\(item)"
        }
    }
} catch {
    print(error) //prints all errors to the console
}

// .. Async without errors.

let result: [String] = await self.exampleArray.parallel().map{ "\($0)" }

// .. Async with errors.

do {
    let result: [String] = try await self.exampleArray.parallel().map{ item throws -> String in
       if item == 0 {
            throw MyError.example
        } else {
            return "\(item)"
        }
    }
} catch {
    print(error) //prints all errors to the console
}

```