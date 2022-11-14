//
//  MainViewModel.swift
//  chess
//
//  Created by Iskhak Zhutanov on 12/11/22.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewModel: NSObject {
    
    let bag = DisposeBag()
    
    let model = MainModel()
    
    var currentBoardVM = PublishSubject<[[String]]>()
    var getCurrentBoardVM = PublishSubject<Bool>()
    var cellToCheckVM = PublishSubject<Int>()
    var possibleMovesVM = PublishSubject<[Int]>()
    var moveToMakeVM = PublishSubject<[Int]>()
    
    override init() {
        super.init()
        
        model.possibleMovesM.subscribe(onNext: {
            self.possibleMovesVM.onNext($0)
        }).disposed(by: bag)
        
        model.currentBoardM.subscribe(onNext: {
            self.currentBoardVM.onNext($0)
        }).disposed(by: bag)
        
        getCurrentBoardVM.subscribe(onNext: {
            self.model.getCurrentBoardM.onNext($0)
        }).disposed(by: bag)
        
        cellToCheckVM.subscribe(onNext: {
            self.model.cellToCheckM.onNext($0)
        }).disposed(by: bag)
        
        moveToMakeVM.subscribe(onNext: {
            self.model.moveToMakeM.onNext($0)
        }).disposed(by: bag)
        
    }
}
