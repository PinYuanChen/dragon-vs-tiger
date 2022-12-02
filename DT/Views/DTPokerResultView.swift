
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPokerResultView: UIView {
    
    let showResultWithoutAnimation = PublishRelay<GameResultModel>()
    let showResultWithAnimation = PublishRelay<GameResultModel>()
    let beginAnimation = PublishRelay<Void>()
    let finishFlipCard = PublishRelay<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let dragonPoker = DTPokerView(frame: .zero)
    private let tigerPoker = DTPokerView(frame: .zero)
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTPokerResultView {

    func setupUI() {
        setupDragonPoker()
        setupTigerPoker()
    }

    func setupDragonPoker() {
        addSubview(dragonPoker)
        dragonPoker.snp.makeConstraints {
            $0.width.equalTo(50.auto())
            $0.height.equalTo(75.auto())
            $0.leading.bottom.equalToSuperview()
        }
    }
    
    func setupTigerPoker() {
        addSubview(tigerPoker)
        tigerPoker.snp.makeConstraints {
            $0.size.equalTo(dragonPoker)
            $0.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension DTPokerResultView {
    func bind() {
        showResultWithoutAnimation
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                owner.dragonPoker.suit = result.dragon
                owner.tigerPoker.suit = result.tiger
            })
            .disposed(by: disposeBag)
        
        showResultWithAnimation
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                owner.dragonPoker.suit = result.dragon
                owner.tigerPoker.suit = result.tiger
                owner.dragonPoker.flipCard.accept(())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    owner.tigerPoker.flipCard.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        beginAnimation
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.resetCardsLayout()
            })
            .disposed(by: disposeBag)
        
        tigerPoker
            .finishFlipCard
            .bind(to: finishFlipCard)
            .disposed(by: disposeBag)
    }
}

private extension DTPokerResultView {
    func resetCardsLayout() {
        dragonPoker.snp.remakeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(50.auto())
            $0.height.equalTo(75.auto())
        }
        
        tigerPoker.snp.remakeConstraints {
            $0.center.equalTo(dragonPoker)
            $0.size.equalTo(dragonPoker)
        }
        
        dragonPoker.foldCard.accept(())
        tigerPoker.foldCard.accept(())
        
        dragonPoker.isHidden = false
        tigerPoker.isHidden = false
        dragonPoker.transform = .identity
        tigerPoker.transform = .identity
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.drawCards()
        }
    }
    
    func drawCards() {
        UIView
            .animate(
                withDuration: 1,
                delay: 0,
                options: .curveEaseInOut) { [weak self] in
                    guard let self = self else { return }
                    self.dragonPoker.transform = .init(translationX: (-75.auto()), y: 25.auto())
                }
        UIView
            .animate(
                withDuration: 0.92,
                delay: 0.08,
                options: .curveEaseInOut) { [weak self] in
                    guard let self = self else { return }
                    self.tigerPoker.transform = .init(translationX: 75.auto(), y: CGFloat(25.auto()))
                }
    }
}
