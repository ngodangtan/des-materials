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

import Foundation
/*
 Product: Hamburger (+ thành phần)
 */

// MARK: - Product
public struct Hamburger {
    public let meat: Meat
    public let sauce: Sauces
    public let toppings: Toppings
}

extension Hamburger: CustomStringConvertible {
    public var description: String { meat.rawValue + " burger" }
}

public enum Meat: String {
    case beef, chicken, kitten, tofu
}

// OptionSet cho phép kết hợp nhiều loại sốt
public struct Sauces: OptionSet {
    public static let mayonnaise = Sauces(rawValue: 1 << 0)
    public static let mustard   = Sauces(rawValue: 1 << 1)
    public static let ketchup   = Sauces(rawValue: 1 << 2)
    public static let secret    = Sauces(rawValue: 1 << 3)

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}

// OptionSet cho phép kết hợp nhiều topping
public struct Toppings: OptionSet {
    public static let cheese   = Toppings(rawValue: 1 << 0)
    public static let lettuce  = Toppings(rawValue: 1 << 1)
    public static let pickles  = Toppings(rawValue: 1 << 2)
    public static let tomatoes = Toppings(rawValue: 1 << 3)

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}

/*
 Trong sách: Hamburger có meat/sauce/toppings (dùng let để thành phẩm bất biến), Sauces & Toppings là OptionSet để có thể cộng gộp nhiều lựa chọn.
 
 2) Builder: nhận input từng bước & build ra Hamburger
 */
// MARK: - Builder
public class HamburgerBuilder {

    // Trạng thái đang chọn (mặc định beef, rỗng sốt/topping)
    public private(set) var meat: Meat = .beef
    public private(set) var sauces: Sauces = []
    public private(set) var toppings: Toppings = []

    // Cho phép thay đổi qua hàm public (có thể kiểm tra/validate)
    public func addSauces(_ sauce: Sauces)       { sauces.insert(sauce) }
    public func removeSauces(_ sauce: Sauces)    { sauces.remove(sauce) }
    public func addToppings(_ topping: Toppings) { toppings.insert(topping) }
    public func removeToppings(_ topping: Toppings) { toppings.remove(topping) }

    // Validation: một số loại thịt “hết hàng”
    public enum Error: Swift.Error { case soldOut }
    private var soldOutMeats: [Meat] = [.kitten]

    public func isAvailable(_ meat: Meat) -> Bool { !soldOutMeats.contains(meat) }

    public func setMeat(_ meat: Meat) throws {
        guard isAvailable(meat) else { throw Error.soldOut }
        self.meat = meat
    }

    // Xuất xưởng chiếc Hamburger
    public func build() -> Hamburger {
        Hamburger(meat: meat, sauce: sauces, toppings: toppings)
    }
}
/*
 Ý tưởng đúng như sách: các thuộc tính trong builder dùng var + private(set) để ép người dùng phải đi qua các hàm public (có thể gắn logic kiểm tra trước khi set), ví dụ báo lỗi khi chọn “kitten” (hết hàng); cuối cùng build() trả về Hamburger.
 3) Director (ví dụ “nhân viên quán” biết làm combo)
 */

// MARK: - Director
public final class Employee {
    public func createCombo1() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.beef)
        builder.addSauces(.secret)
        builder.addToppings([.lettuce, .tomatoes, .pickles]) // OptionSet literal
        return builder.build()
    }

    public func createKittenSpecial() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.kitten) // sẽ ném lỗi vì soldOut
        builder.addSauces(.mustard)
        builder.addToppings([.lettuce, .tomatoes])
        return builder.build()
    }
}

/*
 Trong sách, Employee đóng vai Director, cung cấp các công thức dựng sẵn: createCombo1() và createKittenSpecial(); lệnh “kitten special” sẽ fail vì “hết hàng”.
 */

// MARK: - Example
let staff = Employee()

if let combo = try? staff.createCombo1() {
    print("Nom nom " + combo.description)  // "Nom nom beef burger"
}

if let kitten = try? staff.createKittenSpecial() {
    print("Nom nom nom " + kitten.description)
} else {
    print("Sorry, no kitten burgers here... :[")
}

