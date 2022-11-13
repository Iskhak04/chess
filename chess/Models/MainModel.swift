//
//  MainModel.swift
//  chess
//
//  Created by Iskhak Zhutanov on 12/11/22.
//

import UIKit
import RxSwift
import RxCocoa

class MainModel: NSObject {
    
    let bag = DisposeBag()
    
    private var currentBoard: [[String]] = [["Rw", "Kw", "Bw", "Kingw", "Qw", "Bw", "Kw", "Rw"],
                                            ["Pw", "Pw", "Pw", "Pw",    "Pw", "Pw", "Pw", "Pw"],
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["0",  "0",  "0",  "0",     "Rw",  "0",  "0",  "0"],
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["Pb", "Pb", "Pb", "Pb",    "Pb", "Pb", "Pb", "Pb"],
                                            ["Rb", "Kb", "Bb", "Kingb", "Qb", "Bb", "Kb", "Rb"]]
    
    var currentBoardM = PublishSubject<[[String]]>()
    var getCurrentBoardM = PublishSubject<Bool>()
    var cellToCheckM = PublishSubject<Int>()
    var possibleMovesM = PublishSubject<[Int]>()
    
    override init() {
        super.init()
        
        getCurrentBoardM.subscribe(onNext: {
            if $0 == true {
                self.currentBoardM.onNext(self.currentBoard)
            }
        }).disposed(by: bag)
        
        cellToCheckM.subscribe(onNext: {
            
            let possibleMoves = self.findPossibleMoves(indexPath: $0)
            
            self.possibleMovesM.onNext(possibleMoves)
            
        }).disposed(by: bag)
        
    }
    
    private func findPossibleMoves(indexPath: Int) -> [Int] {
        var possibleMoves: [Int] = []
        let row = indexPath / 8
        let column = indexPath - row * 8
        
        switch currentBoard[row][column] {
        case "Rw", "Rb":
            //if X2=X1 or Y2=Y1
            for i in 0...63 {
                if (i / 8 == row || i - (i / 8) * 8 == column) && i != indexPath {
                    possibleMoves.append(i)
                }
            }            
        case "Kw", "Kb":
            //if (|X2-X1|=1 and |Y2-Y1|=2) or (|X2-X1|=2 and |Y2-Y1|=1)
            for i in 0...63 {
                if (abs(i / 8 - row) == 1 && abs((i - (i / 8) * 8) - column) == 2) || (abs(i / 8 - row) == 2 && abs((i - (i / 8) * 8) - column) == 1) {
                    possibleMoves.append(i)
                }
            }
            
            if currentBoard[row][column] == "Kw" {
                possibleMoves.removeAll { j in
                    if currentBoard[j / 8][j - (j / 8) * 8].contains("w") {
                        return true
                    }
                    return false
                }
            } else {
                possibleMoves.removeAll { j in
                    if currentBoard[j / 8][j - (j / 8) * 8].contains("b") {
                        return true
                    }
                    return false
                }
            }
        case "Bw", "Bb":
            //if |X2-X1|=|Y2-Y1|
            for i in 0...63 {
                if abs(i / 8 - row) == abs((i - (i / 8) * 8) - column) && i != indexPath {
                    possibleMoves.append(i)
                }
            }
        case "Kingw", "Kingb":
            //if |X2-X1|<=1 and |Y2-Y1|<=1
            for i in 0...63 {
                if abs(i / 8 - row) <= 1 && abs((i - (i / 8) * 8) - column) <= 1 && i != indexPath {
                    possibleMoves.append(i)
                }
            }
            
            if currentBoard[row][column] == "Kingw" {
                possibleMoves.removeAll { j in
                    if currentBoard[j / 8][j - (j / 8) * 8].contains("w") {
                        return true
                    }
                    return false
                }
            } else {
                possibleMoves.removeAll { j in
                    if currentBoard[j / 8][j - (j / 8) * 8].contains("b") {
                        return true
                    }
                    return false
                }
            }
        case "Qw", "Qb":
            //if |X2-X1|=|Y2-Y1| or X2=X1 or Y2=Y1
            for i in 0...63 {
                if (i / 8 == row || i - (i / 8) * 8 == column || abs(i / 8 - row) == abs((i - (i / 8) * 8) - column)) && i != indexPath {
                    possibleMoves.append(i)
                }
            }
        case "Pw":
            //if X2=X1 and Y2-Y1=1
            if row == 1 {
                for i in 0...63 {
                    if (i / 8 - row == 2 || i / 8 - row == 1) && (i - (i / 8) * 8) == column {
                        possibleMoves.append(i)
                    }
                }
            } else {
                for i in 0...63 {
                    if i / 8 - row == 1 && (i - (i / 8) * 8) == column {
                        possibleMoves.append(i)
                    }
                }
            }
        case "Pb":
            //if X2=X1 and Y1-Y2=1
            if row == 6 {
                for i in 0...63 {
                    if (row - i / 8 == 2 || row - i / 8 == 1) && (i - (i / 8) * 8) == column {
                        possibleMoves.append(i)
                    }
                }
            } else {
                for i in 0...63 {
                    if row - i / 8 == 1 && (i - (i / 8) * 8) == column {
                        possibleMoves.append(i)
                    }
                }
            }
        default:
            ()
        }
        
        return possibleMoves
    }
}
