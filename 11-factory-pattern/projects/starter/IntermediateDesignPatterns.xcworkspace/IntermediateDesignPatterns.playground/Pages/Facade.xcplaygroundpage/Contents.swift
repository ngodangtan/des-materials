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

import Foundation

// MARK: - Dependencies (models & databases)

public struct Customer {
    public let identifier: String
    public var address: String
    public var name: String
}

extension Customer: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(identifier) }
    public static func == (lhs: Customer, rhs: Customer) -> Bool { lhs.identifier == rhs.identifier }
}

public struct Product {
    public let identifier: String
    public var name: String
    public var cost: Double
}

extension Product: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(identifier) }
    public static func == (lhs: Product, rhs: Product) -> Bool { lhs.identifier == rhs.identifier }
}

// “Database” đơn giản: tồn kho và vận chuyển
public class InventoryDatabase {
    public var inventory: [Product: Int] = [:]

    public init(inventory: [Product: Int]) {
        self.inventory = inventory
    }
}

public class ShippingDatabase {
    public var pendingShipments: [Customer: [Product]] = [:]
}

// MARK: - Facade

public class OrderFacade {
    public let inventoryDatabase: InventoryDatabase
    public let shippingDatabase: ShippingDatabase

    public init(inventoryDatabase: InventoryDatabase,
                shippingDatabase: ShippingDatabase) {
        self.inventoryDatabase = inventoryDatabase
        self.shippingDatabase = shippingDatabase
    }

    public func placeOrder(for product: Product, by customer: Customer) {
        // 1. Log thông tin đặt hàng
        print("Place order for '\(product.name)' by '\(customer.name)'")

        // 2. Kiểm tra tồn kho
        let count = inventoryDatabase.inventory[product, default: 0]
        guard count > 0 else {
            print("'\(product.name)' is out of stock!")
            return
        }

        // 3. Trừ tồn kho
        inventoryDatabase.inventory[product] = count - 1

        // 4. Ghi nhận đơn cần giao cho khách
        var shipments = shippingDatabase.pendingShipments[customer, default: []]
        shipments.append(product)
        shippingDatabase.pendingShipments[customer] = shipments

        // 5. Xác nhận
        print("Order placed for '\(product.name)' by '\(customer.name)'")
    }
}

// MARK: - Example usage

let rayDoodle = Product(identifier: "product-001", name: "Ray's doodle", cost: 0.25)
let vickiPoodle = Product(identifier: "product-002", name: "Vicki's prized poodle", cost: 1000)

let inventoryDatabase = InventoryDatabase(inventory: [rayDoodle: 50, vickiPoodle: 1])
let orderFacade = OrderFacade(inventoryDatabase: inventoryDatabase, shippingDatabase: ShippingDatabase())

let customer = Customer(identifier: "customer-001",
                        address: "1600 Pennsylvania Ave, Washington, DC 20006",
                        name: "Johnny Appleseed")

orderFacade.placeOrder(for: vickiPoodle, by: customer)

/*
 Giải thích nhanh — theo đúng sách

 Customer & Product + Hashable: hai model cơ bản. Việc cho conform Hashable giúp chúng có thể làm key trong Dictionary (để map tồn kho theo Product, và đơn chờ giao theo Customer) .

 InventoryDatabase: “cơ sở dữ liệu” rất tối giản, chỉ là inventory: [Product: Int] lưu số lượng hiện có theo từng sản phẩm; có init để truyền dữ liệu khởi tạo .

 ShippingDatabase: lưu pendingShipments: [Customer: [Product]] — danh sách sản phẩm đã đặt nhưng chưa giao của mỗi khách hàng .

 OrderFacade: đóng vai trò Facade, giữ tham chiếu đến hai “database” và cung cấp API đơn giản placeOrder(for:by:).

 Khởi tạo Facade với hai dependency (inventories & shipping) .

 placeOrder thực hiện 5 bước:

 In ra thông tin đơn hàng (product/customer) .

 Kiểm tra tồn kho, nếu hết → báo “out of stock” và dừng .

 Trừ 1 đơn vị tồn của sản phẩm đó .

 Thêm sản phẩm vào danh sách pendingShipments của khách hàng .

 In xác nhận đặt hàng thành công .

 Example: Tạo hai Product (Ray’s doodle & Vicki’s prized poodle), khởi tạo InventoryDatabase (50 doodles, 1 poodle), tạo OrderFacade, tạo một Customer rồi gọi placeOrder cho poodle. Đây chính là đoạn playground trong sách; khi chạy sẽ in hai dòng “Place order…” và “Order placed…” .

 Ý nghĩa Facade ở đây: Toàn bộ các bước “đọc tồn kho → trừ kho → ghi nhận giao hàng” được gom vào một method duy nhất của OrderFacade. Client không cần biết cách làm việc trực tiếp với InventoryDatabase hay ShippingDatabase — đúng tinh thần “đơn giản hóa interface cho một hệ thống phức tạp” của Facade Pattern
 */
