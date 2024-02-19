import Foundation
import UIKit

public class BasicAlert: UIViewController {
    
    private var titleLabel: UILabel?
    private var messageLabel: UILabel?
    
    private var alertTitle: String
    private var alertMessage: String
    
    // Init
    public init(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Button Event
    @objc func didTapActionButton() {
        dismiss(animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
    }
    
    public func updateText(title: String, message: String) {
        titleLabel?.text = title
        messageLabel?.text = message
    }
    
    private func addViews() {
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let screenWidth = UIScreen.main.bounds.width
        
        // create
        let blueBackground = propCreateUI.backgroundLabel(backgroundColor: UIColor.MY_BLUE, borderColor: UIColor.clear.cgColor, borderWidth: 0, cornerRadius: 20).then {
            $0.isUserInteractionEnabled = true
        }

        let whitebackground = propCreateUI.backgroundLabel(backgroundColor: .white, borderColor: UIColor.clear.cgColor, borderWidth: 0, cornerRadius: 20)
        
        titleLabel = propCreateUI.label(text: alertTitle, color: .white, size: 18, weight: .heavy).then {
            $0.textAlignment = .center
        }
                    
        messageLabel = propCreateUI.label(text: alertMessage, color: UIColor.MY_BLUE, size: 14, weight: .heavy).then {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 15 // 문자 위아래 간격
            
            let attributedString = NSMutableAttributedString(string: alertMessage)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            $0.attributedText = attributedString
            $0.textAlignment = .center
            $0.numberOfLines = 10
        }
        
        let backButton = propCreateUI.button(title: "X", titleColor: .white, size: 18, weight: .heavy, backgroundColor: .clear, tag: 0).then {
            $0.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
                
        // addSubview
        view.addSubview(blueBackground)
        blueBackground.addSubview(whitebackground)
        blueBackground.addSubview(titleLabel!)
        blueBackground.addSubview(messageLabel!)
        blueBackground.addSubview(backButton)
        
        
        // makeConstraints
        // Background
        blueBackground.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(screenWidth / 1.2)
            make.height.equalTo(200)
        }
        
        // Title
        titleLabel!.snp.makeConstraints { make in
            make.top.left.right.equalTo(blueBackground)
        }
        
        // Background
        whitebackground.snp.makeConstraints { make in
            make.top.equalTo(titleLabel!.snp.bottom)
            make.left.equalTo(blueBackground).offset(7)
            make.right.equalTo(blueBackground).offset(-7)
            make.bottom.equalTo(blueBackground).offset(-7)
        }
        
        // Message
        messageLabel!.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(whitebackground)
        }
        
        // Back Button
        backButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(titleLabel!)
            make.left.equalTo(titleLabel!).offset(10)
        }
    }
}
