import Foundation
import UIKit
import Then
import SnapKit


enum ChartType {
    case BPM
    case HRV
    case ARR
    case CALORIE
    case STEP
}

@available(iOS 13.0, *)
public class SummaryViewController : UIViewController {
    
    private let BPM_BUTTON_TAG = 1
    private let ARR_BUTTON_TAG = 2
    private let HRV_BUTTON_TAG = 3
    private let CAL_BUTTON_TAG = 4
    private let STEP_BUTTON_TAG = 5
    
    private let lineChartView = LineChartVC()
    private let barChartView = BarChartVC()
    
    private var arrChild: [UIViewController] = []
    
    private lazy var buttons: [UIButton] = {
        return [bpmButton, arrButton, hrvButton, calorieButton, stepButton]
    }()
    
    private lazy var images: [UIImageView] = {
        return [bpmImage, arrImage, hrvImage, calorieImage, stepImage]
    }()
    
    private lazy var childs: [UIViewController] = {
        return [lineChartView, barChartView]
    }()
    
    // MARK: -
    private let safeAreaView = UIView()

    // ------------------------ Top Button ------------------------
    private lazy var bpmImage = UIImageView().then {
        let image = UIImage(named: "summary_bpm")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.white
    }
    
    private lazy var arrImage = UIImageView().then {
        let image = UIImage(named: "summary_arr")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var hrvImage = UIImageView().then {
        let image = UIImage(named: "summary_hrv")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var calorieImage = UIImageView().then {
        let image = UIImage(named: "summary_cal")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var stepImage = UIImageView().then {
        let image = UIImage(named: "summary_step")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    // ------------------------ BUTTON ------------------------
    private lazy var bpmButton = UIButton().then {
        $0.setTitle("summaryBpm".localized(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 0
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = BPM_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var arrButton = UIButton().then {
        $0.setTitle("summaryArr".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = ARR_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }

    private lazy var hrvButton = UIButton().then {
        $0.setTitle("summaryHRV".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = HRV_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var calorieButton = UIButton().then {
        $0.setTitle("summaryCal".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = CAL_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    
    private lazy var stepButton = UIButton().then {
        $0.setTitle("summaryStep".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = STEP_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }

    
    @objc private func ButtonEvent(_ sender: UIButton) {
        
        setButtonColor(sender)
        
        switch(sender.tag) {
        case BPM_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(.BPM)
        case ARR_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.ARR)
        case HRV_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(.HRV)
        case CAL_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.CALORIE)
        case STEP_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.STEP)
        default:
            break
        }
    }
    
    private func setChild(selectChild: UIViewController, in containerView: UIView) {
        for child in childs {
            if child == selectChild {
                addChild(child, in: containerView)
            } else {
                removeChild(child)
            }
        }
    }
    
    // MARK: - viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setChild(selectChild: lineChartView, in: self.view)
        lineChartView.refreshView(.BPM)
        setButtonColor(buttons[BPM_BUTTON_TAG - 1])
        
    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttons {
            if button == sender {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
                button.layer.borderWidth = 0
                
                images[button.tag-1].tintColor = UIColor.white
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                button.backgroundColor = .white
                button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
                button.layer.borderWidth = 3
                
                images[button.tag-1].tintColor = UIColor.lightGray
            }
        }
    }
    
    func addChild(_ child: UIViewController, in containerView: UIView) {

        addChild(child)
        containerView.addSubview(child.view)
        
        child.view.snp.makeConstraints { make in
            make.top.equalTo(calorieButton.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        child.didMove(toParent: self)
                
        if !arrChild.contains(where: { $0 === child }) {
            arrChild.append(child)
        }
        
    }

    // 자식 뷰 컨트롤러 제거
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    // MARK: - addViews
    func addViews() {
        
        let buttonWidth = (self.view.frame.size.width - 60) / 5
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        // bpm
        view.addSubview(bpmButton)
        bpmButton.snp.makeConstraints { make in
            make.top.left.equalTo(safeAreaView).offset(10)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(50)
        }
        
        view.addSubview(bpmImage)
        bpmImage.snp.makeConstraints { make in
            make.top.equalTo(bpmButton).offset(5)
            make.centerX.equalTo(bpmButton)
        }

        // arr
        view.addSubview(arrButton)
        arrButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(bpmButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        view.addSubview(arrImage)
        arrImage.snp.makeConstraints { make in
            make.top.equalTo(arrButton).offset(5)
            make.centerX.equalTo(arrButton)
        }
        
        // hrv
        view.addSubview(hrvButton)
        hrvButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(arrButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        view.addSubview(hrvImage)
        hrvImage.snp.makeConstraints { make in
            make.top.equalTo(hrvButton).offset(5)
            make.centerX.equalTo(hrvButton)
        }
        
        // cal
        view.addSubview(calorieButton)
        calorieButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(hrvButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        view.addSubview(calorieImage)
        calorieImage.snp.makeConstraints { make in
            make.top.equalTo(calorieButton).offset(5)
            make.centerX.equalTo(calorieButton)
        }
        
        // step
        view.addSubview(stepButton)
        stepButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(calorieButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        view.addSubview(stepImage)
        stepImage.snp.makeConstraints { make in
            make.top.equalTo(stepButton).offset(5)
            make.centerX.equalTo(stepButton)
        }
        
        addChild(lineChartView)
        view.addSubview(lineChartView.view)
        lineChartView.didMove(toParent: self)
        lineChartView.view.snp.makeConstraints { make in
            make.top.equalTo(calorieButton.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
    }
}
