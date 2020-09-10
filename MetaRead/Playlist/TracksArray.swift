import Foundation

let ascendingIntComparator: (Int, Int) -> Bool = {$0 < $1}
let descendingIntComparator: (Int, Int) -> Bool = {$0 > $1}

extension Array where Element: Equatable {
    
    var lastIndex: Int {
        return count - 1
    }
    
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    mutating func addItem(_ item: Element) -> Int {
        
        self.append(item)
        return lastIndex
    }
    
    mutating func addItems(_ items: [Element]) -> ClosedRange<Int> {
        
        let firstIndex: Int = self.count
        self.append(contentsOf: items)
        
        return firstIndex...self.lastIndex
    }
    
    mutating func removeItem(at index: Int) -> Element? {
        return indices.contains(index) ? self.remove(at: index) : nil
    }
    
    mutating func removeItem(_ item: Element) -> Int? {
        
        if let index = self.firstIndex(of: item) {
            
            self.remove(at: index)
            return index
        }
        
        return nil
    }
    
    mutating func removeItems(at indices: IndexSet) -> [Element] {
        
        return indices.sorted(by: descendingIntComparator)
            .compactMap {self.indices.contains($0) ? self.remove(at: $0) : nil}
    }
    
    mutating func removeItems(_ items: [Element]) -> IndexSet {

        // Collect and sort indices before removing items
        let indices: [Int] = items.compactMap {self.firstIndex(of: ($0))}
                                    .sorted(by: descendingIntComparator)
        
        indices.forEach({self.remove(at: $0)})
        
        return IndexSet(indices)
    }
    
    mutating func removeAndInsertItem(from sourceIndex: Int, at destinationIndex: Int) {
        self.insert(self.remove(at: sourceIndex), at: destinationIndex)
    }
    
    mutating func moveItemUp(from index: Int) -> Int {

        swapAt(index, index - 1)
        return index - 1
    }
    
    mutating func moveItemDown(from index: Int) -> Int {

        swapAt(index, index + 1)
        return index + 1
    }
    
    mutating func moveItemsUp(_ items: [Element]) -> [Int: Int] {
        return moveItemsUp(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }

    mutating func moveItemsUp(from indices: IndexSet) -> [Int: Int] {
        
        // Indices need to be in ascending order, because items need to be moved up, one by one, from top to bottom of the playlist
        // Determine if there is a contiguous block of items at the top of the playlist, that cannot be moved. If there is, determine its size.
        let ascendingOldIndices = indices.sorted(by: ascendingIntComparator)
        let unmovableBlockSize: Int = self.indices.first(where: {!ascendingOldIndices.contains($0)}) ?? 0
        
        guard areAscendingIndicesValid(ascendingOldIndices) && unmovableBlockSize < ascendingOldIndices.count else {return [:]}
        
        let oldIndices = (unmovableBlockSize..<ascendingOldIndices.count).map({ascendingOldIndices[$0]})
        return Dictionary(uniqueKeysWithValues: zip(oldIndices, oldIndices.map {moveItemUp(from: $0)}))
    }
    
    mutating func moveItemsDown(_ items: [Element]) -> [Int: Int] {
        return moveItemsDown(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
    
    mutating func moveItemsDown(from indices: IndexSet) -> [Int: Int] {
        
        // Indices need to be in descending order, because items need to be moved down, one by one, from bottom to top of the playlist
        let descendingOldIndices = indices.sorted(by: descendingIntComparator)
        
        // Determine if there is a contiguous block of items at the bottom of the playlist, that cannot be moved. If there is, determine its size.
        let indicesReversed = self.indices.reversed()
        let unmovableBlockSize = self.lastIndex - (indicesReversed.first(where: {!descendingOldIndices.contains($0)}) ?? 0)
        
        guard areDescendingIndicesValid(descendingOldIndices) && unmovableBlockSize < descendingOldIndices.count else {return [:]}
        
        let oldIndices = (unmovableBlockSize..<descendingOldIndices.count).map({descendingOldIndices[$0]})
        return Dictionary(uniqueKeysWithValues: zip(oldIndices, oldIndices.map {moveItemDown(from: $0)}))
    }
    
    private func areAscendingIndicesValid(_ indices: [Int]) -> Bool {
        return !indices.isEmpty && indices.first! >= 0 && indices.last! < self.count && indices.count < self.count
    }
    
    private func areDescendingIndicesValid(_ indices: [Int]) -> Bool {
        return !indices.isEmpty && indices.first! < self.count && indices.last! >= 0 && indices.count < self.count
    }
    
    mutating func moveItemsToTop(_ items: [Element]) -> [Int: Int] {
        return moveItemsToTop(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
    
    mutating func moveItemsToTop(from indices: IndexSet) -> [Int: Int] {
        
        let sortedIndices = indices.sorted(by: ascendingIntComparator)
        guard areAscendingIndicesValid(sortedIndices) else {return [:]}

        var results: [Int: Int] = [:]
        
        // Remove from original location and insert at the top, one after another, below the previous one
        // No need to move the item if the original location is the same as the destination
        for (newIndex, oldIndex) in sortedIndices.enumerated().filter({$0.0 != $0.1}) {
            
            self.removeAndInsertItem(from: oldIndex, at: newIndex)
            results[oldIndex] = newIndex
        }
        
        return results
    }
    
    mutating func moveItemsToBottom(_ items: [Element]) -> [Int: Int] {
        return moveItemsToBottom(from:  IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
    
    mutating func moveItemsToBottom(from indices: IndexSet) -> [Int: Int] {
        
        let sortedIndices = indices.sorted(by: descendingIntComparator)
        guard areDescendingIndicesValid(sortedIndices) else {return [:]}
        
        var results: [Int: Int] = [:]

        // Remove from original location and insert at the bottom, one after another, above the previous one
        // No need to move the item if the original location is the same as the destination
        for (newIndex, oldIndex) in sortedIndices.enumerated().map({(self.lastIndex - $0, $1)}).filter({$0.0 != $0.1}) {
            
            self.removeAndInsertItem(from: oldIndex, at: newIndex)
            results[oldIndex] = newIndex
        }
        
        return results
    }
    
    /*
       In response to a playlist reordering by drag and drop, and given source indices, a destination index, and the drop operation (on/above), determines which destination indices the source indexs will occupy.
    */
    mutating func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [Int: Int] {
        
        // The destination indices will depend on whether there are more source items above/below the drop index
        // Find out how many source items are above the dropIndex and how many below
        let dropsAboveDropIndex: Int = sourceIndices.count(in: 0..<dropIndex)
        let dropsBelowDropIndex: Int = sourceIndices.count - dropsAboveDropIndex
        let destinationIndices = [Int]((dropIndex - dropsAboveDropIndex)...(dropIndex + dropsBelowDropIndex - 1))
        
        // Make sure that the source indices are iterated in descending order, because tracks need to be removed from the bottom up.
        // Collect all the tracks into an array for re-insertion later.
        let sourceItems: [Element] = sourceIndices.sorted(by: descendingIntComparator).compactMap {self.removeItem(at: $0)}
        
        // Reverse the source items collection to match the order of the destination indices.
        // For each destination index, copy over a source item into the corresponding destination hole.
        for (sourceItem, destinationIndex) in zip(sourceItems.reversed(), destinationIndices) {
            self.insert(sourceItem, at: destinationIndex)
        }
        
        return Dictionary(uniqueKeysWithValues: zip(sourceIndices.sorted(by: ascendingIntComparator), destinationIndices))
    }
}
