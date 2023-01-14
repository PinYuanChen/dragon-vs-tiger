//
//  ViewController.swift
//  DT
//
//  Created by Champion Chen on 2022/11/23.
//

import UIKit
import RxSwift
import RxCocoa
import UIAdapter

class ViewController: UIViewController {
    
    let viewModel = DTViewModel()
    let playViewModel = DTPlayViewModel()
    let bottomViewModel = DTBottomViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        bind(viewModel: viewModel)
        bind(playViewModel: playViewModel)
        bind(bottomViewModel: bottomViewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.getCurrentTime()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        invalidate()
    }
    
    private let titleLabel = UILabel()
    private let countDownView = DTCountDownView()
    private let animationView = DTAnimationView()
    private lazy var playView = DTPlayView(playViewModel)
    private lazy var bottomView = DTBottomView(bottomViewModel)
    private var timer: Timer?
    private var countDownNum = 0
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension ViewController {
    func setupUI() {
        view.backgroundColor = .black
        setupTitle()
        setupCountDownView()
        setupAnimationView()
        setupPlayView()
        setupBottomView()
    }
    
    func setupTitle() {
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 24.zoom())
        titleLabel.text = "龍虎"
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(30.zoom())
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupCountDownView() {
        view.addSubview(countDownView)
        countDownView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.size.equalTo(40.zoom())
            $0.leading.equalToSuperview().offset(40.zoom())
        }
    }
    
    func setupAnimationView() {
        view.addSubview(animationView)
        animationView.snp.makeConstraints {
            $0.width.equalTo(350.zoom())
            $0.height.equalTo(250.zoom())
            $0.top.equalTo(titleLabel.snp.bottom).offset(50.zoom())
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupPlayView() {
        view.addSubview(playView)
        playView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.height.equalTo(150.zoom())
            $0.top.equalTo(animationView.snp.bottom).offset(20.zoom())
        }
    }
    
    func setupBottomView() {
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.leading.centerX.equalToSuperview()
            $0.height.equalTo(150.zoom())
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Bind
private extension ViewController {
    func bind() {
        animationView
            .output
            .withUnretained(self)
            .subscribe(onNext: { owner, type in
                switch type {
                case .finishFlipCard:
                    owner.viewModel.input.getWinPlay()
                case .finishAnimation:
                    owner.playViewModel.input.clearAllBetInfo(withAnimation: true)
                    owner.viewModel.input.getCurrentTime()
                }
            })
            .disposed(by: disposeBag)
        
        animationView
            .input
            .accept(.enableBetting(enable: true))
        
        bottomView
            .cancelButton
            .rx.tap
            .withUnretained(playViewModel)
            .subscribe(onNext: { owner, _ in
                owner.input.cancelReadyBet()
            })
            .disposed(by: disposeBag)
        
        bottomView
            .confirmButton
            .rx.tap
            .withUnretained(playViewModel)
            .subscribe(onNext: { owner, _ in
                owner.input.confirmReadyBet()
            })
            .disposed(by: disposeBag)
        
    }
    
    func bind(viewModel: DTViewModelPrototype) {
        
        viewModel
            .output
            .lastGameResult
            .withUnretained(animationView)
            .subscribe(onNext: { owner, result in
                owner.input.accept(.showResult(result: result, withAnimation: false))
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .gameResult
            .withUnretained(animationView)
            .subscribe(onNext: { owner, result in
                owner.input.accept(.showResult(result: result, withAnimation: true))
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showWinPlay
            .withUnretained(animationView)
            .subscribe(onNext: { owner, winner in
                owner.input.accept(.showWinner(winner: winner))
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showCurrentTime
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                // tmp
                owner.playView.isUserInteractionEnabled = true
                
                if owner.timer == nil {
                    owner.countDownNum = 0
                    owner.timer = Timer.scheduledTimer(
                        timeInterval: 1.0,
                        target: owner,
                        selector: #selector(owner.countDown),
                        userInfo: nil,
                        repeats: true
                    )
                }
            })
            .disposed(by: disposeBag)
                
        viewModel
            .input
            .getLastGameResult()
    }
    
    func bind(playViewModel: DTPlayViewModelPrototype) {
        playViewModel
            .output
            .clearAllBet
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animationView.input.accept(.enableBetting(enable: true))
            })
            .disposed(by: disposeBag)
    }
    
    func bind(bottomViewModel: DTBottomViewModelPrototype) {
        bottomViewModel
            .output
            .chipMoney
            .withUnretained(playViewModel)
            .subscribe(onNext: { owner, chipMoney in
                owner.input.getCurrentChipMoney(chipMoney)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private functions
private extension ViewController {
    @objc func countDown() {
        let diff = 10 - countDownNum
        if diff >= 0 {
            countDownView.currentTime = diff
            countDownView.isHidden = false
            countDownNum += 1
        } else {
            invalidate()
            animationView.input.accept(.beginAnimation)
            animationView.input.accept(.enableBetting(enable: false))
            
            playView.isUserInteractionEnabled = false
            playViewModel.input.cancelReadyBet()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.viewModel.input.getGameResult()
            }
        }
    }
    
    func invalidate() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        countDownView.isHidden = true
    }
}
