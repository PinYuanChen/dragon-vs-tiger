

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DTPlayCollectionViewCell: UICollectionViewCell {
    
    // Input
    var playOptionInfo: DTPlayModel? {
        get { _playOptionInfo.value }
        set { _playOptionInfo.accept(newValue) }
    }
    
    var updateSelectedPlayModels: Binder<[UpdateSelectedPlayModel]> {
        .init(self) { target, models in
            target._updateSelectedPlayModels.accept(models)
        }
    }
    
    // TODO: update select info
    
    var reuseDisposeBag = DisposeBag()
    
    // Output
    let didSelectedPlay = PublishRelay<SelectedPlayModel>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = .init()
    }
    
    private let _playOptionInfo = BehaviorRelay<DTPlayModel?>(value: nil)
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

// MARK: - Bind
private extension DTPlayCollectionViewCell {
    func bind() {
        _playOptionInfo
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { owner, play in
                owner.titleLabel.text = play.playCode.title
                owner.oddsLabel.text = play.odds
            })
            .disposed(by: disposeBag)
        
        _updateSelectedPlayModels
            .filter { !$0.isEmpty }
            .withLatestFrom(_playOptionInfo.compactMap { $0 }) { ($0, $1) }
            .subscribe(onNext: { [weak self] (selectedPlayModels, playOptionInfo) in
                guard let self = self else { return }
                guard let model = selectedPlayModels.filter({ $0.playCode == playOptionInfo.playCode.rawValue }).first else {
                    self.chipInfoView.moneyString = ""
                    return
                }
                
                self.chipInfoView.isHidden = false
                self.chipInfoView.moneyString = model.betMoneyString
            })
            .disposed(by: disposeBag)
    }
}
