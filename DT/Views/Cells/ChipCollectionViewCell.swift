
import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum ChipType: CaseIterable {
    case oneK
    case fiveK
    case tenK
    case twentyK
    case fiftyK
    
    var title: String {
        switch self {
        case .oneK:
            return "1K"
        case .fiveK:
            return "5K"
        case .tenK:
            return "10K"
        case .twentyK:
            return "20K"
        case .fiftyK:
            return "50K"
        }
    }
    
    var number: Int {
        switch self {
        case .oneK:
            return 1000
        case .fiveK:
            return 5000
        case .tenK:
            return 10000
        case .twentyK:
            return 20000
        case .fiftyK:
            return 50000
        }
    }
}

class ChipCollectionViewCell: UICollectionViewCell {
    
    var type: ChipType {
        get { _type.value }
        set { _type.accept(newValue) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let chipImageView = UIImageView()
    private let chipLabel = UILabel()
    private let _type = BehaviorRelay<ChipType>(value: .oneK)
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension ChipCollectionViewCell {

    func setupUI() {
        setupChipImage()
        setupChipLabel()
    }

    func setupChipImage() {
        chipImageView.image = .init(named: "chip")
        addSubview(chipImageView)
        chipImageView.snp.makeConstraints {
            $0.size.equalTo(60.zoom())
            $0.center.equalToSuperview()
        }
    }
    
    func setupChipLabel() {
        chipLabel.font = .systemFont(ofSize: 8)
        chipLabel.textColor = .systemRed
        
        chipImageView.addSubview(chipLabel)
        chipLabel.snp.makeConstraints {
            $0.height.equalTo(20.zoom())
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension ChipCollectionViewCell {
    func bind() {
        _type
            .map { $0.title }
            .asDriver(onErrorJustReturn: "")
            .drive(chipLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
