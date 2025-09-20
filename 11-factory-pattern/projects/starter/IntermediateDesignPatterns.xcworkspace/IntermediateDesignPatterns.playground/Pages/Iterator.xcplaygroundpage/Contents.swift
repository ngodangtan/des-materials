/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Iterator
 - - - - - - - - - -
 ![Iterator Diagram](Iterator_Diagram.png)
 
 The Iterator Pattern provides a standard way to loop through a collection. This pattern involves two types:
 
 1. The Swift `Iterable` protocol defines a type that can be iterated using a `for in` loop.
 
 2. A **custom object** you want to make iterable. Instead of conforming to `Iterable` directly, however, you can conform to `Sequence`, which itself conforms to `Iterable`. By doing so, you'll get many higher-order functions, including `map`, `filter` and more, implemented for free for you.
 
 ## Code Example
 */
/*
 1. Iterator Pattern là gì?

 Iterator Pattern là một behavioral pattern, mục tiêu của nó là:
 👉 cung cấp cách duyệt qua các phần tử của một collection mà không cần biết cấu trúc bên trong của collection đó.

 Nói dễ hiểu:

 Bạn có một cái “hộp” chứa nhiều thứ (array, tree, graph…).

 Bạn chỉ muốn duyệt từng phần tử một.

 Bạn không quan tâm bên trong hộp sắp xếp ra sao → chỉ cần có “cái remote điều khiển” để bấm next() lấy ra item kế tiếp.

 Cái “remote điều khiển” đó chính là Iterator.

 2. Tại sao cần Iterator?

 Nếu bạn tự viết code duyệt (for, while), bạn phải biết collection đó hoạt động thế nào (array thì index, linked list thì node…).

 Iterator giúp ẩn chi tiết bên trong → bạn chỉ cần gọi next(), hasNext().

 Nhờ đó, client code ít bị phụ thuộc vào kiểu dữ liệu.

 Ví dụ: thay vì phải biết Array duyệt bằng index, còn Dictionary duyệt bằng key-value pairs → chỉ cần gọi iterator, mọi thứ trông giống nhau.

 3. Ví dụ đơn giản ngoài đời

 Bạn có playlist nhạc.

 Bạn không cần biết bài hát nằm trong database, array hay linked list.

 Chỉ cần remote bấm Next và nghe bài tiếp theo.

 Remote = Iterator
 Playlist = Collection
 */

// Array
let arrayCollection = NumberCollection(numbers: [10, 20, 30])
var arrayIterator = arrayCollection.makeIterator()
while let num = arrayIterator.next() {
    print("Array:", num)
}

// Linked List
let linked = LinkedList<Int>()
linked.head = Node(1, Node(2, Node(3)))
var listIterator = linked.makeIterator()
while let num = listIterator.next() {
    print("LinkedList:", num)
}
