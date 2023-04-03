# Parallel Sequence for Swift. 

Use to achieve better performance on mutations and sequence transformations.  
Catch all errors with information about the occurrence interval.
## Implemented

 - Parallel filter (including rethrow)
 - Parallel map (including rethrow)

<b>Parallel filtering.</b>
```swift
import Octopus

//exampleArray [Int]
let result = exampleArray.parallel().filter{ $0 == 427 }

```

<b>Parallel filtering with error.</b>
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