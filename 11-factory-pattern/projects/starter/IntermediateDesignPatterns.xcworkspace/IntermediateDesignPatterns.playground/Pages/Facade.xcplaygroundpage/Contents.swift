/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Facade
 - - - - - - - - - -
 ![Multicast Delegate Diagram](Facade_Diagram.png)
 
 The facade pattern is a structural pattern that provides a simple interface to a complex system. It involves two types:
 
 1. The **facade** provides simple methods to interact with the system. This allows consumers to use the facade instead of knowing about and interacting with multiple classes in the system.
 
 2. The **dependencies** are objects owned by the facade. Each dependency performs a small part of a complex task.
 
 ## Code Example
 */
/*
 1. Facade Pattern là gì?

 Thuộc nhóm Structural Patterns.

 Ý tưởng: cung cấp một “cửa ngõ đơn giản” (facade) để truy cập vào một hệ thống phức tạp.

 Bên trong có thể là nhiều class, nhiều subsystem → client không cần quan tâm, chỉ gọi qua facade.

 👉 Giống như:

 Bạn muốn uống cà phê.

 Thay vì tự đi xay hạt, đun nước, pha chế… → bạn chỉ cần bấm nút CoffeeMachine.makeCoffee().

 Facade chính là cái nút bấm tiện lợi đó.

 2. Khi nào dùng Facade Pattern?

 Khi hệ thống có nhiều subsystem phức tạp và bạn muốn đơn giản hóa cách sử dụng.

 Khi muốn tách biệt client code khỏi sự phức tạp nội bộ.

 Khi muốn có một API thống nhất để làm việc với nhiều module khác nhau.
 */
