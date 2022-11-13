//
//  ViewController.swift
//  chess
//
//  Created by Iskhak Zhutanov on 12/11/22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    var isWhite = true
    
    var x = 0
    
    private var currentBoardV: [[String]] = []
    private var possibleMovesV: [Int] = []
    
    let bag = DisposeBag()
    
    private let viewModel = MainViewModel()
    
    private lazy var gameBoardCollectoinView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.register(GameBoardCell.self, forCellWithReuseIdentifier: "GameBoardCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        //get current board
        viewModel.currentBoardVM.subscribe(onNext: {
            self.currentBoardV = $0
        }).disposed(by: bag)
        
        //get all possible moves for a tapped piece
        viewModel.possibleMovesVM.subscribe(onNext: {
            self.possibleMovesV = $0
            self.gameBoardCollectoinView.reloadData()
        }).disposed(by: bag)
        
        //ask the viewModel for current board
        viewModel.getCurrentBoardVM.onNext(true)
        
        layout()
        
    }

    private func layout() {
        view.backgroundColor = .gray
        
        view.addSubview(gameBoardCollectoinView)
        gameBoardCollectoinView.snp.makeConstraints { make in
            make.height.equalTo(430)
            make.right.equalTo(view.snp.right).offset(0)
            make.left.equalTo(view.snp.left).offset(0)
            make.centerY.equalTo(view.snp.centerY).offset(0)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = gameBoardCollectoinView.dequeueReusableCell(withReuseIdentifier: "GameBoardCell", for: indexPath) as! GameBoardCell
        
        //coloring the game board
        if indexPath.row % 8 == 0 && indexPath.row != 0 {
            isWhite = !isWhite
            x += 1
        }
        
        if isWhite {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .brown
            }
            
            if possibleMovesV.contains(indexPath.row) {
                cell.backgroundColor = .green
            }
        } else {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .brown
            } else {
                cell.backgroundColor = .white
            }
            
            if possibleMovesV.contains(indexPath.row) {
                cell.backgroundColor = .green
            }
        }
        
        
        //placing pieces on game board
        cell.pieceImageView.image = UIImage(named: currentBoardV[x][indexPath.row - x * 8])
        
        if indexPath.row == 63 {
            x = 0
            isWhite = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 53.75, height: 53.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = gameBoardCollectoinView.cellForItem(at: indexPath) as! GameBoardCell
        
        viewModel.cellToCheckVM.onNext(indexPath.row)
        
    }
}
