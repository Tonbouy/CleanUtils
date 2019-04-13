//
//  BehaviorRelay+Accept.swift
//  BehaviorRelay+Accept
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public extension BehaviorRelay {

    func accept<T>(partial: PartialEvent<[T]>) where Element == CollectionState<T> {
        accept(value.reduce(partial: partial))
    }

    func accept<T>(partial: PartialEvent<T>) where Element == DataState<T> {
        accept(value.reduce(partial: partial))
    }
}
