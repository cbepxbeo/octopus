# Parallel Sequence for Swift. 

Use to achieve better performance on mutations and sequence transformations.  
Catch all errors with information about the occurrence interval.
## Implemented

- Array
  - Parallel filter 
  - Parallel map
  - Parallel async filter
  - Parallel async map
- Dictionary
  - Parallel filter
  - Parallel async filter

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/cbepxbeo/octopus.git", .upToNextMajor(from: "0.0.1"))
]
```

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

### Dictionary
#### Filter
The use makes sense if the filter condition requires additional calculations, such as a nested loop. Otherwise, single-threaded dictionary filtering will be faster because it doesn't require merging. The efficiency of work in relation to the complexity of nested calculations is directly proportional to the size of the dictionary - the larger the size, the less complexity is needed to satisfy the conditions for achieving maximum performance.  

<b>When using a dictionary, just like with an array, you can specify the required number of threads and the execution priority.</b>

```swift
import Octopus

let arrayA: [Int] = .init(repeating: 10, count: 100)
let arrayB: [Int] = .init(repeating: 20, count: 100)

var dictionary: [Int: [Int]] = [:]
for item in 0...1000 {
    dictionary[item] = item % 2 == 0 ? arrayA : arrayB
}

// Up to two times faster execution speed

let result = dictionary.parallel().filter {
    $0.value.reduce(0) { $0 + $1 } > 1000
}

// .. Error processing.  

do {
    let _ = try dictionary.parallel().filter {
        if $0.value.reduce(0, { $0 + $1 }) > 1000 {
            throw MyError.example
        } else {
            return true
        }
    }
} catch {
    print(error)
}

// .. Async without errors.

let result = dictionary.parallel().filter {
    $0.value.reduce(0) { $0 + $1 } > 1000
}

// .. Async with errors.

do {
   let _ = try await dictionary.parallel().filter {
       if $0.value.reduce(0, { $0 + $1 }) > 1000 {
           throw MyError.example
       } else {
           return true
       }
   }
} catch {
   print(error) //prints all errors to the console
}

```