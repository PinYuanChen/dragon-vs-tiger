
import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DTAnimationInput {
    case showResult(result: GameResultModel, withAnimation: Bool)
    case beginAnimation
    case showWinner(winner: String)
    case enableBetting(enable: Bool)
}

enum DTAnimationOutput {
    case finishFlipCard
    case finishAnimation
}

class DTAnimationView: UIView {
    
    var input = PublishRelay<DTAnimationInput>()
    var output = PublishRelay<DTAnimationOutput>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        bindInputOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dragonImageView = UIImageView()
    private let tigerImageView = UIImageView()
    private let pokerResultView = DTPokerResultView()
    private let statusView = DTStatusView(frame: .zero)
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
        setupstatusView()
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
    
    func setupstatusView() {
        statusView.alpha = 0
        statusView.layer.masksToBounds = true
        
        addSubview(statusView)
        statusView.snp.makeConstraints {
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
    
    func bindInputOutput() {
        input
            .withUnretained(self)
            .subscribe(onNext: { owner, type in
                switch type {
                case .showResult(result: let result, withAnimation: let withAnimation):
                    owner.showResult(result, withAnimation: withAnimation)
                case .beginAnimation:
                    owner.beginAnimation()
                case .showWinner(winner: let winner):
                    owner.showWinner(winner)
                case .enableBetting(enable: let enable):
                    owner.enableBetting(enable)
                }
            })
            .disposed(by: disposeBag)
        
        _finishFlipCard
            .map { DTAnimationOutput.finishFlipCard }
            .bind(to: output)
            .disposed(by: disposeBag)
        
        _finishAnimation
            .map { DTAnimationOutput.finishAnimation }
            .bind(to: output)
            .disposed(by: disposeBag)
    }
}

// MARK: - Private functions
extension DTAnimationView {
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
        statusView.image = enabled ? .init(named: "bluebanner") : .init(named: "redbanner")
        statusView.titleLabel.text = enabled ? "開盤" : "封盤"
        statusView.fadeInAndOut(duration: 0.5)
    }
}
