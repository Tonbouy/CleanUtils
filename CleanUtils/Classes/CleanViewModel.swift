//
//  CleanViewModel.swift
//  CleanViewModel
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

open class CleanViewModel<ActionInput, Output> {

    public var disposeBag = DisposeBag()

    fileprivate let ouputDispatcher = PublishSubject<Output>()

    public init() {

    }

    open func perform(_ input: ActionInput) {

    }

    public func dispatchOutput(_ output: Output) {
        ouputDispatcher.onNext(output)
    }

    public func subscribe(_ onOutput: @escaping (Output) -> Void) -> Disposable {
        return ouputDispatcher.subscribe(onNext: {
            onOutput($0)
        })
    }
}

public extension Disposable {

    @discardableResult
    public func disposed<ActionInput, Output>(by vm: CleanViewModel<ActionInput, Output>) -> Disposable {
        disposed(by: vm.disposeBag)
        return self
    }
}

public extension Observable {

    public func bind<Output>(to viewModel: CleanViewModel<Element, Output>) -> Disposable {
        return subscribe(onNext: { input in
            viewModel.perform(input)
        })
    }
}
