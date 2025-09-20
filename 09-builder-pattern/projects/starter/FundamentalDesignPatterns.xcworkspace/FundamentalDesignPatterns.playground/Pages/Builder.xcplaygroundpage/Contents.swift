/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Builder
 - - - - - - - - - -
 ![Builder Diagram](Builder_Diagram.png)
 
 The builder pattern allows complex objects to be created step-by-step instead of all-at-once via a large initializer.
 
 The builder pattern involves three parts:
 
 (1) The **product** is the complex object to be created.
 
 (2) The **builder** accepts inputs step-by-step and ultimately creates the product.
 
 (3) The **director** supplies the builder with step-by-step inputs and requests the builder create the product once everything has been provided.
 
 ## Code Example
 */
/*
 Builder Pattern là gì (ngắn gọn)

 Thuộc nhóm Creational: tạo object theo chuỗi bước thay vì nhồi hết tham số vào init một lần.

 3 vai: Director (điều phối các bước), Builder (nhận input từng bước & dựng sản phẩm), Product (thành phẩm).

 Dùng khi cần tạo đối tượng phức tạp có nhiều input và thứ tự nhập không cố định. Ví dụ “làm burger” — chọn loại thịt, sốt, topping theo bất kỳ thứ tự nào, khi xong mới “build” ra chiếc burger.
 
 Khi nào nên dùng Builder?

 Khi sản phẩm nhiều tham số/tùy chọn, có thể nhập theo bất kỳ thứ tự rồi “chốt đơn” một lần.

 Cần tách input/validation ra khỏi client, gom vào builder (ví dụ kiểm tra hàng còn hay không).

 Nếu sản phẩm ít tham số hoặc không thể tạo theo bước, builder có thể không đáng — dùng convenience initializers là đủ.

 Tóm tắt điểm học được

 Product là Hamburger (immutable).

 Builder giữ trạng thái đang chọn, cho phép thêm/bớt, validate và cuối cùng build().

 Director biết “công thức” chuẩn để gọi builder.

 Ưu điểm: API thân thiện, dễ bảo trì/mở rộng, ẩn bớt phức tạp khỏi controller.
 */
