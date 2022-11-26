

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
    
    private let titleLabel = UILabel()
}


// MARK: - Setup UI
private extension DTPlayCollectionViewCell {
    func setupUI() {
        
    }
}

// MARK: - Bind
private extension DTPlayCollectionViewCell {
    func bind() {
        
    }
}
