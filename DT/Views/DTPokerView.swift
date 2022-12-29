
import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DTPokerViewInput {
    case setSuit(suit: SuitModel)
    case foldCard
    case flipCard
}

enum DTPokerViewOutput {
    case finishFlipCard
}

class DTPokerView: UIView {
    
    var input = PublishRelay<DTPokerViewInput>()
    var output = PublishRelay<DTPokerViewOutput>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindInputOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        suitLabel.font = .boldSystemFont(ofSize: 20.zoom())
        
        addSubview(suitLabel)
        suitLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15.zoom())
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupNumLabel() {
        numLabel.textAlignment = .center
        numLabel.font = .boldSystemFont(ofSize: 20.zoom())
        
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

// MARK: - Binding
private extension DTPokerView {
    func bindInputOutput() {
        input
            .withUnretained(self)
            .subscribe(onNext: { owner, input in
                switch input {
                case .setSuit(suit: let suit):
                    owner.setSuit(suit)
                case .foldCard:
                    owner.foldCard()
                case .flipCard:
                    owner.flipCard()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private functions
extension DTPokerView {
    func setSuit(_ suit: SuitModel) {
        let color = suit.suit.color
        suitLabel.textColor = color
        numLabel.textColor = color
        
        suitLabel.text = suit.suit.title
        numLabel.text = "\(suit.number)"
    }
    
    func foldCard() {
        cardBackImageView.isHidden = false
        suitLabel.isHidden = true
        numLabel.isHidden = true
    }
    
    func flipCard() {
        UIView.transition(with: self,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { [weak self] in
            guard let self = self else { return }
            self.cardBackImageView.isHidden = true
            self.suitLabel.isHidden = false
            self.numLabel.isHidden = false
        }, completion: { _ in
            self.output.accept(.finishFlipCard)
        })
    }
}
