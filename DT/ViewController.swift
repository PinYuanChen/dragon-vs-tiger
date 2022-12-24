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
            .finishFlipCard
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.input.getWinPlay()
            })
            .disposed(by: disposeBag)
        
        animationView
            .finishAnimation
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, _ in
                owner.input.clearAllBetInfo(withAnimation: true)
                owner.input.getCurrentTime()
            })
            .disposed(by: disposeBag)
        
        playView
            .output
            .selectedPlay
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, selectedPlay in
                owner.input.getSelectedPlay(selectedPlay)
            })
            .disposed(by: disposeBag)
        
        bottomView
            .output
            .selectedIndex
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, index in
                owner.input.getSelectedChipIndex(index)
            })
            .disposed(by: disposeBag)
        
        bottomView
            .output
            .didTappedCancelButton
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, _ in
                owner.input.cancelReadyBet()
            })
            .disposed(by: disposeBag)
        
        bottomView
            .output
            .didTappedConfirmButton
            .withUnretained(viewModel)
            .subscribe(onNext: { owner, _ in
                owner.input.confirmReadyBet()
            })
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: DTViewModelPrototype) {
        
        viewModel
            .output
            .playOptions
            .withUnretained(self)
            .subscribe(onNext: { owner, options in
                owner.playView.input.setPlayOptions.accept(options)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .lastGameResult
            .withUnretained(animationView)
            .subscribe(onNext: { owner, result in
                owner.input.showResult(result, withAnimation: false)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .gameResult
            .withUnretained(animationView)
            .subscribe(onNext: { owner, result in
                owner.input.showResult(result, withAnimation: true)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showWinPlay
            .withUnretained(animationView)
            .subscribe(onNext: { owner, winner in
                owner.input.showWinner(winner)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showCurrentTime
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                // tmp
                owner.playView.input.setInteractionEnabled.accept(true)
                
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
                owner.input.updateSelectedPlayModels.accept(models)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .clearAllBet
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.playView.input.clearAllBet.accept(())
                owner.animationView.input.enableBetting(true)
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
            animationView.input.beginAnimation()
            animationView.input.enableBetting(false)
            playView.input.setInteractionEnabled.accept(false)
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
