
// Node trong linked list
public class Node<T> {
    public var value: T
    public var next: Node?
    
    public init(_ value: T, _ next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

// Collection dạng linked list
public class LinkedList<T> {
    public var head: Node<T>?
    
    public init(head: Node<T>? = nil) {
        self.head = head
    }
    
    public func makeIterator() -> LinkedListIterator<T> {
        return LinkedListIterator(current: head)
    }
}

// Iterator cho linked list
public struct LinkedListIterator<T>: IteratorProtocol {
    public var current: Node<T>?
    
    mutating public func next() -> T? {
        guard let node = current else { return nil }
        current = node.next
        return node.value
    }
}
