
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol DTAnimationInputPrototype {
    func showResult(_: GameResultModel, withAnimation: Bool)
    func beginAnimation()
    func showWinner(_: String)
    func enableBetting(_: Bool)
}

protocol DTAnimationOutputPrototype {
    var finishFlipCard: Observable<Void> { get }
    var finishAnimation: Observable<Void> { get }
}

protocol DTAnimationPrototype {
    var input: DTAnimationInputPrototype { get }
    var output: DTAnimationOutputPrototype { get }
}

class DTAnimationView: UIView, DTAnimationPrototype {
    
    var input: DTAnimationInputPrototype { self }
    var output: DTAnimationOutputPrototype { self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dragonImageView = UIImageView()
    private let tigerImageView = UIImageView()
    private let pokerResultView = DTPokerResultView(frame: .zero)
    private let statusLabel = UILabel()
    private let _finishFlipCard = PublishRelay<Void>()
    private let _finishAnimation = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTAnimationView {

    func setupUI() {
        setupDragonImage()
        setupTigerImage()
        setupPokerResultView()
        setupStatusLabel()
    }

    func setupDragonImage() {
        dragonImageView.image = .init(named: "dragon")
        dragonImageView.contentMode = .scaleAspectFit
        addSubview(dragonImageView)
        
        dragonImageView.snp.makeConstraints {
            $0.width.equalTo(150.zoom())
            $0.height.equalTo(160.zoom())
            $0.leading.centerY.equalToSuperview()
        }
    }
    
    func setupTigerImage() {
        tigerImageView.image = .init(named: "tiger")
        tigerImageView.contentMode = .scaleAspectFit
        addSubview(tigerImageView)
        
        tigerImageView.snp.makeConstraints {
            $0.width.equalTo(120.zoom())
            $0.height.equalTo(180.zoom())
            $0.trailing.centerY.equalToSuperview().inset(20.zoom())
        }
    }
    
    func setupPokerResultView() {
        addSubview(pokerResultView)
        pokerResultView.snp.makeConstraints {
            $0.width.equalTo(200.zoom())
            $0.height.equalTo(100.zoom())
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(50.zoom())
        }
    }
    
    func setupStatusLabel() {
        statusLabel.alpha = 0
        statusLabel.font = .systemFont(ofSize: 20.zoom())
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10.zoom()
        statusLabel.layer.masksToBounds = true
        
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(40.zoom())
            $0.width.equalTo(200.zoom())
        }
    }
}

// MARK: - Bind
private extension DTAnimationView {
    func bind() {
        pokerResultView
            .output
            .finishFlipCard
            .bind(to: _finishFlipCard)
            .disposed(by: disposeBag)
    }
}

// MARK: - Input
extension DTAnimationView: DTAnimationInputPrototype {
    func showResult(_ result: GameResultModel, withAnimation: Bool) {
        pokerResultView.input.showResult(result, withAnimation: withAnimation)
    }
    
    func beginAnimation() {
        pokerResultView.input.beginAnimation()
    }
    
    func showWinner(_ winner: String) {
        let imageView = UIImageView()
        if winner == "dragon" {
            imageView.image = .init(named: "dragon")
            dragonImageView.addSubview(imageView)
        } else if winner == "tiger" {
            imageView.image = .init(named: "tiger")
            tigerImageView.addSubview(imageView)
        } else {
            _finishAnimation.accept(())
            return
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.transform = .identity
        
        UIView
            .animate(
                withDuration: 1,
                delay: 0,
                options: [.curveEaseInOut, .repeat]) {
                    imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                    imageView.alpha = 0
                }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            imageView.removeFromSuperview()
            self._finishAnimation.accept(())
        }
    }
    
    func enableBetting(_ enabled: Bool) {
        statusLabel.backgroundColor = enabled ? .systemBlue : .systemRed
        statusLabel.text = enabled ? "開盤" : "封盤"
        statusLabel.fadeInAndOut(duration: 0.5)
    }
}

// MARK: - Output
extension DTAnimationView: DTAnimationOutputPrototype {
    var finishFlipCard: Observable<Void> {
        _finishFlipCard.asObservable()
    }
    
    var finishAnimation: Observable<Void> {
        _finishAnimation.asObservable()
    }
}
