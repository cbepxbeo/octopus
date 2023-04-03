# Parallel Sequence for Swift. 

Use to achieve better performance on mutations and sequence transformations.  
Catch all errors with information about the occurrence interval.
## Implemented

 - Parallel filter
 - Parallel map

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.


## Usage

### Filter
<b>Parallel.</b>
```swift
import Octopus

//exampleArray [Int]
let result = exampleArray.parallel().filter{ $0 == 427 }

```

<b>With a limit of threads to execute.</b>
```swift
import Octopus

//exampleArray [Int]
let result = exampleArray
    .parallel()
    .filter(requiredNumber: 4){ $0 == 427 } //from 2 to 6, default all active

```

<b>With priority for execution.</b>
```swift
import Octopus

//exampleArray [Int]
let result = exampleArray
    .parallel()
    .filter(priority: .utility){ $0 == 427 } //default userInteractive

```

<b>Error processing.</b>
```swift
import Octopus

//exampleArray [Int]
do {
    let result = try self.exampleArray.parallel().filter { item in
        if item == 0 {
            throw MyError.example
        } else {
            return true
        }
    }
} catch {
    print(error) //prints all errors to the console
}

```

### Map
<b>Parallel.</b>
```swift
import Octopus

//exampleArray [Int]
let result: [String] = exampleArray.parallel().map{ "\($0)" }

```

<b>With a limit of threads to execute.</b>
```swift
import Octopus

//exampleArray [Int]
let result: [String] = exampleArray
    .parallel()
    .map(requiredNumber: 4){ "\($0)" } //from 2 to 6, default all active

```

<b>With priority for execution.</b>
```swift
import Octopus

//exampleArray [Int]
let result: [String] = exampleArray
    .parallel()
    .map(priority: .utility){ "\($0)" } //default userInteractive

```

<b>Error processing.</b>
```swift
import Octopus

//exampleArray [Int]
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

```
