//
//  MainViewController.swift
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
    var whitesTurn = true
    var x = 0
    var lastClick: Int = -1
    var placeToPromote = 0
    private var currentBoardV: [[String]] = []
    private var possibleMovesV: [Int] = []
    private var promotionPieces: [[String]] = [["Qw", "Rw", "Bw", "Kw"], ["Qb", "Rb", "Bb", "Kb"]]
    let bag = DisposeBag()
    private let viewModel = MainViewModel()
    
    private lazy var turnView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var gameBoardCollectoinView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.register(GameBoardCell.self, forCellWithReuseIdentifier: "GameBoardCell")
        return view
    }()
    
    private lazy var pawnPromotionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .cyan
        view.isHidden = true
        view.register(PawnPromotionCell.self, forCellWithReuseIdentifier: "PawnPromotionCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        //get current board
        viewModel.currentBoardVM.subscribe(onNext: {
            self.currentBoardV = $0
            self.gameBoardCollectoinView.reloadData()
            self.pawnPromotionCollectionView.reloadData()
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
        
        view.addSubview(turnView)
        turnView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(110)
            make.centerX.equalTo(view.snp.centerX).offset(0)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        
        view.addSubview(gameBoardCollectoinView)
        gameBoardCollectoinView.snp.makeConstraints { make in
            make.height.equalTo(430)
            make.right.equalTo(view.snp.right).offset(0)
            make.left.equalTo(view.snp.left).offset(0)
            make.centerY.equalTo(view.snp.centerY).offset(0)
        }
        
        view.addSubview(pawnPromotionCollectionView)
        pawnPromotionCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(110)
            make.centerX.equalTo(view.snp.centerX).offset(0)
            //make.bottom.equalTo(view.snp.bottom).offset(0)
            make.height.equalTo(60)
            make.width.equalTo(view.frame.width / 2)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pawnPromotionCollectionView {
            return 4
        }
        return 64
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pawnPromotionCollectionView {
            let cell = pawnPromotionCollectionView.dequeueReusableCell(withReuseIdentifier: "PawnPromotionCell", for: indexPath) as! PawnPromotionCell
            
            if whitesTurn {
                cell.pieceImageView.image = UIImage(named: promotionPieces[0][indexPath.row])
            } else {
                cell.pieceImageView.image = UIImage(named: promotionPieces[1][indexPath.row])
            }
            
            return cell
        }
        
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
        if collectionView == pawnPromotionCollectionView {
            
            if whitesTurn {
                switch indexPath.row {
                case 0:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Qw"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 1:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Rw"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 2:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Bw"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 3:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Kw"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                default:
                    ()
                }
            } else {
                switch indexPath.row {
                case 0:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Qb"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 1:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Rb"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 2:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Bb"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                case 3:
                    viewModel.pieceToPromoteVM.onNext((lastClick, placeToPromote, "Kb"))
                    pawnPromotionCollectionView.isHidden = true
                    possibleMovesV.removeAll()
                    whitesTurn = !whitesTurn
                default:
                    ()
                }
            }
            
            if whitesTurn {
                turnView.backgroundColor = .white
            } else {
                turnView.backgroundColor = .black
            }
            
        } else {
            let row = indexPath.row / 8
            let column = indexPath.row - row * 8
            
            if !possibleMovesV.isEmpty {
                if possibleMovesV.contains(indexPath.row) {
                    if currentBoardV[lastClick / 8][lastClick - (lastClick / 8) * 8] == "Pw" && row == 7 {
                        placeToPromote = indexPath.row
                        pawnPromotionCollectionView.isHidden = false
                        
                    } else if currentBoardV[lastClick / 8][lastClick - (lastClick / 8) * 8] == "Pb" && row == 0 {
                        placeToPromote = indexPath.row
                        pawnPromotionCollectionView.isHidden = false
                    } else {
                        //make the move
                        viewModel.moveToMakeVM.onNext([lastClick, indexPath.row])
                        whitesTurn = !whitesTurn
                        possibleMovesV.removeAll()
                        if whitesTurn {
                            turnView.backgroundColor = .white
                        } else {
                            turnView.backgroundColor = .black
                        }
                    }
                } else {
                    if whitesTurn {
                        if currentBoardV[row][column].contains("w") {
                            possibleMovesV.removeAll()
                            viewModel.cellToCheckVM.onNext(indexPath.row)
                            lastClick = indexPath.row
                        } else {
                            possibleMovesV.removeAll()
                            gameBoardCollectoinView.reloadData()
                        }
                    } else {
                        if currentBoardV[row][column].contains("b") {
                            possibleMovesV.removeAll()
                            viewModel.cellToCheckVM.onNext(indexPath.row)
                            lastClick = indexPath.row
                        } else {
                            possibleMovesV.removeAll()
                            gameBoardCollectoinView.reloadData()
                        }
                    }
                }
            } else {
                //show possible moves
                if whitesTurn {
                    if currentBoardV[row][column].contains("w") {
                        viewModel.cellToCheckVM.onNext(indexPath.row)
                        lastClick = indexPath.row
                    }
                } else {
                    if currentBoardV[row][column].contains("b") {
                        viewModel.cellToCheckVM.onNext(indexPath.row)
                        lastClick = indexPath.row
                    }
                }
            }
        }
    }
}
