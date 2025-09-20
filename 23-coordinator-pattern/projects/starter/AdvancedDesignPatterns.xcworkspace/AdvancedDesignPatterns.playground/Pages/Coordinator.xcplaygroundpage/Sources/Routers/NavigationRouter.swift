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

import UIKit
/*
 Ok, mình sẽ giải thích thật kỹ hai ý bạn hỏi về `NavigationRouter`.
 
 ---
 
 ## 1. Tại sao `class NavigationRouter: NSObject`?
 
 * **Lý do chính:** `NavigationRouter` thường sẽ làm **delegate** của `UINavigationController`.
 
 * Trong iOS, các delegate của UIKit (`UITableViewDelegate`, `UINavigationControllerDelegate`, …) đều yêu cầu đối tượng delegate phải là **Objective-C compatible**.
 * Muốn class Swift làm delegate của UIKit, thường phải **thừa kế từ `NSObject`** (hoặc ít nhất là `NSObjectProtocol`).
 * Thừa kế `NSObject` cũng giúp:
 
 * Có sẵn **runtime features** (như KVO, selector) mà UIKit có thể cần.
 * Tự động tuân thủ `NSObjectProtocol` (`isEqual`, `hash`, `description`…), nhiều khi hữu ích khi debug.
 
 👉 Vì vậy: `NavigationRouter: NSObject` đảm bảo class này có thể **làm delegate của UINavigationController** và dùng trọn vẹn cơ chế delegate/selector của UIKit.
 
 ---
 
 ## 2. Tại sao cần ba property này?
 
 ### a. `private let navigationController: UINavigationController`
 
 * Đây là “**engine**” điều hướng thật sự.
 * Router giữ tham chiếu tới `UINavigationController` để:
 
 * `pushViewController`
 * `popViewController`
 * set delegate (để biết khi nào VC bị pop).
 * Nếu không giữ tham chiếu này, Router không thể thực sự thực thi lệnh điều hướng.
 
 ---
 
 ### b. `private let routerRootController: UIViewController?`
 
 * Dùng để **ghi nhớ màn hình gốc** khi Router được khởi tạo (thường là `navigationController.viewControllers.first`).
 * Ý nghĩa:
 
 * Biết “gốc” để **reset** stack về ban đầu khi flow kết thúc.
 * Dùng để xác định khi nào navigation stack trở về root (có thể xem flow đã kết thúc).
 
 Ví dụ:
 
 * App khởi động, root là `HomeVC`.
 * Bạn push `DetailVC`, push `SettingsVC`.
 * Khi user back hết về `HomeVC`, Router có thể detect stack == `routerRootController` → báo coordinator flow con đã hoàn thành, remove child.
 
 ---
 
 ### c. `private var onDismissForViewController: [UIViewController: (() -> Void)] = [:]`
 
 * Đây là một **dictionary mapping VC → closure**.
 * Ý nghĩa: khi coordinator **present** một VC, ta có thể đính kèm một `onDismissed` closure.
 * Router giữ cái closure này để khi VC đó bị **pop/dismiss**, nó sẽ gọi callback tương ứng.
 * Callback này dùng để:
 
 * Cho Coordinator biết flow con đã kết thúc.
 * Dọn dẹp child coordinator trong `children`.
 * Thực hiện clean-up khác (analytics, logging, …).
 
 Ví dụ:
 
 ```swift
 router.present(loginVC, animated: true) {
 // onDismiss: remove AuthCoordinator khỏi children
 }
 ```
 
 ---
 
 ## Tóm gọn
 
 * **`NSObject`**: để `NavigationRouter` có thể làm delegate của `UINavigationController` và tương thích với UIKit runtime.
 * **`navigationController`**: “engine” điều hướng chính (thực thi push/pop).
 * **`routerRootController`**: lưu màn hình gốc, giúp detect khi nào flow trở về trạng thái ban đầu.
 * **`onDismissForViewController`**: lưu callback onDismiss của từng VC, gọi khi VC bị pop/dismiss để Coordinator biết mà dọn dẹp.
 
 ---
 */

public class NavigationRouter: NSObject {
    // 2
    private let navigationController: UINavigationController
    private let routerRootController: UIViewController?
    private var onDismissForViewController: [UIViewController: (() -> Void)] = [:]
    // 3
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.routerRootController = navigationController.viewControllers.first
        super.init()
        navigationController.delegate = self
    }
}

/*
 1) Vì sao NavigationRouter cần : NSObject

 Mục tiêu của NavigationRouter là trở thành delegate của UINavigationController để bắt sự kiện khi một view controller bị pop (ví dụ user bấm Back).

 Tác giả ghi rõ: khai báo NavigationRouter là subclass của NSObject vì bạn sẽ cho nó conform UINavigationControllerDelegate ngay sau đó (UIKit/selector cần tương thích Objective-C).

 Nói ngắn: NSObject giúp router dùng được delegate + selector của UIKit, đúng nhu cầu “nghe” pop/back.

 2) Ba property “xương sống” của NavigationRouter
 a) private let navigationController: UINavigationController

 Đây là “động cơ điều hướng” thật: router push/pop qua nó. Tác giả nêu thẳng: dùng để push & pop VC.

 b) private let routerRootController: UIViewController?

 Chụp lại “điểm neo” (anchor) của stack tại thời điểm router được khởi tạo (trong code mẫu là viewControllers.first, tức root hiện thời).

 Dùng làm đích pop khi “đóng” toàn bộ flow do router mở ra: “dùng biến này để dismiss router bằng cách pop về đây”.

 Nhờ có “neo”, dismiss() biết cần pop về đâu (không pop quá tay), trả stack về trạng thái ban đầu trước khi flow bắt đầu.

 c) private var onDismissForViewController: [UIViewController: (() -> Void)]

 Bảng băm mapping VC → onDismiss closure. Khi bạn present(vc, onDismissed:), router lưu closure này.

 Khi VC đó bị pop/dismiss, router gọi closure để báo cho coordinator “flow con đã xong” → parent coordinator remove child, dọn dẹp, analytics… Tác giả nói rõ vai trò này.

 3) Cách các hàm vận hành (và vì sao được viết như vậy)
 present(_:animated:onDismissed:)
 onDismissForViewController[viewController] = onDismissed
 navigationController.pushViewController(viewController, animated: animated)


 Bước 1: ghi sổ onDismiss cho VC đó.

 Bước 2: push VC lên stack.

 Ý nghĩa: gắn “hậu sự” cho từng VC ngay khi show, để lúc nó biến mất, router biết phải làm gì. Tác giả diễn giải y như vậy.

 dismiss(animated:)
 guard let routerRootController = routerRootController else {
   navigationController.popToRootViewController(animated: animated)
   return
 }
 performOnDismissed(for: routerRootController)
 navigationController.popToViewController(routerRootController, animated: animated)


 Nếu không có neo (hiếm): pop về root mặc định của nav.

 Nếu có neo:

 Kích hoạt onDismiss gắn với “neo” (nếu có) — đây là điểm móc để dọn dẹp khi đóng toàn bộ router/flow.

 Pop về “neo” (đưa stack về trạng thái trước khi flow bắt đầu).

 Tác giả giải thích logic này đúng như code ở chương: khi dismiss, hoặc pop về root, hoặc perform onDismiss cho “neo” rồi pop về nó.

 Lưu ý nhỏ: với thao tác popToViewController, nhiều VC có thể bị pop một lượt. Vậy làm sao gọi onDismiss của “những VC bị pop” kia? → câu trả lời nằm ở Delegate bên dưới.

 performOnDismissed(for:)

 Lấy closure từ bảng băm, gọi nó rồi xóa để tránh leak/gọi lại.

 4) Bắt nút Back & pop thủ công: Delegate là mấu chốt

 Để biết VC nào vừa bị pop (dù là user bấm Back hay popViewController), router đăng ký làm delegate của nav và xử lý tại:

 navigationController(_:didShow:animated:)


 Công thức trong sách (áp dụng cho cả playground và project): lấy from viewController từ transitionCoordinator, kiểm tra nó không còn trong viewControllers → đó chính là VC vừa bị pop, khi đó gọi performOnDismissed(for: dismissedVC).

 Và nhớ set delegate trong init của router:

 navigationController.delegate = self


 (Tác giả nhắc rõ phải set).

 Nhờ delegate, mọi lần pop (kể cả pop nhiều VC khi popToViewController) đều sẽ đi qua didShow, và bạn sẽ gọi performOnDismissed cho VC bị rời khỏi stack. Điều này bổ khuyết cho dismiss(animated:) ở trên: dismiss lo đích pop & hook “neo”, còn delegate đảm bảo từng VC bị pop đều được bắn onDismiss đúng chuẩn.

 5) Minh họa nhanh 1 flow

 Trước khi tạo router: stack = [Home]

 Tạo router với nav hiện tại → routerRootController = Home.

 present(A, onDismissed: aDone) → push → stack [Home, A] (bảng băm lưu A→aDone)

 present(B, onDismissed: bDone) → push → stack [Home, A, B] (bảng băm lưu B→bDone)

 User Back từ B → didShow phát hiện B bị pop → gọi bDone() → stack [Home, A]

 Coordinator quyết định đóng flow → dismiss()

 performOnDismissed(for: Home) (thường không có onDismiss cho Home → bỏ qua)

 popToViewController(Home) → A bị pop → didShow phát hiện A bị pop → gọi aDone() → stack [Home] (trở lại trạng thái ban đầu)

 Chốt ý

 NSObject: để làm delegate UINavigationController (cần Obj-C runtime).

 navigationController: “máy đẩy kéo” VC; routerRootController: “neo” để đóng flow đúng chỗ; onDismissForViewController: sổ tay các callback dọn dẹp.

 present: lưu onDismiss rồi push; dismiss: hook dọn dẹp toàn flow + pop về “neo”; performOnDismissed: gọi & xóa closure.

 Delegate didShow: phát hiện VC nào vừa rời stack để gọi performOnDismissed (kể cả khi pop nhiều VC). Nhớ set navigationController.delegate = self.
 */

// MARK: - Router
extension NavigationRouter: Router {
    // 1
    // chiu trách nhiệm
    public func present(
        _ viewController: UIViewController,
        animated: Bool,
        onDismissed: (() -> Void)?
    ) {
        onDismissForViewController[viewController] = onDismissed
        navigationController.pushViewController(viewController,
                                                animated: animated)
    }
    
    // 2
    public func dismiss(animated: Bool) {
        guard let routerRootController = routerRootController else {
            navigationController.popToRootViewController(
                animated: animated)
            return
        }
        performOnDismissed(for: routerRootController)
        navigationController.popToViewController(
            routerRootController,
            animated: animated)
    }
    // 3
    private func performOnDismissed(
        for
        viewController: UIViewController
    ) {
        guard let onDismiss =
                onDismissForViewController[viewController] else {
            return
        }
        onDismiss()
        onDismissForViewController[viewController] = nil
    }
}

/*
 Dưới đây là “zoom-in” từng dòng của delegate này và vì sao nó hoạt động đúng để gọi onDismiss khi một VC vừa bị pop khỏi stack:

 // MARK: - UINavigationControllerDelegate
 extension NavigationRouter: UINavigationControllerDelegate {
   public func navigationController(
     _ navigationController: UINavigationController,
     didShow viewController: UIViewController,
     animated: Bool
   ) {
     guard
       let dismissedViewController = navigationController.transitionCoordinator?
         .viewController(forKey: .from),
       !navigationController.viewControllers.contains(dismissedViewController)
     else {
       return
     }

     performOnDismissed(for: dismissedViewController)
   }
 }

 Ý tưởng tổng quát

 Mục tiêu: tìm ra view controller nào vừa rời khỏi stack sau một lần chuyển cảnh (thường là pop do bấm Back hoặc vuốt Back).

 Chiến lược: Trong didShow, hỏi transitionCoordinator xem VC “from” là ai. Nếu VC “from” hiện không còn nằm trong navigationController.viewControllers nữa ⇒ nó đã bị pop ⇒ gọi performOnDismissed(for:).

 Giải thích từng phần
 1) Tại sao dùng didShow (không phải willShow)?

 willShow xảy ra trước khi chuyển cảnh hoàn tất, lúc đó chưa biết chắc kết quả (đặc biệt với interactive pop có thể bị hủy).

 didShow gọi sau khi chuyển cảnh kết thúc → kết quả đã “an bài”. Đây là thời điểm tin cậy để quyết định VC nào thực sự rời stack.

 2) transitionCoordinator?.viewController(forKey: .from)

 transitionCoordinator mô tả transition hiện tại.

 .from == màn hình đi ra trong transition.

 Case push: from = màn trước (ví dụ A), to = màn mới (B). Sau push xong, A vẫn còn trong stack ⇒ không phải “dismissed”.

 Case pop: from = màn đang bị pop (ví dụ B), to = màn bên dưới (A). Sau pop xong, B không còn trong stack ⇒ đúng là dismissed.

 Khi không có transition (hoặc một số edge cases), transitionCoordinator có thể là nil ⇒ guard fail → return an toàn.

 3) !navigationController.viewControllers.contains(dismissedViewController)

 Điều kiện “không còn trong stack” là chìa khóa.

 Với push: from (A) vẫn còn trong mảng viewControllers ⇒ điều kiện sai ⇒ không gọi performOnDismissed.

 Với pop: from (B) đã rời khỏi mảng ⇒ điều kiện đúng ⇒ gọi performOnDismissed(for: B).

 4) Vì sao cách check này đúng cả khi:

 Back button lẫn edge-swipe (interactive pop):
 Nếu người dùng hủy thao tác vuốt (cancel), didShow sẽ không báo rời stack ⇒ contains vẫn true ⇒ không gọi onDismiss (đúng).

 Pop nhiều màn (ví dụ popToViewController hoặc popToRootViewController)
 didShow chạy một lần cho transition đó. transitionCoordinator?.viewController(forKey: .from) chỉ trả về màn hình “rời đi” chính. Tuy nhiên, với cách triển khai đầy đủ, bạn thường:

 Gọi performOnDismissed(for:) tại đây cho màn hình chính rời đi;

 Và/hoặc thêm logic xử lý cho từng VC bị loại khỏi stack (nếu cần), bằng cách so sánh snapshot mảng trước/sau hoặc lặp qua onDismissForViewController để gọi những VC không còn trong stack. (Trong sách, phần pop-to thường được phối hợp cùng dismiss(animated:) hoặc quản lý onDismiss theo điểm neo “root”.)

 5) Tại sao phải gọi performOnDismissed(for:) tại đây?

 Bạn đã “gửi gắm” callback vào onDismissForViewController[vc] khi present(vc, onDismissed:).

 Khi vc rời stack thực sự, đây là lúc an toàn để:

 Gọi onDismiss (để Coordinator remove child, dọn dẹp flow con, gửi analytics…)

 Xóa entry khỏi dictionary để tránh leak/gọi lặp lại.

 6) Tại sao không so sánh viewController (tham số thứ 3) mà lại lấy .from?

 Tham số viewController của didShow là VC “đã hiện ra” (màn hình đích sau transition), không phải màn vừa rời đi.

 Muốn biết ai bị rời, phải hỏi transitionCoordinator và lấy “.from”.

 Tóm tắt luồng suy luận

 Đợi transition kết thúc (didShow) để có kết quả xác thực.

 Hỏi transitionCoordinator xem màn hình “from” là ai.

 Nếu “from” không còn trong viewControllers ⇒ đó là VC vừa bị pop.

 Gọi performOnDismissed(for:) để chạy callback và dọn dẹp.
 */

// MARK: - UINavigationControllerDelegate
extension NavigationRouter: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let dismissedViewController = navigationController.transitionCoordinator?
            .viewController(forKey: .from),
              !navigationController.viewControllers
            .contains(dismissedViewController) else {
            return
        }
        
        performOnDismissed(for: dismissedViewController)
    }
}

// -> Check tiếp coordinator
