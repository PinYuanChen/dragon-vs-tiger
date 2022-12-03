
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChipCollectionViewCell: UICollectionViewCell {

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
            $0.size.equalTo(60.auto())
            $0.center.equalToSuperview()
        }
    }
    
    func setupChipLabel() {
        chipLabel.text = "5K"
        chipImageView.addSubview(chipLabel)
        chipLabel.snp.makeConstraints {
            $0.height.equalTo(20.auto())
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension ChipCollectionViewCell {
    func bind() {
        
    }
}
