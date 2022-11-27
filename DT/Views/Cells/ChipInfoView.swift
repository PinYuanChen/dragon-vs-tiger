
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChipInfoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let chipImageView = UIImageView()
    private let moneyLabel = UILabel()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension ChipInfoView {

    func setupUI() {
        setupChipImageView()
        setupMoneyLabel()
    }

    func setupChipImageView() {
        chipImageView.image = .init(named: "flat-chip")
        chipImageView.contentMode = .scaleAspectFit
        addSubview(chipImageView)
        chipImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(20.auto())
            $0.bottom.centerX.equalToSuperview()
        }
    }
    
    func setupMoneyLabel() {
        moneyLabel.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        moneyLabel.textAlignment = .center
        moneyLabel.textColor = .white
        moneyLabel.clipsToBounds = true
        moneyLabel.font = .systemFont(ofSize: 14.auto())
        moneyLabel.layer.borderColor = UIColor.white.cgColor
        moneyLabel.layer.borderWidth = 1.auto()
        moneyLabel.layer.cornerRadius = 4.auto()
        moneyLabel.layer.masksToBounds = true
        moneyLabel.text = "999K"
        
        addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints {
            $0.leading.centerX.equalToSuperview()
            $0.height.equalTo(26.auto())
            $0.bottom.equalTo(chipImageView.snp.top)
        }
    }
}

// MARK: - Bind
private extension ChipInfoView {
    func bind() {
        
    }
}
