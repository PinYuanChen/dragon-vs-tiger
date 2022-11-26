
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTAnimationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dragonImageView = UIImageView()
    private let tigerImageView = UIImageView()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTAnimationView {

    func setupUI() {
        setupDragonImage()
        setupTigerImage()
        setupPokerView()
    }

    func setupDragonImage() {
        dragonImageView.image = .init(named: "dragon")
        dragonImageView.contentMode = .scaleAspectFit
        addSubview(dragonImageView)
        
        dragonImageView.snp.makeConstraints {
            $0.width.equalTo(150.auto())
            $0.height.equalTo(160.auto())
            $0.leading.centerY.equalToSuperview()
        }
    }
    
    func setupTigerImage() {
        tigerImageView.image = .init(named: "tiger")
        tigerImageView.contentMode = .scaleAspectFit
        addSubview(tigerImageView)
        
        tigerImageView.snp.makeConstraints {
            $0.width.equalTo(106.auto())
            $0.height.equalTo(160.auto())
            $0.trailing.centerY.equalToSuperview()
        }
    }
    
    func setupPokerView() {
        
    }
}

// MARK: - Bind
private extension DTAnimationView {
    func bind() {
        
    }
}
