
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol DTPokerResultInputPrototype {
    func showResult(_: GameResultModel, withAnimation: Bool)
    func beginAnimation()
}

protocol DTPokerResultOutputPrototype {
    var finishFlipCard: Observable<Void> { get }
}

protocol DTPokerResultPrototype {
    var input: DTPokerResultInputPrototype { get }
    var output: DTPokerResultOutputPrototype { get }
}

class DTPokerResultView: UIView, DTPokerResultPrototype {
    
    var input: DTPokerResultInputPrototype { self }
    var output: DTPokerResultOutputPrototype { self }

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
    private let _finishFlipCard = PublishRelay<Void>()
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
            $0.width.equalTo(50.zoom())
            $0.height.equalTo(75.zoom())
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
        tigerPoker
            .output
            .finishFlipCard
            .bind(to: _finishFlipCard)
            .disposed(by: disposeBag)
    }
}

// MARK: - Input
extension DTPokerResultView: DTPokerResultInputPrototype {
    func showResult(_ result: GameResultModel, withAnimation: Bool) {
        dragonPoker.input.setSuit(result.dragon)
        tigerPoker.input.setSuit(result.tiger)
        
        if withAnimation {
            dragonPoker.input.flipCard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tigerPoker.input.flipCard()
            }
        }
    }
    
    func beginAnimation() {
        resetCardsLayout()
    }

}

// MARK: - Output
extension DTPokerResultView: DTPokerResultOutputPrototype {
    var finishFlipCard: Observable<Void> {
        _finishFlipCard.asObservable()
    }
}

// MARK: - Private functions
private extension DTPokerResultView {
    func resetCardsLayout() {
        dragonPoker.snp.remakeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(50.zoom())
            $0.height.equalTo(75.zoom())
        }
        
        tigerPoker.snp.remakeConstraints {
            $0.center.equalTo(dragonPoker)
            $0.size.equalTo(dragonPoker)
        }
        
        dragonPoker.input.foldCard()
        tigerPoker.input.foldCard()
        
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
                    self.dragonPoker.transform = .init(translationX: (-75.zoom()), y: 25.zoom())
                }
        UIView
            .animate(
                withDuration: 0.92,
                delay: 0.08,
                options: .curveEaseInOut) { [weak self] in
                    guard let self = self else { return }
                    self.tigerPoker.transform = .init(translationX: 75.zoom(), y: CGFloat(25.zoom()))
                }
    }
}
