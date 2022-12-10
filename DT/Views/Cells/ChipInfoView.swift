
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChipInfoView: UIView {
    
    var moneyString: String? {
        get { _moneyString.value }
        set { _moneyString.accept(newValue) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let _moneyString = BehaviorRelay<String?>(value: nil)
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
            $0.height.equalTo(20.zoom())
            $0.bottom.centerX.equalToSuperview()
        }
    }
    
    func setupMoneyLabel() {
        moneyLabel.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        moneyLabel.textAlignment = .center
        moneyLabel.textColor = .white
        moneyLabel.clipsToBounds = true
        moneyLabel.font = .systemFont(ofSize: 14.zoom())
        moneyLabel.layer.borderColor = UIColor.white.cgColor
        moneyLabel.layer.borderWidth = 1.zoom()
        moneyLabel.layer.cornerRadius = 4.zoom()
        moneyLabel.layer.masksToBounds = true
        
        addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints {
            $0.leading.centerX.equalToSuperview()
            $0.height.equalTo(26.zoom())
            $0.bottom.equalTo(chipImageView.snp.top)
        }
    }
}

// MARK: - Bind
private extension ChipInfoView {
    func bind() {
        _moneyString
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(moneyLabel.rx.text)
            .disposed(by: disposeBag)
        
        _moneyString
            .compactMap { $0 }
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(rx.isHidden)
            .disposed(by: disposeBag)
    }
}
