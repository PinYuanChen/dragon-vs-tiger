
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let identifier = "Cell"
    private let collectionView = UICollectionView()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTPlayView {

    func setupUI() {
        setupCollectionView()
    }

    func setupCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = .init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = .zero
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DTPlayCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension DTPlayView {
    func bind() {
        
    }
}

extension DTPlayView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: identifier,
                                 for: indexPath) as? DTPlayCollectionViewCell else {
            return .init()
        }
        
        return cell
    }
    
}
