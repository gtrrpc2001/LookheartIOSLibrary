import UIKit

class UnderLineTextField: UITextField {

    lazy var placeholderColor: UIColor = self.tintColor
    lazy var placeholderString: String = ""

    // 입력 Text 여백
    var textPadding = UIEdgeInsets (top: 0, left: 3, bottom: 0, right: 0)
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    // underLine
    private lazy var underLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        return lineView
    }()

    override init(frame: CGRect){
        super.init(frame: frame)

        addSubview(underLineView)

        underLineView.snp.makeConstraints {
            $0.top.equalTo(self.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }

        // textField 변경 시작과 종료에 대한 action
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // placeholder 설정
    func setPlaceholder(placeholder: String, color: UIColor){
        placeholderString = placeholder
        placeholderColor = color
        
        setPlaceholder()
        underLineView.backgroundColor = placeholderColor
    }

    func setPlaceholder() {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor, .font: UIFont.systemFont(ofSize: 13)]
        )
    }
    
    func setError() {
        underLineView.backgroundColor = .red
    }
    
    func setUnderLineColor(_ color: UIColor) {
        underLineView.backgroundColor = color
        underLineView.layoutIfNeeded()
    }
}

extension UnderLineTextField {
    @objc func editingDidBegin(){
        setPlaceholder()
        underLineView.backgroundColor = UIColor.MY_BLUE
    }
    
    @objc func editingDidEnd(){
//        underLineView.backgroundColor = placeholderColor
    }
}
