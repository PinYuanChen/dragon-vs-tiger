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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private let titleLabel = UILabel()
    private let countDownView = DTCountDownView(frame: .zero)
    private let animationView = DTAnimationView(frame: .zero)
    private let playView = DTPlayView(frame: .zero)
    private let bottomView = DTBottomView(frame: .zero)
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
        titleLabel.font = .boldSystemFont(ofSize: 20.auto())
        titleLabel.text = "Dragon vs. Tiger"
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(20.auto())
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
        playView.backgroundColor = .red
        
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
        
    }
}

