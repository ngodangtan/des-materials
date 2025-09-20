/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

public protocol Coordinator: AnyObject {
    // 1
    var children: [Coordinator] { get set }
    var router: Router { get }
    
    // 2
    func present(animated: Bool, onDismissed: (() -> Void)?)
    func dismiss(animated: Bool)
    func presentChild(
        _ child: Coordinator,
        animated: Bool,
        onDismissed: (() -> Void)?)
}

extension Coordinator {
    // 1
    public func dismiss(animated: Bool) {
        router.dismiss(animated: true)
    }
    // 2
    public func presentChild(
        _ child: Coordinator,
        animated: Bool,
        onDismissed: (() -> Void)? = nil
    ) {
        children.append(child)
        child.present(
            animated: animated,
            onDismissed: { [weak self, weak child] in
                guard let self = self,
                      let child = child else {
                    return
                }
                self.removeChild(child)
                onDismissed?()
            }
        )
    }
    
    private func removeChild(_ child: Coordinator) {
        guard let index = children.firstIndex(
            where: { $0 === child }) else {
            return
        }
        children.remove(at: index)
    }
}

/*
 1. Định nghĩa protocol Coordinator
 protocol Coordinator: AnyObject {
     // 1
     var children: [Coordinator] { get set }
     var router: Router { get }
     
     // 2
     func present(animated: Bool, onDismissed: (() -> Void)?)
     func dismiss(animated: Bool)
     func presentChild(
         _ child: Coordinator,
         animated: Bool,
         onDismissed: (() -> Void)?)
 }

 a) AnyObject

 Bắt buộc chỉ class implement → để dùng weak, quản lý vòng đời, tránh retain cycle.

 b) children: [Coordinator]

 Mỗi coordinator có thể quản lý nhiều child coordinator (flow con).

 Dùng mảng để giữ tham chiếu → đảm bảo child không bị giải phóng khi đang chạy flow.

 Khi flow con xong → remove khỏi children để giải phóng memory.

 c) router: Router

 Mỗi coordinator cần một router để thực hiện điều hướng UI thực sự (push, present, dismiss).

 Coordinator chỉ quyết định trình tự flow, còn router quyết định hiển thị như thế nào.

 d) Các method

 present(animated:onDismissed:)
 → Khởi động chính flow của coordinator (màn hình root của flow).

 dismiss(animated:)
 → Kết thúc flow này, nhờ router pop/dismiss về root.

 presentChild(_:animated:onDismissed:)
 → Cho phép present một child coordinator (flow con), gắn kèm callback khi nó kết thúc.

 2. Extension với default implementation
 extension Coordinator {
     // 1
     public func dismiss(animated: Bool) {
         router.dismiss(animated: true)
     }


 Cung cấp sẵn một cách dismiss mặc định → gọi thẳng router để đóng flow.

 Như vậy, mọi concrete coordinator không cần viết lại hàm này, trừ khi muốn behavior đặc biệt.

     // 2
     public func presentChild(
         _ child: Coordinator,
         animated: Bool,
         onDismissed: (() -> Void)? = nil
     ) {
         children.append(child)
         child.present(
             animated: animated,
             onDismissed: { [weak self, weak child] in
                 guard let self = self,
                       let child = child else {
                     return
                 }
                 self.removeChild(child)
                 onDismissed?()
             }
         )
     }


 Bước 1: children.append(child)
 → Giữ tham chiếu đến child coordinator để nó không bị deinit sớm.

 Bước 2: child.present(...)
 → Khởi chạy flow con.
 → Truyền vào callback onDismissed mới, trong đó:

 [weak self, weak child] để tránh retain cycle (self giữ child, child giữ self).

 Nếu self và child còn sống → gọi removeChild(child) để giải phóng khỏi mảng children.

 Sau đó gọi callback onDismissed?() do caller truyền vào (nếu có).

 Ý nghĩa:

 Coordinator cha không cần nhớ khi nào flow con kết thúc → cơ chế này lo sẵn: khi child dismiss xong → nó sẽ tự remove khỏi children + báo ngược lại.

 Tránh memory leak vì giữ child mãi.

     private func removeChild(_ child: Coordinator) {
         guard let index = children.firstIndex(
             where: { $0 === child }) else {
             return
         }
         children.remove(at: index)
     }
 }


 Hàm tiện ích để xóa đúng child coordinator khỏi children.

 Dùng === (so sánh reference) vì Coordinator là class-only protocol → chỉ remove chính xác instance đó.

 Đây là bước dọn dẹp memory quan trọng.

 3. Ý nghĩa kiến trúc

 Coordinator protocol định nghĩa hợp đồng: mọi coordinator phải quản lý children, có router, và biết cách present/dismiss.

 Default implementation trong extension:

 Tránh lặp code (mọi coordinator đều có cùng cách dismiss/present child).

 Đảm bảo logic quản lý vòng đời chuẩn hoá (giữ child khi chạy, remove khi kết thúc).

 Weak self/child trong callback: bảo vệ chống retain cycle.

 removeChild: giúp tránh memory leak.

 4. Flow minh họa

 Ví dụ:

 let appCoordinator = AppCoordinator(router: AppRouter(window: window))
 let authCoordinator = AuthCoordinator(router: NavigationRouter(nav: nav))

 appCoordinator.presentChild(authCoordinator, animated: true) {
     print("Auth flow finished")
 }


 Diễn biến:

 authCoordinator được append vào children.

 authCoordinator.present(...) hiển thị màn hình login.

 Khi user đăng nhập xong → authCoordinator.dismiss() được gọi → trigger onDismissed.

 Callback trong presentChild chạy:

 removeChild(authCoordinator) khỏi children.

 Gọi print("Auth flow finished").

 Kết quả: child flow kết thúc gọn gàng, không leak, parent biết để tiếp tục luồng.
 */
