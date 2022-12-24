
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol DTPlayPrototype {
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}

/*
protocol DTPlayInputPrototype {
    func setPlayOptions(_: DTPlayCateModel)
    func updateSelectedPlayModels(_: [UpdateSelectedPlayModel])
    func setInteractionEnabled(_: Bool)
    func clearAllBet()
}

protocol DTPlayOutputPrototype {
    var selectedPlay: Observable<SelectedPlayModel> { get }
}

protocol DTPlayPrototype {
    var input: DTPlayInputPrototype { get }
    var output: DTPlayOutputPrototype { get }
}
*/

class DTPlayView: UIView, DTPlayPrototype {
    
    let input: Input
    let output: Output
    
    struct Input {
        let setPlayOptions = PublishRelay<DTPlayCateModel>()
        let updateSelectedPlayModels = PublishRelay<[UpdateSelectedPlayModel]>()
        let setInteractionEnabled = PublishRelay<Bool>()
        let clearAllBet = PublishRelay<Void>()
    }
    
    struct Output {
        let selectedPlay = PublishRelay<SelectedPlayModel>()
    }
    
    override init(frame: CGRect) {
        self.input = Input()
        self.output = Output()
        super.init(frame: frame)
        setupUI()
        bind()
        bindInputOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        _isInteractionEnabled
            .withUnretained(self)
            .subscribe(onNext: { owner, enabled in
                owner.isUserInteractionEnabled = enabled
                owner.alpha = enabled ? 1 : 0.5
            })
            .disposed(by: disposeBag)
    }
    
    func bindInputOutput() {
        input
            .setPlayOptions
            .bind(to: _playOptions)
            .disposed(by: disposeBag)
        
        input
            .updateSelectedPlayModels
            .bind(to: _updateSelectedPlayModels)
            .disposed(by: disposeBag)
        
        input
            .setInteractionEnabled
            .bind(to: _isInteractionEnabled)
            .disposed(by: disposeBag)
        
        input
            .clearAllBet
            .bind(to: _clearAllBet)
            .disposed(by: disposeBag)
        
        _selectedPlay
            .bind(to: output.selectedPlay)
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: identifier,
                                 for: indexPath) as? DTPlayCollectionViewCell,
              let playType = _playOptions.value?.playType else {
            return .init()
        }
        
        cell.input.setPlayOptionInfo.accept(playType[indexPath.item])
        
        _updateSelectedPlayModels
            .withUnretained(cell)
            .subscribe(onNext: { owner, models in
                cell.input.updateSelectedPlayModels.accept(models)
            })
            .disposed(by: cell.reuseDisposeBag)
        
        _clearAllBet
            .withUnretained(cell)
            .subscribe(onNext: { owner, _ in
                owner.input.clearAllBetInfo.accept(())
            })
            .disposed(by: cell.reuseDisposeBag)
        
        _isInteractionEnabled
            .bind(to: cell.rx.isUserInteractionEnabled)
            .disposed(by: cell.reuseDisposeBag)
        return cell
    }
}

// MARK: - Input
/*
extension DTPlayView: DTPlayInputPrototype {
    func setPlayOptions(_ options: DTPlayCateModel) {
        _playOptions.accept(options)
    }
    
    func updateSelectedPlayModels(_ selectedPlays: [UpdateSelectedPlayModel]) {
        _updateSelectedPlayModels.accept(selectedPlays)
    }
    
    func setInteractionEnabled(_ enabled: Bool) {
        _isInteractionEnabled.accept(enabled)
    }
    
    func clearAllBet() {
        _clearAllBet.accept(())
    }
}

// MARK: - Output
extension DTPlayView: DTPlayOutputPrototype {
    var selectedPlay: RxSwift.Observable<SelectedPlayModel> {
        _selectedPlay.asObservable()
    }
}
*/
