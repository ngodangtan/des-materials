//
//  ArrayNums.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

// 2. Collection có thể trả về iterator
public struct NumberCollection {
    let numbers: [Int]
    
    public init(numbers: [Int]) {
        self.numbers = numbers
    }
    
    public func makeIterator() -> NumberIterator {
        return NumberIterator(numbers: numbers)
    }
}

// 3. Iterator cụ thể
public struct NumberIterator: Iterator {
    private let numbers: [Int]
    private var index = 0
    
    public init(numbers: [Int]) {
        self.numbers = numbers
    }
    
    mutating public func next() -> Int? {
        guard index < numbers.count else { return nil }
        defer { index += 1 }
        return numbers[index]
    }
}
