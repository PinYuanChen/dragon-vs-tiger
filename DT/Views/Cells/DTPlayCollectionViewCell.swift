
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol DTPlayCollectionCellPrototype {
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}

class DTPlayCollectionViewCell: UICollectionViewCell, DTPlayCollectionCellPrototype {
   
    let input: Input
    var output: Output
    
    struct Input {
        let setPlayOptionInfo = PublishRelay<DTPlayModel>()
        let updateSelectedPlayModels = PublishRelay<[UpdateSelectedPlayModel]>()
        let clearAllBetInfo = PublishRelay<Void>()
    }
    
    struct Output { }
    
    var reuseDisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        self.input = Input()
        self.output = Output()
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _playOptionInfo = nil
        reuseDisposeBag = .init()
    }
    
    private var _playOptionInfo: DTPlayModel?
    private let _updateSelectedPlayModels = BehaviorRelay<[UpdateSelectedPlayModel]>(value: [])
    private let flashView = FlashView(frame: .zero)
    private let titleLabel = UILabel()
    private let oddsLabel = UILabel()
    private let chipInfoView = ChipInfoView(frame: .zero)
    private let hadBetLabel = UILabel()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension DTPlayCollectionViewCell {
    func setupUI() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        clipsToBounds = true
        contentView.backgroundColor = .systemGray.withAlphaComponent(0.3)
        
        setupFlashView()
        setupTitleLabel()
        setupOddsLabel()
        setupChipInfoView()
        setuphadBetLabel()
    }
    
    func setupFlashView() {
        contentView.addSubview(flashView)
        flashView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24.zoom())
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20.zoom())
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30.zoom())
        }
    }
    
    func setupOddsLabel() {
        oddsLabel.textColor = .white
        contentView.addSubview(oddsLabel)
        oddsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.zoom())
            $0.height.equalTo(20.zoom())
        }
    }
    
    func setupChipInfoView() {
        chipInfoView.isHidden = true
        contentView.addSubview(chipInfoView)
        chipInfoView.snp.makeConstraints {
            $0.width.equalTo(46.zoom())
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(4.zoom())
        }
    }
    
    func setuphadBetLabel() {
        hadBetLabel.isHidden = true
        hadBetLabel.layer.borderColor = UIColor.white.cgColor
        hadBetLabel.layer.borderWidth = 1
        hadBetLabel.backgroundColor = .systemGreen.withAlphaComponent(0.5)
        hadBetLabel.textColor = .green
        hadBetLabel.layer.cornerRadius = 4.zoom()
        hadBetLabel.layer.masksToBounds = true
        hadBetLabel.textAlignment = .center
        hadBetLabel.font = .systemFont(ofSize: 14.zoom())
        
        contentView.addSubview(hadBetLabel)
        hadBetLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(10.zoom())
            $0.height.equalTo(20.zoom())
            $0.width.equalTo(50.zoom())
        }
    }
}

// MARK: - Binding

private extension DTPlayCollectionViewCell {
    func bind() {
        input
            .setPlayOptionInfo
            .withUnretained(self)
            .subscribe(onNext: { owner, play in
                owner._playOptionInfo = play
                owner.titleLabel.text = play.playCode.title
                owner.oddsLabel.text = play.odds
            })
            .disposed(by: disposeBag)
        
        input
            .updateSelectedPlayModels
            .withUnretained(self)
            .subscribe(onNext: { owner, selectedPlayModels in
                guard let play = owner._playOptionInfo,
                      let model = selectedPlayModels.filter({
                    $0.playCode == play.playCode.rawValue
                }).first else {
                    owner.chipInfoView.isHidden = true
                    return
                }
                
                owner.chipInfoView.isHidden = model.betMoneyString.isEmpty
                owner.chipInfoView.moneyString = model.betMoneyString
                owner.hadBetLabel.isHidden = model.hadBetMoneyString.isEmpty
                owner.hadBetLabel.text = model.hadBetMoneyString
            })
            .disposed(by: disposeBag)
        
        input
            .clearAllBetInfo
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.chipInfoView.moneyString = ""
                self.hadBetLabel.text = ""
                self.chipInfoView.isHidden = true
                self.hadBetLabel.isHidden = true
            })
            .disposed(by: disposeBag)
    }
}
