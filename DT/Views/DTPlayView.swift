
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayView: UIView {
    
    // Input
    var playOptions: [DTPlayModel] {
        get {
            _playOptions.value
        }
        set {
            _playOptions.accept(newValue)
        }
    }
    
    // Output
    let selectedPlay = PublishRelay<SelectedPlayModel>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let _playOptions = BehaviorRelay<[DTPlayModel]>(value: [])
    private let identifier = "Cell"
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: .init())
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTPlayView {
    
    func setupUI() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = .init()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        
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
        _playOptions
            .filter { $0.count > 0 }
            .withUnretained(collectionView)
            .subscribe(onNext: { collectionView, options in
                collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, index in
                guard let cell = owner
                    .collectionView
                    .dequeueReusableCell(
                        withReuseIdentifier: owner.identifier,
                        for: index
                    ) as? DTPlayCollectionViewCell else {
                    return
                }
                
//                cell.didSelectedPlay.accept()
            })
            .disposed(by: disposeBag)
    }
}

extension DTPlayView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _playOptions.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width - 20
        let padding: CGFloat = CGFloat(2) * 10
        let width = screenWidth - padding
        let cellWidthInt = Int(width) / 3
        return .init(width: cellWidthInt, height: cellWidthInt)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: identifier,
                                 for: indexPath) as? DTPlayCollectionViewCell else {
            return .init()
        }
        cell.playOptionInfo = _playOptions.value[indexPath.item]
        cell
            .didSelectedPlay
            .bind(to: selectedPlay)
            .disposed(by: cell.reuseDisposeBag)
        return cell
    }
    
}
