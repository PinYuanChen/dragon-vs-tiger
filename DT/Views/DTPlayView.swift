
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayView: UIView {
    
    required init(_ viewModel: DTPlayViewModelPrototype) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        bind()
        bind(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: DTPlayViewModelPrototype
    private let _playOptions = BehaviorRelay<DTPlayCateModel?>(value: nil)
    private let _updateSelectedPlayModels = BehaviorRelay<[UpdateSelectedPlayModel]>(value: [])
    private let _selectedPlay = PublishRelay<SelectedPlayModel>()
    private let _clearAllBet = PublishRelay<Void>()
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
            .withUnretained(collectionView)
            .subscribe(onNext: { collectionView, _ in
                collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        _selectedPlay
            .withUnretained(self)
            .subscribe(onNext: { owner, selectPlay in
                owner.viewModel.input.getSelectedPlay(selectPlay: selectPlay)
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, index in
                guard owner.isUserInteractionEnabled,
                      let cateCode = owner._playOptions.value?.cateCode,
                      let playCode = owner._playOptions.value?.playType[index.item].playCode else {
                    return
                }
                
                owner._selectedPlay.accept(.init(cateCode: cateCode,
                                                playCode: playCode.rawValue,
                                                endPoint: .zero))
                
            })
            .disposed(by: disposeBag)
        
        rx
            .observe(\.isUserInteractionEnabled)
            .map { $0 ? 1 : 0.5 }
            .asDriver(onErrorJustReturn: 1)
            .drive(rx.alpha)
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: DTPlayViewModelPrototype) {
        viewModel
            .output
            .playOptions
            .bind(to: _playOptions)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .clearAllBet
            .bind(to: _clearAllBet)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .updateSelectedPlayModels
            .bind(to: _updateSelectedPlayModels)
            .disposed(by: disposeBag)
        
        viewModel.input.getPlayOptions()
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: identifier,
                                 for: indexPath) as? DTPlayCollectionViewCell,
              let playType = _playOptions.value?.playType else {
            return .init()
        }
        
        cell.input.accept(.setPlayOptionInfo(playModel: playType[indexPath.item]))
        
        _updateSelectedPlayModels
            .withUnretained(cell)
            .subscribe(onNext: { owner, models in
                cell.input.accept(.updateSelectedPlayModels(models: models))
            })
            .disposed(by: cell.reuseDisposeBag)
        
        _clearAllBet
            .withUnretained(cell)
            .subscribe(onNext: { owner, _ in
                owner.input.accept(.clearAllBetInfo)
            })
            .disposed(by: cell.reuseDisposeBag)
        
        return cell
    }
}
