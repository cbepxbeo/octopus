//
//  File.swift
//  
//
//  Created by Егор Бойко on 06.04.2023.
//

import Foundation

import OSLog

fileprivate let logger: Logger = .init(
    subsystem: "octopus",
    category: "parallel-dictionary-method-filter"
)

extension Parallel {
    
    public func filter<Key: Hashable, Value>(
        requiredNumber threads: Int? = nil,
        priority: DispatchQoS.QoSClass = .userInteractive,
        _ isIncluded: @escaping (Key) throws -> Bool
    ) rethrows -> [Key: Value] where StructureData == Dictionary<Key, Value> {
        
        return try _filter(requiredNumber: threads, priority: priority, isIncluded: isIncluded, rethrow)
        
        func rethrow(error: Error) throws ->() {
            throw error
        }
        
        func _filter(
            requiredNumber threads: Int?,
            priority: DispatchQoS.QoSClass,
            isIncluded: @escaping (Key) throws -> Bool,
            _ rethrow: (_ error: Error) throws -> ()
        ) rethrows -> [Key: Value] {
            if self.structureData.isEmpty {
                return [:]
            }
            
            if self.structureData.count < self.amountThreads(threads) * 2 {
                logger.debug("Not enough for parallel computing")
                return try structureData.filter{ try isIncluded($0.0) }
            }
            
            let resultUpdateQueue = DispatchQueue(label: "--", attributes: .concurrent)
            var storage: [Int:  [Slice<Dictionary<Key, Value>>.Element]] = [:]
            var storage2: Dictionary<Key, Value> = [:]
            let structureDataStartIndex = self.structureData.startIndex
            let group = DispatchGroup()
            var errors: [(String, Error)] = []
            
            self.parallelize(
                amountThreads: self.amountThreads(threads),
                group: group, priority: priority
            ) { [weak self] iteration, start, end in
                guard let parallel = self else {
                    errors.append((Self.instanceWasFreedMessage, OctopusError.unexpectedState))
                    group.leave()
                    return
                }
                logger.debug("Вычисляю срез - \(iteration)")
                let slice: Dictionary<Key, Value>.SubSequence
                let iterationIndex = parallel.structureData.index(structureDataStartIndex, offsetBy: end)

                if iteration == 1 {
                    slice = parallel.structureData.prefix(parallel.sliceData.step)
                } else if iteration != parallel.amountThreads(threads) {
                    let temp = parallel.structureData.prefix(through: iterationIndex)
                    //print("===\(iteration)")
                    //print(temp)
                    slice = temp.suffix(parallel.sliceData.step)
                } else {
                    let temp = parallel.structureData.prefix(through: iterationIndex)
                    slice = temp.suffix(parallel.sliceData.remainder + parallel.sliceData.step)
                }
                logger.debug("Вычислил - \(iteration)")
                //print("===\(iteration)")
                //print(slice.map{ $0.value })
                
                do {
                    let output = try slice.filter{ try isIncluded($0.key) }
                    parallel.insertQueue.async {
                        //storage[iteration] = output
                        logger.debug("Выполняю мердж - \(iteration)")
                        storage2.merge(output) { (current, _) in current }
                        logger.debug("Выполнил - \(iteration)")
                        group.leave()
                    }
                    
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        resultUpdateQueue.sync(flags: .barrier) {
//                            storage2.merge(output) { (current, _) in current }
//                            group.leave()
//                        }
//                    }
                }
                catch {
                    parallel.insertQueue.async {
                        let message = "method: filter, element: \(Element.self), slice: "
                        errors.append((message, error))
                        group.leave()
                    }
                }
                
          
                
//                do {
////                    if iteration == 1 {
////                        let sliceA = parallel.structureData.suffix(from: <#T##Dictionary<Hashable, Value>.Index#>)
////                    }
////                    let needIndex = parallel.structureData.index(structureDataStartIndex, offsetBy: slice.min())
//
////                    parallel.insertQueue.async {
////                        storage[iteration] = dictoinary
////                        group.leave()
////                    }
//                } catch {
//                    parallel.insertQueue.async {
//                        let message = "method: filter, element: \(Element.self), slice: "
//                        errors.append((message, error))
//                        group.leave()
//                    }
//                }
            }
            group.wait()
            
            if !errors.isEmpty {
                if errors.count > 1 {
                    try rethrow(OctopusError.multiple(errors: errors))
                } else if let first = errors.first {
                    try rethrow(OctopusError.alone(message: first.0, error: first.1))
                }
            }
            
//            var storage3: Dictionary<Key, Value> = [:]
//            var storage4: Dictionary<Key, Value> = [:]
//
//            let to2 = DispatchQueue(label: "sdf")
//            let to4 = DispatchQueue(label: "sdf")
//
//            let groupdd = DispatchGroup()
//
//            for item in 1...storage.count {
//                if item % 2 == 0 {
//                    groupdd.enter()
//                    to2.async {
//                        storage3.merge(storage[item]!){ (current, _) in current }
//                        groupdd.leave()
//                    }
//                } else {
//                    groupdd.enter()
//                    to4.async {
//
//                        storage4.merge(storage[item]!){ (current, _) in current }
//                        groupdd.leave()
//                    }
//                }
//            }
//            groupdd.wait()
//
//            storage3.merge(storage4){ (current, _) in current }
//            return storage3
            //print(storage2.randomElement())
            
            return storage2
//            return storage.reduce([:], { x, y in
//                var temp = x
//                temp.merge(y.value){ (current, _) in current }
//                return temp
//            })
        }
    }
}
