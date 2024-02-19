import Foundation
import UIKit
import Then
import SnapKit
import PhoneNumberKit

public protocol AuthDelegate: AnyObject {
    func complete(phoneNumber: String)
    func cancle()
}

public class AuthPhoneNumber: UIView, UITableViewDataSource, UITableViewDelegate {
    public weak var delegate: AuthDelegate?
    
    private let numberRegex = try! NSRegularExpression(pattern: "[0-9]+")
    
    private let PHONE_NUMBER_TAG = 0
    private let AUTH_NUMBER_TAG = 1

    private let phoneNumberKit = PhoneNumberKit()
    private var countries: [String] {
        return phoneNumberKit.allCountries().filter { $0 != "001" }
    }

    private var authTextFieldHeightConstraint: Constraint?  // 기존 높이 제약 조건을 참조할 수 있도록 저장
    
    private var countdownTimer: Timer?
    private var countdown: Int = 180
    private var smsCnt = 5
    
    private var phoneNumber = ""
    private var nationalCode = ""
    private var authNumber = ""
    
    private var phoneNumberRegx = false
    private var authNumberRegx = false
    
    private lazy var toggleButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var sendButton = UIButton().then {
        $0.setTitle("requestVerification".localized(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor.MY_BLUE
    }

    private lazy var okButton = UIButton().then {
        $0.setTitle("ok".localized(), for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.MY_BLUE
    }
    
    private lazy var calcleButton = UIButton().then {
        $0.setTitle("reject".localized(), for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER2
    }
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.isHidden = true  // 초기에는 숨김
    }
    
    private lazy var phoneNumberTextField = UnderLineTextField().then {
        $0.textColor = .darkGray
        $0.keyboardType = .numberPad
        $0.tintColor = UIColor.MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.placeholderString = "enterMobilePhone".localized()
        $0.placeholderColor = UIColor.lightGray
        $0.tag = PHONE_NUMBER_TAG
    }
    
    private lazy var authTextField = UnderLineTextField().then {
        $0.textColor = .darkGray
        $0.keyboardType = .numberPad
        $0.textContentType = .oneTimeCode
        $0.tintColor = UIColor.MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.placeholderString = "enterVerificationCode".localized()
        $0.placeholderColor = UIColor.lightGray
        $0.tag = AUTH_NUMBER_TAG
        $0.isHidden = true
    }

    private let verifyNumberLabel = UILabel().then {
        $0.text = "verifyNumber".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        $0.textColor = UIColor.darkGray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    
    
    
    
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        updateToggleButtonTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setLayoutSubviews()
    }
    
    // MARK: tableView
    @objc func toggleButtonTapped() {
        tableView.isHidden = !tableView.isHidden            // 리스트 뷰의 표시 상태 토글
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let countryCode = countries[indexPath.row]
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = "\(flag)\(countryName)"
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        let countryCode = phoneNumberKit.countryCode(for: selectedCountry) ?? 0
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: selectedCountry) ?? selectedCountry
        let flag = emojiFlag(for: selectedCountry)
        
        toggleButton.setTitle("\(flag)\(countryName)", for: .normal)
        tableView.isHidden = !tableView.isHidden
        
        nationalCode = String(countryCode)
        print("Selected Country: \(selectedCountry) - Code: \(countryCode)")
    }
    
    private func emojiFlag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
    
    private func updateToggleButtonTitle() {
        let currentLocale = Locale.current
        let countryCode = currentLocale.regionCode ?? "US"
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        toggleButton.setTitle("\(flag)\(countryName)", for: .normal)
        
        // nationalCode 업데이트
        if let code = phoneNumberKit.countryCode(for: countryCode) {
            nationalCode = String(code)
        }
    }
    
    // MARK: - sendSMS Event
    @objc private func sendButtonEvent() {
        
        self.endEditing(true)
        
        if smsCnt > 0 && phoneNumber.count > 4 && phoneNumberRegx {
            
            updateUI()
            sendSMS()
            
        } else if phoneNumber.count < 4 || !phoneNumberRegx {
            showAlert(title: "noti".localized(), message: "validPhoneNumber".localized())
        } else {
            showAlert(title: "noti".localized(), message: "exceededNumber".localized())
        }
    }
    
    private func sendSMS() {
        NetworkManager.shared.sendSMS(phoneNumber: phoneNumber, nationalCode: nationalCode) { [self] result in
            switch result {
            case .success(let result):
                if result.contains("true") {
                    
                    startCountdown()
                    smsCnt -= 1
                    
                    showAlert(title: "requestVerification".localized(), message: "requestsRemaining".localized(with: smsCnt, comment: "cnt"))
                    
                } else if result.contains("false") {
                    showAlert(title: "failVerification".localized(), message: "againMoment".localized())
                } else {
                    // 횟수 초과
                    showAlert(title: "failVerification".localized(), message: "exceededNumber".localized())
                }
                
            case .failure(_):
                showAlert(title: "failVerification".localized(), message: "againMoment".localized())
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        guard let viewController = self.parentViewController else {
            print("View controller not found")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok".localized(), style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
    
    private func updateUI() {
        verifyNumberLabel.isHidden = false
        authTextField.isHidden = false
        sendButton.isEnabled = false
        
        authTextFieldHeightConstraint?.update(offset: 30)
        authTextField.layoutIfNeeded()  // 레이아웃 업데이트
                
        self.addSubview(verifyNumberLabel)
        verifyNumberLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(authTextField)
            make.left.equalTo(toggleButton).offset(3)
            make.right.equalTo(toggleButton)
        }
        
        verifyNumberLabel.layoutIfNeeded()
    }
    
    // MARK: - checkSMS Event
    @objc private func checkButtonEvent() {
        
        self.endEditing(true)
        
        if authNumber.count == 6 && authNumberRegx {
            checkSMS()
        } else {
            showAlert(title: "noti".localized(), message: "correctVerification".localized())
        }
    }
    
    private func checkSMS() {
        NetworkManager.shared.checkSMS(phoneNumber: phoneNumber, code: authNumber) { [self] result in
            switch result {
            case .success(let result):
                if result {
                    UserProfileManager.shared.phone = phoneNumber
                    delegate?.complete(phoneNumber: phoneNumber)
                } else {
                    // 시간 초과
                    showAlert(title: "failVerification".localized(), message: "exceededTime".localized())
                }
            case .failure(_):
                showAlert(title: "failVerification".localized(), message: "againMoment".localized())
            }
        }
    }
    
    // MARK: - cancleButton Event
    @objc private func cancleButtonEvent() {
        self.endEditing(true)
        delegate?.cancle()
    }
    
    // MARK: - keyboard
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? "Empty"
        
        switch (textField.tag) {
        case PHONE_NUMBER_TAG:
            
            phoneNumber = text
            if isNumberValid(phoneNumber) {
                phoneNumberRegx = true
                phoneNumberTextField.setUnderLineColor(UIColor.MY_BLUE)
            } else {
                phoneNumberRegx = false
                phoneNumberTextField.setUnderLineColor(.lightGray)
            }
            
        case AUTH_NUMBER_TAG:
            
            authNumber = text
            if isNumberValid(authNumber) {
                authNumberRegx = true
                authTextField.setUnderLineColor(UIColor.MY_BLUE)
            } else {
                authNumberRegx = false
                authTextField.setUnderLineColor(.lightGray)
            }
            
        default:
            break
        }
    }
    
    private func isNumberValid(_ number: String) -> Bool {
        return numberRegex.firstMatch(in: number, options: [], range: NSRange(location: 0, length: number.count)) != nil
    }
    
    // MARK: - timer
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        if countdown > 0 {
            countdown -= 1
            let sec = countdown % 60
            let min = (countdown / 60) % 60
            
            let secString = sec < 10 ? "0\(sec)" : "\(sec)"
            let minString = min < 10 ? "0\(min)" : "\(min)"
            
            sendButton.setTitle("\(minString):\(secString)", for: .normal)
        } else {
            countdown = 180
            countdownTimer?.invalidate()
            countdownTimer = nil
            sendButton.isEnabled = true
            sendButton.setTitle("resendText".localized(), for: .normal)
        }
    }
    
    // MARK: - addViews
    private func addTarget() {
        
        phoneNumberTextField.tag = PHONE_NUMBER_TAG
        authTextField.tag = AUTH_NUMBER_TAG
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        authTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        sendButton.addTarget(self, action: #selector(sendButtonEvent), for: .touchUpInside)
        
        okButton.addTarget(self, action: #selector(checkButtonEvent), for: .touchUpInside)
        calcleButton.addTarget(self, action: #selector(cancleButtonEvent), for: .touchUpInside)
        
    }
    
    private func setLayoutSubviews() {
        
        addTarget()
        setBorder()
        
        let underLine = UILabel().then {
            $0.backgroundColor = UIColor.MY_BLUE
        }
        
        self.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(1)
            make.left.equalTo(toggleButton).offset(3)
            make.right.equalTo(toggleButton)
            make.height.equalTo(2)
        }
    }
    
    private func addViews(){
        
        self.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let safeAreaView = UILabel().then { $0.backgroundColor = .white }
        self.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-50)
        }
        
        let borderLabel = UILabel().then {
            $0.layer.borderColor = UIColor.MY_BLUE.cgColor
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 2
            $0.layer.masksToBounds = true
            $0.backgroundColor = .clear
        }

        self.addSubview(borderLabel)
        borderLabel.snp.makeConstraints {
            $0.top.right.left.equalTo(safeAreaView)
            $0.bottom.equalToSuperview().offset(30)
        }
        
        let authLabel = UILabel().then {
            $0.text = "identityVerification".localized()
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
            $0.backgroundColor = UIColor.MY_BLUE
            $0.textAlignment = .center
            $0.layer.cornerRadius = 10
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]   // 왼쪽 위, 오른쪽 위 테두리 설정
            $0.clipsToBounds = true
        }
        self.addSubview(authLabel)
        authLabel.snp.makeConstraints { make in
            make.top.left.right.centerX.equalTo(safeAreaView)
            make.height.equalTo(40)
        }
        
        //
        let helpText = UILabel().then {
            $0.text = "helpAuthText".localized()
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
            $0.textColor = UIColor.MY_BLUE
            $0.textAlignment = .center
        }
        self.addSubview(helpText)
        helpText.snp.makeConstraints { make in
            make.top.equalTo(authLabel.snp.bottom).offset(50)
            make.left.right.equalTo(safeAreaView)
        }
        
        //
        self.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.top.equalTo(helpText.snp.bottom).offset(50)
            make.left.equalTo(safeAreaView).offset(10)
            make.width.equalTo(100)
        }
        
        // phoneNumberTextField
        self.addSubview(phoneNumberTextField)
        phoneNumberTextField.snp.makeConstraints { make in
            make.left.equalTo(toggleButton.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-100)
            make.top.equalTo(toggleButton)
            make.bottom.equalTo(toggleButton).offset(1)
        }
        
        // authTextField
        self.addSubview(authTextField)
        authTextField.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(20)
            make.left.right.equalTo(phoneNumberTextField)
            authTextFieldHeightConstraint = make.height.equalTo(0).constraint // 초기 높이 저장
        }
        
        //
        self.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(toggleButton)
            make.left.equalTo(phoneNumberTextField.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
        }
    
        //
        let authHelpText = UILabel().then {
            $0.text = "threeMinutesHelpText".localized()
            $0.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
            $0.textColor = UIColor.lightGray
        }
        self.addSubview(authHelpText)
        authHelpText.snp.makeConstraints { make in
            make.top.equalTo(authTextField.snp.bottom).offset(15)
            make.left.equalTo(toggleButton).offset(10)
        }
        
        //
        let authHelpText2 = UILabel().then {
            $0.text = "resendAuthNumber".localized()
            $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.textColor = UIColor.lightGray
        }
        self.addSubview(authHelpText2)
        authHelpText2.snp.makeConstraints { make in
            make.top.equalTo(authHelpText.snp.bottom).offset(5)
            make.left.equalTo(toggleButton).offset(10)
        }
        
        self.addSubview(okButton)
        okButton.snp.makeConstraints { make in
            make.top.equalTo(authHelpText2).offset(50)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(40)
        }
        
        self.addSubview(calcleButton)
        calcleButton.snp.makeConstraints { make in
            make.top.equalTo(okButton.snp.bottom).offset(10)
            make.left.right.height.equalTo(okButton)
        }
        
        // tableView
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(10)
            make.left.equalTo(toggleButton)
            make.right.equalTo(borderLabel).offset(-5)
            make.height.equalTo(300)
        }
    }
    
    private func setBorder() {
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = true

        okButton.layer.cornerRadius = 10
        okButton.layer.masksToBounds = true

        calcleButton.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        calcleButton.layer.cornerRadius = 10
        calcleButton.layer.borderWidth = 3
        calcleButton.layer.masksToBounds = true
    }
    
}
