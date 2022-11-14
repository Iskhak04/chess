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
                                            ["0",  "0",  "0",  "Qb",     "0",  "0",  "0",  "Qb"],
                                            ["Qw",  "0",  "0",  "Qw",     "0",  "0",  "0",  "0"],
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
        case "Rw":
            //left
            if column != 0 {
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("b") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("w") {
                        break
                    }
                }
            }
            //right
            if column != 7 {
                for i in (column + 1)...7 {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("b") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("w") {
                        break
                    }
                }
            }
            //top
            if row != 0 {
                for i in stride(from: row-1, through: 0, by: -1) {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("b") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("w") {
                        break
                    }
                }
            }
            //bottom
            if row != 7 {
                for i in row+1...7 {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("b") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("w") {
                        break
                    }
                }
            }
        case "Rb":
            //left
            if column != 0 {
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("w") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("b") {
                        break
                    }
                }
            }
            //right
            if column != 7 {
                for i in (column + 1)...7 {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("w") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("b") {
                        break
                    }
                }
            }
            //top
            if row != 0 {
                for i in stride(from: row-1, through: 0, by: -1) {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("w") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("b") {
                        break
                    }
                }
            }
            //bottom
            if row != 7 {
                for i in row+1...7 {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("w") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("b") {
                        break
                    }
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
        case "Bw":
            if row == 0 && column == 0 {
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 0 && column == 7 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 && column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 && column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 0 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            }
        case "Bb":
            if row == 0 && column == 0 {
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 0 && column == 7 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 && column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 && column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 0 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
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
        case "Qw":
            //rook move check
            
            //left
            if column != 0 {
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("b") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("w") {
                        break
                    }
                }
            }
            //right
            if column != 7 {
                for i in (column + 1)...7 {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("b") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("w") {
                        break
                    }
                }
            }
            //top
            if row != 0 {
                for i in stride(from: row-1, through: 0, by: -1) {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("b") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("w") {
                        break
                    }
                }
            }
            //bottom
            if row != 7 {
                for i in row+1...7 {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("b") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("w") {
                        break
                    }
                }
            }
            
            
            //bishop move check
            if row == 0 && column == 0 {
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 0 && column == 7 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 && column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 && column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 0 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else if row == 7 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
            } else {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        break
                    }
                }
            }
        case "Qb":
            //rook move check
            
            //left
            if column != 0 {
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("w") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("b") {
                        break
                    }
                }
            }
            //right
            if column != 7 {
                for i in (column + 1)...7 {
                    if currentBoard[row][i] == "0" {
                        possibleMoves.append(row * 8 + i)
                    } else if currentBoard[row][i].contains("w") {
                        possibleMoves.append(row * 8 + i)
                        break
                    } else if currentBoard[row][i].contains("b") {
                        break
                    }
                }
            }
            //top
            if row != 0 {
                for i in stride(from: row-1, through: 0, by: -1) {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("w") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("b") {
                        break
                    }
                }
            }
            //bottom
            if row != 7 {
                for i in row+1...7 {
                    if currentBoard[i][column] == "0" {
                        possibleMoves.append(i * 8 + column)
                    } else if currentBoard[i][column].contains("w") {
                        possibleMoves.append(i * 8 + column)
                        break
                    } else if currentBoard[i][column].contains("b") {
                        break
                    }
                }
            }
            
            //bishop move check
            if row == 0 && column == 0 {
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 0 && column == 7 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 && column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 && column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if column == 0 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if column == 7 {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 0 {
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else if row == 7 {
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
            } else {
                //top-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //top-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-left
                for i in stride(from: column-1, through: 0, by: -1) {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
                //bottom-right
                for i in column+1...7 {
                    if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("w") {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains("b") {
                        break
                    }
                }
            }
        case "Pw":
            if row != 7 {
                if row == 1 {
                    if currentBoard[row + 1][column] == "0" {
                        if currentBoard[row + 2][column] == "0" {
                            possibleMoves.append((row + 1) * 8 + column)
                            possibleMoves.append((row + 2) * 8 + column)
                        } else {
                            possibleMoves.append((row + 1) * 8 + column)
                        }
                    }
                } else {
                    if currentBoard[row + 1][column] == "0" {
                        possibleMoves.append((row + 1) * 8 + column)
                    }
                }
                
                if column == 0 {
                    if currentBoard[row + 1][column + 1].contains("b") {
                        possibleMoves.append((row + 1) * 8 + (column + 1))
                    }
                } else if column == 7 {
                    if currentBoard[row + 1][column - 1].contains("b") {
                        possibleMoves.append((row + 1) * 8 + (column - 1))
                    }
                } else {
                    if currentBoard[row + 1][column - 1].contains("b") {
                        possibleMoves.append((row + 1) * 8 + (column - 1))
                    }
                    if currentBoard[row + 1][column + 1].contains("b") {
                        possibleMoves.append((row + 1) * 8 + (column + 1))
                    }
                }
            }
        case "Pb":
            if row != 0 {
                if row == 6 {
                    if currentBoard[row - 1][column] == "0" {
                        if currentBoard[row - 2][column] == "0" {
                            possibleMoves.append((row - 1) * 8 + column)
                            possibleMoves.append((row - 2) * 8 + column)
                        } else {
                            possibleMoves.append((row - 1) * 8 + column)
                        }
                    }
                } else {
                    if currentBoard[row - 1][column] == "0" {
                        possibleMoves.append((row - 1) * 8 + column)
                    }
                }
                
                if column == 0 {
                    if currentBoard[row - 1][column + 1].contains("w") {
                        possibleMoves.append((row - 1) * 8 + (column + 1))
                    }
                } else if column == 7 {
                    if currentBoard[row - 1][column - 1].contains("w") {
                        possibleMoves.append((row - 1) * 8 + (column - 1))
                    }
                } else {
                    if currentBoard[row - 1][column - 1].contains("w") {
                        possibleMoves.append((row - 1) * 8 + (column - 1))
                    }
                    if currentBoard[row - 1][column + 1].contains("w") {
                        possibleMoves.append((row - 1) * 8 + (column + 1))
                    }
                }
            }
        default:
            ()
        }
        
        return possibleMoves
    }
}
