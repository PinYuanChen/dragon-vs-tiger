
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTCountDownView: UIView {
    
    var currentTime: Int {
        set { time.accept(newValue) }
        get { time.value ?? 0 }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundShapeLayer = CAShapeLayer()
    private let timeShapeLayer = CAShapeLayer()
    private let timeLabel = UILabel()
    private let time = BehaviorRelay<Int?>(value: nil)
    private let inAnimation = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTCountDownView {
    
    func setupUI() {
        backgroundColor = .clear
        drawShapeLayer(shapeLayer: backgroundShapeLayer,
                       radius: 20.zoom(),
                       lineWidth: 3,
                       strokeColor: "00224C".hexColorWithAlpha(1.0))
        drawShapeLayer(shapeLayer: timeShapeLayer,
                       radius: 20.zoom(),
                       lineWidth: 3,
                       strokeColor: .clear)
        setupTimeLabel()
    }
    
    func drawShapeLayer(
        shapeLayer: CAShapeLayer,
        radius: CGFloat,
        lineWidth: CGFloat,
        strokeColor: UIColor
    ) {
        shapeLayer.path = UIBezierPath(arcCenter: .init(x: 20.zoom(), y: 20.zoom()),
                                       radius: radius,
                                       startAngle: -90.degreesToRadians,
                                       endAngle: 270.degreesToRadians,
                                       clockwise: true).cgPath
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
    }
    
    func setupTimeLabel() {
        timeLabel.font = .systemFont(ofSize: 16.zoom())
        timeLabel.textAlignment = .center
        timeLabel.textColor = .systemGreen
        addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension DTCountDownView {
    func bind() {
        rx
            .observe(\.isHidden)
            .filter { $0 }
            .map { _ in false }
            .bind(to: inAnimation)
            .disposed(by: disposeBag)
        
        time
            .compactMap { $0 }
            .map { String(format: "%d", $0) }
            .asDriver(onErrorJustReturn: "")
            .drive(timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        time
            .compactMap { $0 }
            .withUnretained(self)
            .map { owner, time -> UIColor in
                0...5 ~= time ? .red : .white
            }
            .asDriver(onErrorJustReturn: .clear)
            .drive(timeLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        time
            .compactMap { $0 }
            .filter { 0...5 ~= $0 }
            .withUnretained(timeLabel)
            .subscribe(onNext: { timeLabel, _ in
                UIView.animate(withDuration: 0.95,
                               delay: 0,
                               options: .curveEaseInOut) {
                    timeLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                } completion: { finish in
                    timeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            })
            .disposed(by: disposeBag)
        
        time
            .compactMap { $0 }
            .filter { $0 >= 0 }
            .withUnretained(self)
            .map { owner, time -> UIColor in
                0...5 ~= time ? .red : .systemGreen
            }
            .map { $0.cgColor }
            .asDriver(onErrorJustReturn: UIColor.clear.cgColor)
            .drive(timeShapeLayer.rx.strokeColor)
            .disposed(by: disposeBag)
        
        time
            .compactMap { $0 }
            .withLatestFrom(inAnimation) { ($0, $1) }
            .filter { !$0.1 }
            .subscribe(onNext: { [weak self] time, _ in
                guard let self = self else { return }
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                animation.fromValue = Float(time) / 10.0
                animation.toValue = 0
                animation.duration = CFTimeInterval(time)
                animation.delegate = self
                
                self.timeShapeLayer.add(animation, forKey: animation.keyPath)
                self.inAnimation.accept(true)
            })
            .disposed(by: disposeBag)
        
        inAnimation
            .filter { !$0 }
            .map { _ in UIColor.clear.cgColor }
            .asDriver(onErrorJustReturn: UIColor.clear.cgColor)
            .drive(timeShapeLayer.rx.strokeColor)
            .disposed(by: disposeBag)
    }
}

extension DTCountDownView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        inAnimation.accept(false)
    }
}


private extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * .pi / 180
    }
}
