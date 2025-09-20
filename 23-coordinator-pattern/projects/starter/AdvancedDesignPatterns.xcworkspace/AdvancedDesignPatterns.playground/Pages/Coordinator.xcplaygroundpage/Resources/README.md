Tìm hiểu về coordinator sẽ đi theo thứ tự 
Router -> coordinator
----------------------------

Mục đích của router protocol để làm gì ?
Router: tách biệt phần “điều hướng UI” (push, present, dismiss view controllers) khỏi coordinator.
Router định nghĩa:

present(_ vc: UIViewController, animated: Bool, onDismissed: (() -> Void)?)

dismiss(animated: Bool)

Và một default tiện lợi: present(_:animated:) gọi sang hàm đầy đủ (onDismissed = nil).

Ý nghĩa kiến trúc:

Decouple coordinator khỏi UIKit: Coordinator chỉ gọi router.present(...) thay vì tự pushViewController/present. Nhờ đó, thay router là đổi ngay cơ chế điều hướng mà không đổi code coordinator.

Router biết “thực thi UI”, không biết “màn tiếp theo là gì”: cái này do coordinator quyết.


Ý nghĩa:

Giúp coordinator không phụ thuộc vào UINavigationController, UIWindow hay modal presentation cụ thể.

Router chỉ lo cách hiển thị/dismiss; còn coordinator lo cái gì sẽ được hiển thị.

Ví dụ: NavigationRouter dùng push/pop, ModalNavigationRouter dùng present/dismiss, AppDelegateRouter dùng window root… nhưng coordinator không cần biết, chỉ gọi qua router.present.

👉 Nói ngắn gọn: Router protocol tạo ra để tách layer “hiển thị view controller” khỏi coordinator, giúp tái sử dụng và thay đổi cơ chế điều hướng mà không động chạm đến logic flow.

----------------------------
Mục đích của coordinator protocol để làm gì ?
Coordinator: Vai trò: là “bộ điều phối” flow, chịu trách nhiệm quyết định tạo ViewController nào và trình bày theo thứ tự nào.

Trong protocol: định nghĩa các property & method chung mà tất cả concrete coordinators phải có:

children: [Coordinator] để quản lý child coordinators.

router: Router để tách biệt khỏi cách trình bày thực tế.

Các method như present, dismiss, presentChild.

Ý nghĩa:

Giúp decouple (khử phụ thuộc) giữa các view controller với nhau. View controller không biết ai sẽ được show tiếp theo — chỉ cần báo lại coordinator.

Giúp tổ chức flow phức tạp thành từng coordinator nhỏ, dễ tái sử dụng và dễ test.

Parent coordinator giữ con qua interface Coordinator → không phụ thuộc vào implementation cụ thể.

👉 Nói ngắn gọn: Coordinator protocol định nghĩa hợp đồng chung để mọi flow (coordinator) trong app có thể được điều phối thống nhất, quản lý children và lifecycle.


----------------------------
Tại sao cả 2 lại kế thừa AnyObject
Trong sách khi định nghĩa cả `Coordinator` protocol và `Router` protocol, bạn sẽ thấy chúng đều kế thừa **`AnyObject`**.

---

## 1. `AnyObject` trong Swift là gì?

* `AnyObject` là một **protocol đặc biệt** mà tất cả **class type** trong Swift đều tuân theo.
* Khi bạn khai báo `protocol SomeProtocol: AnyObject {}`, nghĩa là protocol đó **chỉ có thể được áp dụng cho class**, không thể áp dụng cho `struct` hay `enum`.
* Đây còn gọi là một **class-only protocol**.

---

## 2. Tại sao `Coordinator` cần giới hạn class-only?

* **Coordinator quản lý child coordinators** thông qua một mảng `children: [Coordinator]`.
* Mỗi child coordinator thường có vòng đời phụ thuộc vào parent → cần được quản lý tham chiếu (reference semantics), và quan trọng hơn là **cần weak reference** để tránh retain cycle.
* Chỉ **class** mới có reference semantics và hỗ trợ `weak`. Struct/enum thì không.
* Nếu không kế thừa `AnyObject`, ta không thể khai báo:

  ```swift
  weak var parent: Coordinator?
  ```

  Vì Swift chỉ cho phép `weak` với class type.
* Vì vậy, `Coordinator` protocol bắt buộc phải `: AnyObject` để đảm bảo mọi implement đều là class → dùng được `weak` để quản lý quan hệ parent-child.

---

## 3. Tại sao `Router` cũng cần class-only?

* Router thường wrap một `UINavigationController` hoặc `UIWindow` → vốn là class trong UIKit.
* Router giữ tham chiếu (reference) tới những đối tượng UIKit này, và cũng cần được giữ dưới dạng `weak` ở phía coordinator (để tránh retain cycle giữa Coordinator ↔ Router).
* Do đó, Router cũng phải là class-only.
* Ngoài ra, Router thường quản lý **trạng thái điều hướng** (stack view controllers, dismiss callback, …). Với **reference semantics** thì mọi Coordinator dùng chung cùng một Router sẽ luôn thấy đúng trạng thái hiện tại. Nếu Router là struct thì chỉ copy-by-value, không còn phù hợp.

---

## 4. Tóm gọn

* `Coordinator: AnyObject` → Đảm bảo chỉ class implement được, để quản lý vòng đời (parent/child), tránh retain cycle bằng `weak`.
* `Router: AnyObject` → Đảm bảo chỉ class implement được, để làm việc với UIKit (toàn class) và chia sẻ trạng thái navigation qua reference semantics.

👉 Nếu không có `AnyObject`, ta có thể vô tình implement Coordinator/Router bằng struct → dẫn tới lỗi thiết kế, mất khả năng `weak`, gây retain cycle hoặc hành vi sai.

----------------------------

Tại sao trong coordinator vẫn phải khai báo present, dismiss mặc dù trong coordinator đã khai báo router

Tóm gọn: **Router “điều khiển CÁCH hiển thị view controller”, còn Coordinator “điều phối FLOW và VÒNG ĐỜI của các coordinator”**. Vì thế, dù `Coordinator` đã có `router`, protocol `Coordinator` **vẫn phải** có `present / dismiss / presentChild` để:

### 1) Che giấu Router & giữ “điểm vào” thống nhất cho flow

* Caller (parent coordinator, AppDelegate, v.v.) chỉ tương tác với **flow** qua `Coordinator.present(...)`, **không** đụng tới `router`.
* Nhờ đó, bên ngoài **không bị rò rỉ chi tiết UI** (push, modal, window…) và không bị phụ thuộc vào loại Router cụ thể; tất cả được bọc trong Coordinator. Sách cũng nhấn mạnh: coordinator giữ `router` như một **quan hệ trừu tượng** để tách chi tiết trình bày.

### 2) `presentChild` quản lý **lifecycle** của child coordinators — thứ Router không làm

* Khi present một flow con, ta **phải**:
  (a) thêm child vào `children`,
  (b) gọi `child.present(...)`,
  (c) gỡ child ra khi flow con bị dismiss (user bấm Back/cancel).
* Các bước (a)(c) **không** thuộc trách nhiệm Router. Vì vậy `presentChild` nằm trong `Coordinator` và có **default implementation**: append child, gọi `child.present`, rồi gắn `onDismissed` để tự động `removeChild` khi flow kết thúc (dọn dẹp bộ nhớ, tránh leak).

### 3) `dismiss` ở Coordinator là “ý định flow”, Router chỉ là “thực thi UI”

* `Coordinator.dismiss(animated:)` **đại diện cho ý định kết thúc flow** ở tầng điều phối; **mặc định nó ủy quyền** cho `router.dismiss(...)`. Điều này tạo một **hook chung** (nơi có thể thêm logging, analytics, guard logic…) trước/after khi thực thi UI. Sách đưa đúng default impl: `dismiss` của coordinator chỉ gọi `router.dismiss`.

### 4) Phân tách “present cái GÌ” (Coordinator) vs “present bằng CÁCH NÀO” (Router)

* Router **chỉ biết** nhận một `UIViewController` để `present/push/dismiss`. Nó **không** biết “màn hình tiếp theo của flow là gì?” hay “khi nào flow hoàn thành để dọn dẹp child?”.
* Coordinator **quyết định** tạo VC nào, thứ tự nào, và **nối onDismiss** để dọn dẹp. Ví dụ trong sách, `Coordinator.presentChild` wiring onDismiss để remove child — đây là logic **điều phối**, không phải điều hướng UI.

### 5) Tăng testability & tránh lặp code

* Nếu để caller gọi **trực tiếp** `router.present(vc, ...)`, bạn sẽ phải **lặp lại** việc quản lý `children` & onDismiss ở khắp nơi. Đưa `present/presentChild` vào protocol giúp **chuẩn hoá hành vi**, test coordinator bằng mock dễ hơn (kiểm tra đã gọi `presentChild` đúng chưa, onDismiss có remove child chưa), trong khi Router vẫn có thể mock riêng việc điều hướng UI.

---

#### Kết luận

* **Router**: API trình bày **view controller** (push/present/dismiss).
* **Coordinator**: API trình bày **flow** (khởi động/kết thúc/present child) + quản lý **lifecycle** child.
* Vì **hai tầng trừu tượng khác nhau**, `Coordinator` *cần* `present / dismiss / presentChild` để giữ invariant của flow (quản lý children, gắn onDismiss, đóng gói hook), còn việc chạm UIKit vẫn ủy quyền xuống `router`. Đây cũng là đúng những gì chương “Coordinator Pattern” mô tả: **Coordinator định nghĩa quan hệ `children` và `router` cùng các phương thức `present/dismiss`**, còn Router định nghĩa **phương thức trình bày/dismiss view controller**.

Nếu bạn muốn, mình có thể dán đoạn **default implementation** ngắn của `dismiss` và `presentChild` từ chương này để thấy rõ “Coordinator gọi Router nhưng đồng thời quản lý children & onDismiss” (rất súc tích).


