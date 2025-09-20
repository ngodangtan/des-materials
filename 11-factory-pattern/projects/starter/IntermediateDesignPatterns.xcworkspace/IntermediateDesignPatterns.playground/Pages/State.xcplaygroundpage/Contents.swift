/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # State
 - - - - - - - - - -
 ![State Diagram](State_Diagram.png)
 
 The state pattern is a behavioral pattern that allows an object to change its behavior at runtime. It does so by changing an internal state. This pattern involves three types:
 
 1. The **context** is the object whose behavior changes and has an internal state.
 
 2. The **state protocol** defines a set of methods and properties required by concrete states. If you need stored properties, you can substitute a **base state class** instead of a protocol.
 
 3. The **concrete states** conform to the state protocol, or if a base class is used instead, they subclass the base. They implement required methods and properties to perform whatever behavior is desired when the context is in its state.
 
 ## Code Example
 */
/*
 1. State Pattern là gì?

 Thuộc nhóm Behavioral Pattern.

 Ý tưởng: thay vì nhồi nhét nhiều if / switch để xử lý trạng thái khác nhau, ta đóng gói từng trạng thái thành một object riêng, và cho context (đối tượng chính) ủy quyền hành vi cho state hiện tại.

 👉 Nói dễ hiểu:

 Bạn có một cái máy (context).

 Máy có nhiều trạng thái (state).

 Ở mỗi trạng thái, hành vi của máy khác nhau.

 Thay vì viết 1 class to đùng với nhiều if, ta chia nhỏ thành nhiều class “State” → code gọn, dễ mở rộng.

 2. Lợi ích của State Pattern

 ✅ Loại bỏ if-else khổng lồ khi xử lý trạng thái.
 ✅ Dễ mở rộng (chỉ cần thêm state mới).
 ✅ Đóng gói hành vi theo từng trạng thái → dễ đọc, dễ bảo trì.
 */

protocol TrafficLightState {
    func handle(context: TrafficLight)
}

class TrafficLight {
    var state: TrafficLightState
    
    init(initial: TrafficLightState) {
        self.state = initial
    }
    
    func request() {
        state.handle(context: self)
    }
}
//
class RedLight: TrafficLightState {
    func handle(context: TrafficLight) {
        print("🔴 Stop! Next → Green")
        context.state = GreenLight()
    }
}

class GreenLight: TrafficLightState {
    func handle(context: TrafficLight) {
        print("🟢 Go! Next → Yellow")
        context.state = YellowLight()
    }
}

class YellowLight: TrafficLightState {
    func handle(context: TrafficLight) {
        print("🟡 Caution! Next → Red")
        context.state = RedLight()
    }
}

// using
let trafficLight = TrafficLight(initial: RedLight())

trafficLight.request() // 🔴 Stop! Next → Green
trafficLight.request() // 🟢 Go! Next → Yellow
trafficLight.request() // 🟡 Caution! Next → Red
trafficLight.request() // 🔴 Stop! Next → Green

