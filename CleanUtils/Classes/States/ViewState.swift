//
//  ViewState.swift
//  ViewState
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxSwift

public protocol ViewState {
    associatedtype P: PartialState
    
    func reduce(partial: P) -> Self
    
    static var initialState: Self { get }
}
