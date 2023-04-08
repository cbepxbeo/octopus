/*
 
 Project: Octopus
 File: Parallel+Dictionary+Method+DictoinarySlice.swift
 Created by: Egor Boyko
 Date: 08.04.2023
 
 Status: #In progress | #Not decorated
 
*/

import Foundation


extension Parallel {
    internal func dictoinarySlice<Key: Hashable, Value>(
        iteration: Int,
        end: Int,
        requiredNumber threads: Int
    ) -> Dictionary<Key, Value>.SubSequence
    where StructureData == Dictionary<Key, Value>{
        let currentIndex = self.structureData.index(self.structureData.startIndex, offsetBy: end)
        
        if iteration == 1 {
            return self.structureData.prefix(self.sliceData.step)
        } else if iteration != threads {
            let temp = self.structureData.prefix(through: currentIndex)
            return temp.suffix(self.sliceData.step)
        } else {
            let temp = self.structureData.prefix(through: currentIndex)
            return temp.suffix(self.sliceData.remainder + self.sliceData.step)
        }
    }
}
