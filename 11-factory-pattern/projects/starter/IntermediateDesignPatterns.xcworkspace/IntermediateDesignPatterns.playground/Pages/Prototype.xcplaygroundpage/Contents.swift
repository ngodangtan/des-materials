/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Prototype
 - - - - - - - - - -
 ![Prototype Diagram](Prototype_Diagram.png)
 
 The prototype pattern is a creational pattern that allows an object to copy itself. It involves two types:
 
 1. A **copying** protocol declares copy methods.
 
 2. A **prototype** is a class that conforms to the copying protocol.
 
 ## Code Example
 */
/*
 1. Prototype Pattern là gì?

 Là một Creational Pattern.

 Ý tưởng: tạo object bằng cách clone (nhân bản) từ một object gốc (prototype), thay vì phải khởi tạo từ đầu.

 Rất hữu ích khi:

 Việc tạo mới object tốn kém tài nguyên (ví dụ: cấu hình phức tạp, tính toán nhiều).

 Bạn muốn giữ trạng thái ban đầu và tái sử dụng nó để tạo bản sao.

 👉 Giống như: bạn có một “mẫu form” → chỉ cần copy ra và điền thêm thông tin thay vì viết lại từ đầu.

 2. Khi nào nên dùng?

 Khi object có cấu hình phức tạp và việc tạo mới nhiều lần gây lãng phí.

 Khi cần tạo nhiều biến thể của object nhưng vẫn giữ được khởi tạo ban đầu.

 Khi muốn tách biệt quá trình khởi tạo phức tạp khỏi client.

 3. Ví dụ trong sách (Coffee Order) ☕️

 Sách đưa ra tình huống:

 Bạn có một Coffee với nhiều thuộc tính: size, loại sữa, số shot espresso, syrup…

 Tạo mới từng cái bằng init phức tạp, nhiều tham số → dễ lặp code.

 Giải pháp: tạo một prototype (cà phê cơ bản) rồi clone ra, chỉ thay đổi vài thuộc tính.
 */

// 1. Protocol cho Prototype
protocol Copying {
    init(original: Self)
}

// 2. Coffee class hỗ trợ copy
class Coffee: Copying, CustomStringConvertible {
    var size: String
    var milk: String
    var sugar: Int
    
    init(size: String, milk: String, sugar: Int) {
        self.size = size
        self.milk = milk
        self.sugar = sugar
    }
    
    // init dùng để clone
    required init(original: Coffee) {
        self.size = original.size
        self.milk = original.milk
        self.sugar = original.sugar
    }
    
    var description: String {
        return "Coffee(size: \(size), milk: \(milk), sugar: \(sugar))"
    }
}

// 3. Dùng Prototype
let baseCoffee = Coffee(size: "Medium", milk: "Whole", sugar: 1)

// Clone ra rồi chỉnh sửa
let customer1 = Coffee(original: baseCoffee)
customer1.sugar = 2

let customer2 = Coffee(original: baseCoffee)
customer2.milk = "Soy"

print(baseCoffee)   // Coffee(size: Medium, milk: Whole, sugar: 1)
print(customer1)    // Coffee(size: Medium, milk: Whole, sugar: 2)
print(customer2)    // Coffee(size: Medium, milk: Soy, sugar: 1)

// Another example
let monster = Monster(health: 700, level: 37)
let monster2 = monster.copy()
print("Watch out! That monster's level is \(monster2.level)!")

let eyeball = EyeballMonster(
health: 3002,
level: 60,
redness: 999)
let eyeball2 = eyeball.copy()
print("Eww! Its eyeball redness is \(eyeball2.redness)!")

let eyeballMonster3 = EyeballMonster(monster)
