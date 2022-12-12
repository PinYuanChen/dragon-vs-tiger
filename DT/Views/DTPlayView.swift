
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayView: UIView {
    
    // Input
    var playOptions: DTPlayCateModel? {
        get { _playOptions.value }
        set { _playOptions.accept(newValue) }
    }
    
    var updateSelectedPlayModels: [UpdateSelectedPlayModel] {
        get { _updateSelectedPlayModels.value }
        set { _updateSelectedPlayModels.accept(newValue) }
    }
    
    var isInteractionEnabled: Bool {
        get { _isInteractionEnabled.value }
        set { _isInteractionEnabled.accept(newValue) }
    }
    
    let clearAllBet = PublishRelay<Void>()
    
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
    
    private let _playOptions = BehaviorRelay<DTPlayCateModel?>(value: nil)
    private let _updateSelectedPlayModels = BehaviorRelay<[UpdateSelectedPlayModel]>(value: [])
    private let identifier = "Cell"
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: .init())
    private let _isInteractionEnabled = BehaviorRelay<Bool>(value: true)
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
        flowLayout.minimumInteritemSpacing = 10
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
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
            .compactMap { $0 }
            .filter { !$0.playType.isEmpty }
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
                guard let cell = owner.collectionView.dequeueReusableCell(
                    withReuseIdentifier: owner.identifier,
                    for: index
                ) as? DTPlayCollectionViewCell,
                      let cateCode = owner.playOptions?.cateCode,
                      let playCode = owner.playOptions?.playType[index.item].playCode else {
                    return
                }
                
                owner.selectedPlay.accept(.init(cateCode: cateCode,
                                                playCode: playCode.rawValue,
                                                endPoint: .zero))
            })
            .disposed(by: disposeBag)
        
        _isInteractionEnabled
            .withUnretained(self)
            .subscribe(onNext: { owner, enabled in
                owner.isUserInteractionEnabled = enabled
                owner.alpha = enabled ? 1 : 0.5
            })
            .disposed(by: disposeBag)
    }
}

extension DTPlayView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _playOptions.value?.playType.count ?? 0
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
                                 for: indexPath) as? DTPlayCollectionViewCell,
              let playType = _playOptions.value?.playType else {
            return .init()
        }
        cell.playOptionInfo = playType[indexPath.item]
        cell
            .didSelectedPlay
            .bind(to: selectedPlay)
            .disposed(by: cell.reuseDisposeBag)
        _updateSelectedPlayModels
            .bind(to: cell.updateSelectedPlayModels)
            .disposed(by: cell.reuseDisposeBag)
        clearAllBet
            .bind(to: cell.clearAllBetInfo)
            .disposed(by: cell.reuseDisposeBag)
        return cell
    }
    
}
