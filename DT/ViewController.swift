//
//  ViewController.swift
//  DT
//
//  Created by Champion Chen on 2022/11/23.
//

import UIKit
import RxSwift
import RxCocoa
import AutoInch

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
        titleLabel.font = .boldSystemFont(ofSize: 24.auto())
        titleLabel.text = "龍虎"
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(30.auto())
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupCountDownView() {
        view.addSubview(countDownView)
        countDownView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.size.equalTo(40.auto())
            $0.leading.equalToSuperview().offset(40.auto())
        }
    }
    
    func setupAnimationView() {
        view.addSubview(animationView)
        animationView.snp.makeConstraints {
            $0.width.equalTo(350.auto())
            $0.height.equalTo(250.auto())
            $0.top.equalTo(titleLabel.snp.bottom).offset(50.auto())
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupPlayView() {
        view.addSubview(playView)
        playView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.height.equalTo(150.auto())
            $0.top.equalTo(animationView.snp.bottom)
        }
    }
    
    func setupBottomView() {
        bottomView.backgroundColor = .orange
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.height.equalTo(150.auto())
            $0.bottom.equalToSuperview()
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
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.input.getCurrentTime()
            })
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: DTViewModelPrototype) {
        
        viewModel
            .output
            .lastGameResult
            .bind(to: animationView.showResultWithoutAnimation)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .gameResult
            .bind(to: animationView.showResultWithAnimation)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showWinPlay
            .bind(to: animationView.showWinner)
            .disposed(by: disposeBag)
        
        viewModel
            .output
            .showCurrentTime
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
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
            animationView.beginAnimation.accept(())
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

