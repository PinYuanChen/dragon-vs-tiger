
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPokerResultView: UIView {
    
    let showResultWithoutAnimation = PublishRelay<GameResultModel>()
    let showResultWithAnimation = PublishRelay<GameResultModel>()

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
    }
}
