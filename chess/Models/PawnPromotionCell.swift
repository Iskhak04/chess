//
//  PawnPromotionCell.swift
//  chess
//
//  Created by Iskhak Zhutanov on 15/11/22.
//

import UIKit

class PawnPromotionCell: UICollectionViewCell {
    
    var pieceImageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    override func layoutSubviews() {
        addSubview(pieceImageView)
        pieceImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(45)
            make.width.equalTo(45)
        }
        
    }
}
