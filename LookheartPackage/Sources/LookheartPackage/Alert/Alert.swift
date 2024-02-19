import UIKit

public class MyAlert {
    public static let shared = MyAlert()
    
    public init() {}
    
    public func basicAlert(title: String, message: String, ok: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default)
        alert.addAction(complite)
        viewController.present(alert, animated: true, completion: {})
    }
    
    public func basicActionAlert(title: String, message: String, ok: String, viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default) { _ in
            completion()
        }
        alert.addAction(complite)
        viewController.present(alert, animated: true, completion: {})
    }
    
    public func basicPasswordAlert(viewController: UIViewController, completion: @escaping (String) -> Void) {

        let alertController = UIAlertController(title: "pw_Label".localized(), message: "password_Hint".localized(), preferredStyle: .alert)

        // 텍스트 필드
        alertController.addTextField { textField in
            textField.placeholder = "password_Label".localized()
            textField.isSecureTextEntry = true // 비밀번호 입력 필드로 설정
        }

        // 확인 버튼
        let confirmAction = UIAlertAction(title: "ok".localized(), style: .default) { _ in
            if let password = alertController.textFields?.first?.text {
                // 비밀번호
                completion(password)
            }
        }

        // 취소 버튼
        let cancelAction = UIAlertAction(title: "reject".localized(), style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
}
