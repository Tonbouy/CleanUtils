//
//  State+Rx.swift
//  State+Rx
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Observable {
    
    public func load<State, PartialState>(with relay: BehaviorRelay<State>,
                                          converter: @escaping ((LoadEvent<Element>) -> PartialState),
                                          onPartial: ((PartialState) -> Void)? = nil) -> Disposable where State: ViewState, PartialState == State.P {
        return self
            .map { converter(.success(data: $0)) }
            .asDriver(onErrorRecover: { error in
                print(error)
                return Driver.just(converter(.error(error: error)))
            })
            .startWith(converter(.load))
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { partial in
                relay.accept(relay.value.reduce(partial: partial))
                onPartial?(partial)
            }, onError: { error in
                print("CleanUtils State+Rx.swift:load() ->" +
                    error.localizedDescription)
            })
    }
}

public enum LoadEvent<T> {
    case load
    case success(data: T)
    case error(error: Error)
}
