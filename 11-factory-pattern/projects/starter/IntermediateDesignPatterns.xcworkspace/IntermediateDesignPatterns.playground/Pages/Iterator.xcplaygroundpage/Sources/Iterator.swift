//
//  Iterator.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

public protocol Iterator {
    associatedtype Element
    mutating func next() -> Element?
}

/*
 associatedtype cho phép Iterator “linh hoạt” về kiểu phần tử mà nó trả về.
 mutating cho phép Iterator (thường là struct) thay đổi trạng thái bên trong khi duyệt.
 */
