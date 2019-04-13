//
//  ActionState+Rx.swift
//  ActionState+Rx
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Observable {

    public func executeAction(with relay: BehaviorRelay<ActionState>,
                              onPartial: ((ActionState.Partial) -> Void)? = nil) -> Disposable {
        return load(with: relay, converter: { event -> ActionState.Partial in
            switch event {
            case .load:
                return .execute
            case .success(let data):
                return .success(response: data)
            case .error(let error):
                return .failure(error: error)
            }
        }, onPartial: onPartial)
    }
    
    public func executeAction<I, O>(with relay: BehaviorRelay<ActionState>,
                                    viewModel: CleanViewModel<I, O>,
                                    success: O,
                                    error: O? = nil,
                                    onPartial: ((ActionState.Partial) -> Void)? = nil) {
        load(with: relay, converter: { event -> ActionState.Partial in
            switch event {
            case .load:
                return .execute
            case .success(let data):
                return .success(response: data)
            case .error(let error):
                return .failure(error: error)
            }
        }, onPartial: { partial in
            onPartial?(partial)
            if case .success = partial {
                viewModel.dispatchOutput(success)
            } else if case .failure = partial, let error = error {
                viewModel.dispatchOutput(error)
            }
        }).disposed(by: viewModel)
    }
}

public extension ActionState {
    
    public static var relay: BehaviorRelay<ActionState> {
        return BehaviorRelay<ActionState>(value: ActionState.initialState)
    }
    
    public static func relay(with initialValue: ActionState) -> BehaviorRelay<ActionState> {
        return BehaviorRelay<ActionState>(value: initialValue)
    }
}
