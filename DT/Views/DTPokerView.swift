
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPokerView: UIView {
    
    var suit: SuitModel {
        set { _suit.accept(newValue) }
        get { _suit.value }
    }
    
    let foldCard = PublishRelay<Void>()
    let flipCard = PublishRelay<Void>()
    let finishFlipCard = PublishRelay<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let _suit = BehaviorRelay<SuitModel>(value: .init(suit: .heart, number: 1))
    private let cardBackImageView = UIImageView()
    private let suitLabel = UILabel()
    private let numLabel = UILabel()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTPokerView {

    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        setupSuitLabel()
        setupNumLabel()
        setupCardImageView()
    }

    func setupSuitLabel() {
        suitLabel.textAlignment = .center
        suitLabel.font = .boldSystemFont(ofSize: 20.auto())
        
        addSubview(suitLabel)
        suitLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15.auto())
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupNumLabel() {
        numLabel.textAlignment = .center
        numLabel.font = .boldSystemFont(ofSize: 20.auto())
        
        addSubview(numLabel)
        numLabel.snp.makeConstraints {
            $0.top.equalTo(suitLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupCardImageView() {
        cardBackImageView.isHidden = true
        cardBackImageView.image = .init(named: "card_back_orange")
        addSubview(cardBackImageView)
        cardBackImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension DTPokerView {
    func bind() {
        _suit
            .withUnretained(self)
            .subscribe(onNext: { owner, suit in
                let color = suit.suit.color
                owner.suitLabel.textColor = color
                owner.numLabel.textColor = color
                
                owner.suitLabel.text = suit.suit.title
                owner.numLabel.text = "\(suit.number)"
            })
            .disposed(by: disposeBag)
        
        foldCard
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.cardBackImageView.isHidden = false
                owner.suitLabel.isHidden = true
                owner.numLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        flipCard
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                UIView.transition(with: self,
                                  duration: 0.5,
                                  options: .transitionFlipFromLeft,
                                  animations: {
                    owner.cardBackImageView.isHidden = true
                    owner.suitLabel.isHidden = false
                    owner.numLabel.isHidden = false
                }, completion: { _ in
                    owner.finishFlipCard.accept(())
                })
            })
            .disposed(by: disposeBag)
    }
}
