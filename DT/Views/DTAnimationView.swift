
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTAnimationView: UIView {
    
    let showResultWithoutAnimation = PublishRelay<GameResultModel>()
    let showResultWithAnimation = PublishRelay<GameResultModel>()
    let beginAnimation = PublishRelay<Void>()
    let finishFlipCard = PublishRelay<Void>()
    let showWinner = PublishRelay<String>()
    let finishAnimation = PublishRelay<Void>()

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
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTAnimationView {

    func setupUI() {
        setupDragonImage()
        setupTigerImage()
        setupPokerResultView()
    }

    func setupDragonImage() {
        dragonImageView.image = .init(named: "dragon")
        dragonImageView.contentMode = .scaleAspectFit
        addSubview(dragonImageView)
        
        dragonImageView.snp.makeConstraints {
            $0.width.equalTo(150.auto())
            $0.height.equalTo(160.auto())
            $0.leading.centerY.equalToSuperview()
        }
    }
    
    func setupTigerImage() {
        tigerImageView.image = .init(named: "tiger")
        tigerImageView.contentMode = .scaleAspectFit
        addSubview(tigerImageView)
        
        tigerImageView.snp.makeConstraints {
            $0.width.equalTo(120.auto())
            $0.height.equalTo(180.auto())
            $0.trailing.centerY.equalToSuperview().inset(20.auto())
        }
    }
    
    func setupPokerResultView() {
        addSubview(pokerResultView)
        pokerResultView.snp.makeConstraints {
            $0.width.equalTo(200.auto())
            $0.height.equalTo(100.auto())
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(50.auto())
        }
    }
}

// MARK: - Bind
private extension DTAnimationView {
    func bind() {
        showResultWithoutAnimation
            .bind(to: pokerResultView.showResultWithoutAnimation)
            .disposed(by: disposeBag)
        
        beginAnimation
            .bind(to: pokerResultView.beginAnimation)
            .disposed(by: disposeBag)
        
        showResultWithAnimation
            .bind(to: pokerResultView.showResultWithAnimation)
            .disposed(by: disposeBag)
        
        pokerResultView
            .finishFlipCard
            .bind(to: finishFlipCard)
            .disposed(by: disposeBag)
        
        showWinner
            .withUnretained(self)
            .subscribe(onNext: { owner, winner in
                let imageView = UIImageView()
                if winner == "dragon" {
                    imageView.image = .init(named: "dragon")
                    owner.dragonImageView.addSubview(imageView)
                } else if winner == "tiger" {
                    imageView.image = .init(named: "tiger")
                    owner.tigerImageView.addSubview(imageView)
                } else {
                    owner.finishAnimation.accept(())
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
                    owner.finishAnimation.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private functions
private extension DTAnimationView {
    
}
