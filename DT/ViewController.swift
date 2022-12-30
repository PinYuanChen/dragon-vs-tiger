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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        bind(viewModel: viewModel)
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
    private let countDownView = DTCountDownView(frame: .zero)
    private let animationView = DTAnimationView(frame: .zero)
    private let playView = DTPlayView(frame: .zero)
    private let bottomView = DTBottomView(frame: .zero)
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
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, type in
                switch type {
                case .finishFlipCard:
                    owner.input.getWinPlay()
                case .finishAnimation:
                    owner.input.clearAllBetInfo(withAnimation: true)
                    owner.input.getCurrentTime()
                }
            })
            .disposed(by: disposeBag)
        
        playView
            .output
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, type in
                switch type {
                case .selectedPlay(let play):
                    owner.input.getSelectedPlay(play)
                }
            })
            .disposed(by: disposeBag)
        
        bottomView
            .output
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, type in
                switch type {
                case .selectedIndex(index: let index):
                    owner.input.getSelectedChipIndex(index)
                case .didTappedCancelButton:
                    owner.input.cancelReadyBet()
                case .didTappedConfirmButton:
                    owner.input.confirmReadyBet()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func bind(viewModel: DTViewModelPrototype) {
        
        viewModel
            .output
            .playOptions
            .withUnretained(self)
            .subscribe(onNext: { owner, options in
                owner.playView.input.accept(.setPlayOptions(options: options))
            })
            .disposed(by: disposeBag)
        
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
                owner.playView.input.accept(.setInteractionEnabled(enabled: true))
                
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
            .output
            .updateSelectedPlayModels
            .withUnretained(playView)
            .subscribe(onNext: { owner, models in
                owner.input.accept(.updateSelectedPlayModels(model: models))
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .clearAllBet
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.playView.input.accept(.clearAllBet)
                owner.animationView.input.accept(.enableBetting(enable: true))
            })
            .disposed(by: disposeBag)
        
        viewModel
            .input
            .getPlayOptions()
        
        viewModel
            .input
            .getLastGameResult()
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
            playView.input.accept(.setInteractionEnabled(enabled: false))
            viewModel.input.cancelReadyBet()
            
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
