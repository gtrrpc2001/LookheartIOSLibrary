import UIKit
import AVFAudio
import AudioToolbox

public class EmergencyAlert: UIViewController {
        
    private var audioPlayer: AVAudioPlayer?
    
    private var titleLabel: UILabel?
    private var timeLabel: UILabel?
    private var locationLabel: UILabel?
    
    private var emergencyTitle: String
    private var emergencyTime: String
    private var emergencyLocation: String
    
    public init(title: String, time: String, location: String) {
        self.emergencyTitle = title
        self.emergencyTime = time
        self.emergencyLocation = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        startAudioPlayer()
        
    }
    
    public func updateText(title: String, time: String, location: String) {
        titleLabel?.text = title
        timeLabel?.text = time
        locationLabel?.text = location
    }
    
    @objc func didTapActionButton() {
        audioPlayer?.stop()
        dismiss(animated: true)
    }
    
    func startAudioPlayer() {
        setupEmergencyAudioPlayer("heartAttackSound")
        audioPlayer?.play()
    }
    
    
    func setupEmergencyAudioPlayer(_ soundFile: String) {
        guard let url = Bundle.module.url(forResource: soundFile, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 무한 반복 재생
            audioPlayer?.prepareToPlay()
        } catch {
            print("오디오 파일을 로드할 수 없습니다: \(error)")
        }
    }

    private func addViews() {
        
        func createImage() -> UIImageView {
            let imageView = propCreateUI.imageView(tintColor: UIColor.MY_RED, backgroundColor: .clear, contentMode: .scaleAspectFit).then {
                let image =  UIImage(named: "summary_bpm")!
                let coloredImage = image.withRenderingMode(.alwaysTemplate)
                $0.image = coloredImage
            }
            return imageView
        }
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // create
        let backgroundView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
        }
                     
        titleLabel = propCreateUI.label(text: emergencyTitle, color: .white, size: 18, weight: .heavy).then {
            $0.backgroundColor = UIColor.MY_RED
            $0.textAlignment = .center
        }
        
        let timeImg = createImage()
        let locationImg = createImage()
        
        let timeTitle = propCreateUI.label(text: "occurrenceTime".localized(), color: UIColor.MY_RED, size: 14, weight: .bold)
        let locationTitle = propCreateUI.label(text: "occurrenceLocation".localized(), color: UIColor.MY_RED, size: 14, weight: .bold)
        
        timeLabel = propCreateUI.label(text: emergencyTime, color: .black, size: 14, weight: .bold)
        locationLabel = propCreateUI.label(text: emergencyLocation, color: .black, size: 14, weight: .bold).then {
            $0.numberOfLines = 5
        }
        
        let actionButton = UIButton().then {
            $0.setTitle("\("ok".localized())", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
            $0.backgroundColor = UIColor.MY_RED
            $0.tintColor = .white
            $0.layer.cornerRadius = 10
            $0.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        }
                
        // addSubview
        view.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel!)
        
        backgroundView.addSubview(timeImg)
        backgroundView.addSubview(timeTitle)
        backgroundView.addSubview(timeLabel!)
        
        backgroundView.addSubview(locationImg)
        backgroundView.addSubview(locationTitle)
        backgroundView.addSubview(locationLabel!)
        
        backgroundView.addSubview(actionButton)
        
        
        // makeConstraints
        backgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(screenWidth / 1.2)
            make.height.equalTo(200)
        }
        
        titleLabel!.snp.makeConstraints { make in
            make.top.left.right.equalTo(backgroundView)
            make.height.equalTo(40)
        }
        
        // Time
        timeImg.snp.makeConstraints { make in
            make.top.equalTo(titleLabel!.snp.bottom).offset(10)
            make.left.equalTo(backgroundView).offset(5)
            make.width.equalTo(10)
        }
        
        timeTitle.snp.makeConstraints { make in
            make.centerY.equalTo(timeImg)
            make.left.equalTo(timeImg.snp.right).offset(3)
        }
        
        
        timeLabel!.snp.makeConstraints { make in
            make.centerY.equalTo(timeImg)
            make.left.equalTo(timeTitle.snp.right).offset(5)
            make.right.equalTo(backgroundView)
        }
        
        // Location
        locationImg.snp.makeConstraints { make in
            make.top.equalTo(timeTitle.snp.bottom).offset(10)
            make.left.width.equalTo(timeImg)
        }
        
        locationTitle.snp.makeConstraints { make in
            make.centerY.equalTo(locationImg)
            make.left.equalTo(timeTitle)
        }
        
        locationLabel!.snp.makeConstraints { make in
            make.centerY.equalTo(locationImg)
            make.left.equalTo(locationTitle.snp.right).offset(5)
            make.right.equalTo(backgroundView)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.bottom.equalTo(backgroundView).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(35)
        }

    }
}
