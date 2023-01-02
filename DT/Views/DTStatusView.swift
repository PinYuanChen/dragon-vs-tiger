//
//  DTStatusView.swift
//  DT
//
//  Created by Champion Chen on 2023/1/2.
//

import UIKit
import UIAdapter

class DTStatusView: UIImageView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DTStatusView {
    func setupUI() {
        titleLabel.font = .systemFont(ofSize: 20.zoom())
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
