

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayCollectionViewCell: UICollectionViewCell {
    
    var reuseDisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = .init()
    }
    
    private let flashView = FlashView(frame: .zero)
    private let titleLabel = UILabel()
    private let oddsLabel = UILabel()
    private let chipInfoView = ChipInfoView(frame: .zero)
    private let betMoneyLabel = UILabel()
}


// MARK: - Setup UI
private extension DTPlayCollectionViewCell {
    func setupUI() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        clipsToBounds = true
        contentView.backgroundColor = .systemGray.withAlphaComponent(0.3)
        
        setupFlashView()
        setupTitleLabel()
        setupOddsLabel()
        setupChipInfoView()
        setupBetMoneyLabel()
    }
    
    func setupFlashView() {
        contentView.addSubview(flashView)
        flashView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupTitleLabel() {
        titleLabel.text = "龍"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24.auto())
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20.auto())
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30.auto())
        }
    }
    
    func setupOddsLabel() {
        oddsLabel.text = "1.5"
        oddsLabel.textColor = .white
        contentView.addSubview(oddsLabel)
        oddsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
            $0.height.equalTo(20.auto())
        }
    }
    
    func setupChipInfoView() {
        contentView.addSubview(chipInfoView)
        chipInfoView.snp.makeConstraints {
            $0.width.equalTo(46.auto())
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(4.auto())
        }
    }
    
    func setupBetMoneyLabel() {
        betMoneyLabel.layer.borderColor = UIColor.white.cgColor
        betMoneyLabel.layer.borderWidth = 1
        betMoneyLabel.backgroundColor = .systemGreen.withAlphaComponent(0.5)
        betMoneyLabel.textColor = .green
        betMoneyLabel.layer.cornerRadius = 4.auto()
        betMoneyLabel.layer.masksToBounds = true
        betMoneyLabel.textAlignment = .center
        betMoneyLabel.font = .systemFont(ofSize: 14.auto())
        betMoneyLabel.text = "5K"
        
        contentView.addSubview(betMoneyLabel)
        betMoneyLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(10.auto())
            $0.height.equalTo(20.auto())
            $0.width.equalTo(50.auto())
        }
    }
}

// MARK: - Bind
private extension DTPlayCollectionViewCell {
    func bind() {
        
    }
}
