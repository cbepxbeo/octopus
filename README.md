# Parallel Collection for Swift. 

Use to achieve better performance on filtering and sequence transformations.  
Catch all errors with information about the occurrence interval.
## Implemented

- Array
  - Parallel filter 
  - Parallel map
  - Parallel async filter
  - Parallel async map
- Dictionary
  - Parallel filter
  - Parallel map
  - Parallel async filter
  - Parallel async map

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Octopus as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

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

#### Map
The use makes sense if the transformation condition requires additional calculations, such as a nested loop. Otherwise, single-threaded dictionary conversion will be faster because it doesn't require a merge. The efficiency of work in relation to the complexity of nested calculations is directly proportional to the size of the dictionary - the larger the size, the less complexity is required to meet the conditions for achieving maximum performance.


```swift
import Octopus

var dictionary: [Int: String] = [:]
let end = 100
for i in 0...end{
    dictionary[i] = "\(i)"
    for z in 0...end{
        let value = z + (i * end)
        dictionary[value] = "\(value)"
    }
}

func mapTask() -> ((key: Int, value: String)) -> String{
    return {
        var temp: Int = $0.key
        for item in 1...5 {
            temp += item
        }
        return "\(temp)"
    }
}

let defaultResult = dictionary.map(self.mapTask())
let parallelResult = dictionary.parallel().map(self.mapTask()) //More efficient

//....

let defaultResult = dictionary.map{ "\($0.key)" } //More efficient
let parallelResult = dictionary.parallel().map{ "\($0.key)" } 

```

The rest of the possibilities are similar to the array method.

###Features of use

When using, do not forget that the main use is related to offloading complex calculations. Each method creates queues and delegates its execution, which means that it is not worth investing in parallel computing, other parallel computing, you will get an explosion of threads and the execution time will only get worse.   

Let's consider the task. We need to filter the arrays nested in the dictionary, consisting of names. By a certain coincidence of the first letters.

```swift

let names: [String] = [
    "Adam",     "Abraham",
    "Bernard",  "Brian",
    "Caleb",    "Carl",
    "Daniel",   "Derek",
    "Eric",     "Ernest",
    "Felix",    "Frederick",
    "Gabriel",  "Gregory",
    "Harry",    "Henry",
    "Jack",     "Jacob",
    "Kurt",     "Kyle",
    "Lucas",    "Leonard",
    "Marcus",   "Martin",
    "Scott",    "Simon",
    "Travis",   "Tyler",
    "Wayne",    "Winston",
]

```

Let's prepare a dictionary

```swift

let namesWithZ = names + ["Zachary"]
let namesWithO = names + ["Oliver"]
let namesWithZAndO = namesWithZ + ["Oliver"]

var dictionary: [Int: [String]] = [:]

for item in 1...100 {
    if item % 3 == 0 {
        dictionary[item] = namesWithZ
    } else if item % 2 == 0 {
        dictionary[item] = namesWithO
    } else {
        dictionary[item] = namesWithZAndO
    }
}

```

Standard usage

```swift

let defaultResult = dictionary.filter { element in
    let uppercased = element.value.map { string in
        string.uppercased()
    }
    let namesWithZ = uppercased.filter { string in
        if let ch = string.first {
            return ch == "Z"
        }
        return false
    }
    
    if namesWithZ.count == 0 {
        return false
    }
    let namesWithO = uppercased.filter { string in
        if let ch = string.first {
            return ch == "O"
        }
        return false
    }
    return namesWithO.count != 0
}

```

Parallel use

With all the overhead, parallel filtering will run one and a half to two times faster.

```swift

let parallelResult = dictionary.parallel().filter { element in
    let uppercased = element.value.map { string in
        string.uppercased()
    }
    let namesWithZ = uppercased.filter { string in
        if let ch = string.first {
            return ch == "Z"
        }
        return false
    }
    
    if namesWithZ.count == 0 {
        return false
    }
    let namesWithO = uppercased.filter { string in
        if let ch = string.first {
            return ch == "O"
        }
        return false
    }
    return namesWithO.count != 0
}

```

  

<b>If you nest parallel tasks in other parallel tasks, the method will do its job hundreds of times slower</b>

```swift

let multiParallelResult = dictionary.parallel().filter { element in
    let uppercased = element.value.parallel().map { string in
        string.uppercased()
    }
    let namesWithZ = uppercased.parallel().filter { string in
        if let ch = string.first {
            return ch == "Z"
        }
        return false
    }
    
    if namesWithZ.count == 0 {
        return false
    }
    let namesWithO = uppercased.parallel().filter { string in
        if let ch = string.first {
            return ch == "O"
        }
        return false
    }
    return namesWithO.count != 0
}

//This implementation is erroneous.

```
Similar to nesting, running parallel computations within standard computations that are fast and iterate many times will result in performance degradation.

```swift

let subParallelResult = dictionary.filter { element in
    let uppercased = element.value.parallel().map { string in
        string.uppercased()
    }
    let namesWithZ = uppercased.parallel().filter { string in
        if let ch = string.first {
            return ch == "Z"
        }
        return false
    }
    
    if namesWithZ.count == 0 {
        return false
    }
    let namesWithO = uppercased.parallel().filter { string in
        if let ch = string.first {
            return ch == "O"
        }
        return false
    }
    return namesWithO.count != 0
}

//This implementation is erroneous.

```