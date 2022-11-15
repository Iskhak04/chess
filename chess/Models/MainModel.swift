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
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["0",  "0",  "0",  "0",     "0",  "0",  "0",  "0"],
                                            ["Pb", "Pb", "Pb", "Pb",    "Pb", "Pb", "Pb", "Pb"],
                                            ["Rb", "Kb", "Bb", "Kingb", "Qb", "Bb", "Kb", "Rb"]]
    
    var currentBoardM = PublishSubject<[[String]]>()
    var getCurrentBoardM = PublishSubject<Bool>()
    var cellToCheckM = PublishSubject<Int>()
    var possibleMovesM = PublishSubject<[Int]>()
    var moveToMakeM = PublishSubject<[Int]>()
    var pieceToPromoteM = PublishSubject<(Int, Int, String)>()
    
    override init() {
        super.init()
        
        pieceToPromoteM.subscribe(onNext: {
            self.makeThePromotion(firstIndexPath: $0.0, secondIndexPath: $0.1, promotionPiece: $0.2)
        }).disposed(by: bag)
        
        getCurrentBoardM.subscribe(onNext: {
            if $0 == true {
                self.currentBoardM.onNext(self.currentBoard)
            }
        }).disposed(by: bag)
        
        cellToCheckM.subscribe(onNext: {
            
            let possibleMoves = self.findPossibleMoves(indexPath: $0)
            
            self.possibleMovesM.onNext(possibleMoves)
            
        }).disposed(by: bag)
        
        moveToMakeM.subscribe(onNext: {
            self.makeTheMove(firstIndexPath: $0[0], secondIndexPath: $0[1])
        }).disposed(by: bag)
        
    }
    
    private func rookMoves(row: Int, column: Int, isWhite: Bool) -> [Int] {
        var possibleMoves: [Int] = []
        var ownPiece = ""
        var otherPiece = ""
        
        if isWhite {
            ownPiece = "w"
            otherPiece = "b"
        } else {
            ownPiece = "b"
            otherPiece = "w"
        }

        //left
        if column != 0 {
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[row][i] == "0" {
                    possibleMoves.append(row * 8 + i)
                } else if currentBoard[row][i].contains(otherPiece) {
                    possibleMoves.append(row * 8 + i)
                    break
                } else if currentBoard[row][i].contains(ownPiece) {
                    break
                }
            }
        }
        
        //right
        if column != 7 {
            for i in (column + 1)...7 {
                if currentBoard[row][i] == "0" {
                    possibleMoves.append(row * 8 + i)
                } else if currentBoard[row][i].contains(otherPiece) {
                    possibleMoves.append(row * 8 + i)
                    break
                } else if currentBoard[row][i].contains(ownPiece) {
                    break
                }
            }
        }
        
        //top
        if row != 0 {
            for i in stride(from: row-1, through: 0, by: -1) {
                if currentBoard[i][column] == "0" {
                    possibleMoves.append(i * 8 + column)
                } else if currentBoard[i][column].contains(otherPiece) {
                    possibleMoves.append(i * 8 + column)
                    break
                } else if currentBoard[i][column].contains(ownPiece) {
                    break
                }
            }
        }
        
        //bottom
        if row != 7 {
            for i in row+1...7 {
                if currentBoard[i][column] == "0" {
                    possibleMoves.append(i * 8 + column)
                } else if currentBoard[i][column].contains(otherPiece) {
                    possibleMoves.append(i * 8 + column)
                    break
                } else if currentBoard[i][column].contains(ownPiece) {
                    break
                }
            }
        }

        return possibleMoves
    }
    
    private func knightMoves(row: Int, column: Int) -> [Int] {
        var possibleMoves: [Int] = []
        
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
        
        return possibleMoves
    }
    
    private func bishopMoves(row: Int, column: Int, isWhite: Bool) -> [Int] {
        var possibleMoves: [Int] = []
        let indexPath = row * 8 + column
        var ownPiece = ""
        var otherPiece = ""
        
        if isWhite {
            ownPiece = "w"
            otherPiece = "b"
        } else {
            ownPiece = "b"
            otherPiece = "w"
        }
        
        if row == 0 && column == 0 {
            //bottom-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if row == 0 && column == 7 {
            //bottom-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if row == 7 && column == 0 {
            //top-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if row == 7 && column == 7 {
            //top-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if column == 0 {
            //top-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //bottom-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if column == 7 {
            //top-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //bottom-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if row == 0 {
            //bottom-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //bottom-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else if row == 7 {
            //top-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //top-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        } else {
            //top-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //top-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 - abs(i - column)][i] == "0" {
                    if indexPath / 8 - abs(i - column) == 0 {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 - abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 - abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //bottom-left
            for i in stride(from: column-1, through: 0, by: -1) {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
            //bottom-right
            for i in column+1...7 {
                if currentBoard[indexPath / 8 + abs(i - column)][i] == "0" {
                    if indexPath / 8 + abs(i - column) == 7 {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                        break
                    } else {
                        possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    }
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(otherPiece) {
                    possibleMoves.append((indexPath / 8 + abs(i - column)) * 8 + i)
                    break
                } else if currentBoard[indexPath / 8 + abs(i - column)][i].contains(ownPiece) {
                    break
                }
            }
        }

        return possibleMoves
    }
    
    private func kingMoves(row: Int, column: Int) -> [Int] {
        var possibleMoves: [Int] = []
        let indexPath = row * 8 + column
        
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
        
        return possibleMoves
    }
    
    private func pawnMoves(row: Int, column: Int, isWhite: Bool) -> [Int] {
        var possibleMoves: [Int] = []
        
        if isWhite {
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
            
            return possibleMoves
        }
        
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
        
        return possibleMoves
    }
    
    private func findPossibleMoves(indexPath: Int) -> [Int] {
        var possibleMoves: [Int] = []
        let row = indexPath / 8
        let column = indexPath - row * 8
        
        switch currentBoard[row][column] {
        case "Rw":
            possibleMoves.append(contentsOf: rookMoves(row: row, column: column, isWhite: true))
        case "Rb":
            possibleMoves.append(contentsOf: rookMoves(row: row, column: column, isWhite: false))
        case "Kw", "Kb":
            possibleMoves.append(contentsOf: knightMoves(row: row, column: column))
        case "Bw":
            possibleMoves.append(contentsOf: bishopMoves(row: row, column: column, isWhite: true))
        case "Bb":
            possibleMoves.append(contentsOf: bishopMoves(row: row, column: column, isWhite: false))
        case "Kingw", "Kingb":
            possibleMoves.append(contentsOf: kingMoves(row: row, column: column))
        case "Qw":
            possibleMoves.append(contentsOf: rookMoves(row: row, column: column, isWhite: true))
            possibleMoves.append(contentsOf: bishopMoves(row: row, column: column, isWhite: true))
        case "Qb":
            possibleMoves.append(contentsOf: rookMoves(row: row, column: column, isWhite: false))
            possibleMoves.append(contentsOf: bishopMoves(row: row, column: column, isWhite: false))
        case "Pw":
            possibleMoves.append(contentsOf: pawnMoves(row: row, column: column, isWhite: true))
        case "Pb":
            possibleMoves.append(contentsOf: pawnMoves(row: row, column: column, isWhite: false))
        default:
            ()
        }
        
        return possibleMoves
    }
    
    private func makeTheMove(firstIndexPath: Int, secondIndexPath: Int) {
        let row1 = firstIndexPath / 8
        let column1 = firstIndexPath - row1 * 8
        
        let row2 = secondIndexPath / 8
        let column2 = secondIndexPath - row2 * 8
        
        currentBoard[row2][column2] = currentBoard[row1][column1]
        currentBoard[row1][column1] = "0"
        
        getCurrentBoardM.onNext(true)
    }
    
    private func makeThePromotion(firstIndexPath: Int, secondIndexPath: Int, promotionPiece: String) {
        let row1 = firstIndexPath / 8
        let column1 = firstIndexPath - row1 * 8
        
        var row2 = 0
        var column2 = 0
        
        if promotionPiece.contains("w") {
            row2 = 7
            column2 = secondIndexPath - row2 * 8
        } else {
            row2 = 0
            column2 = secondIndexPath - row2 * 8
        }

        currentBoard[row2][column2] = promotionPiece
        currentBoard[row1][column1] = "0"
        
        getCurrentBoardM.onNext(true)
    }
}
