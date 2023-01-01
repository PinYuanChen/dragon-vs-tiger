
import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DTBottomOutput {
    case selectedIndex(index: Int)
    case didTappedCancelButton
    case didTappedConfirmButton
}

class DTBottomView: UIView {
    
    var output = PublishRelay<DTBottomOutput>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
        bindInputOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let leftButton = UIButton()
    private let rightButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: .init())
    private let cancelButton = UIButton()
    private let confirmButton = UIButton()
    private let _selectedIndex = BehaviorRelay<Int>(value: 0)
    private let _didTappedCancelButton = PublishRelay<Void>()
    private let _didTappedConfirmButton = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTBottomView {
    
    func setupUI() {
        setupLeftButton()
        setupCollectionView()
        setupRightButton()
        setupCancelButton()
        setupConfirmButton()
    }
    
    func setupLeftButton() {
        leftButton.setTitle("◀︎", for: .normal)
        leftButton.titleLabel?.textAlignment = .left
        addSubview(leftButton)
        leftButton.snp.makeConstraints {
            $0.size.equalTo(20.zoom())
            $0.top.equalToSuperview().inset(50.zoom())
            $0.leading.equalToSuperview().inset(20.zoom())
        }
    }
    
    func setupCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = .init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumInteritemSpacing = .zero
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ChipCollectionViewCell.self,
                                forCellWithReuseIdentifier: "ChipCell")
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.height.equalTo(100.zoom())
            $0.width.equalTo(260.zoom())
            $0.centerY.equalTo(leftButton)
            $0.leading.equalTo(leftButton.snp.trailing).offset(20.zoom())
        }
    }
    
    func setupRightButton() {
        rightButton.setTitle("▶︎", for: .normal)
        addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.size.equalTo(leftButton)
            $0.trailing.equalToSuperview().inset(20.zoom())
            $0.centerY.equalTo(leftButton)
        }
    }
    
    func setupCancelButton() {
        cancelButton.titleLabel?.textColor = .white
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.font = .systemFont(ofSize: 12.zoom())
        cancelButton.backgroundColor = .systemGray
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.cornerRadius = 4.zoom()
        cancelButton.setTitle("CANCEL", for: .normal)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(70.zoom())
            $0.height.equalTo(35.zoom())
            $0.leading.equalToSuperview().inset(20.zoom())
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupConfirmButton() {
        confirmButton.titleLabel?.textColor = .white
        confirmButton.titleLabel?.textAlignment = .center
        confirmButton.titleLabel?.font = .systemFont(ofSize: 12.zoom())
        confirmButton.backgroundColor = .systemBlue
        confirmButton.layer.borderWidth = 1
        confirmButton.layer.borderColor = UIColor.blue.cgColor
        confirmButton.layer.cornerRadius = 4.zoom()
        confirmButton.setTitle("CONFIRM", for: .normal)
        addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.size.equalTo(cancelButton)
            $0.trailing.equalToSuperview().inset(20.zoom())
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension DTBottomView {
    func bind() {
        _selectedIndex
            .withUnretained(collectionView)
            .subscribe(onNext: { owner, _ in
                owner.reloadData()
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .map { $0.item }
            .bind(to: _selectedIndex)
            .disposed(by: disposeBag)
        
        cancelButton
            .rx
            .tap
            .bind(to: _didTappedCancelButton)
            .disposed(by: disposeBag)
        
        confirmButton
            .rx
            .tap
            .bind(to: _didTappedConfirmButton)
            .disposed(by: disposeBag)
        
        leftButton
            .rx
            .tap
            .withLatestFrom(_selectedIndex) { ($0, $1) }
            .filter { $0.1 > 0 }
            .map { [unowned self] _ in self._selectedIndex.value - 1 }
            .bind(to: _selectedIndex)
            .disposed(by: disposeBag)
        
        rightButton
            .rx
            .tap
            .withLatestFrom(_selectedIndex) { ($0, $1) }
            .filter { $0.1 < ChipType.allCases.count - 1 }
            .map { [unowned self] _ in self._selectedIndex.value + 1 }
            .bind(to: _selectedIndex)
            .disposed(by: disposeBag)
    }
    
    func bindInputOutput() {
        _selectedIndex
            .map { DTBottomOutput.selectedIndex(index: $0) }
            .bind(to: output)
            .disposed(by: disposeBag)
        
        _didTappedCancelButton
            .map { DTBottomOutput.didTappedCancelButton }
            .bind(to: output)
            .disposed(by: disposeBag)
        
        _didTappedConfirmButton
            .map { DTBottomOutput.didTappedConfirmButton }
            .bind(to: output)
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionView Delegate
extension DTBottomView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ChipType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 80.zoom(), height: 80.zoom())
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChipCell", for: indexPath
        ) as? ChipCollectionViewCell else {
            return .init()
        }
        let chipType = ChipType.allCases
        cell.type = chipType[indexPath.item]
        cell.didSelected.accept(indexPath.item == _selectedIndex.value)
        return cell
    }
}
