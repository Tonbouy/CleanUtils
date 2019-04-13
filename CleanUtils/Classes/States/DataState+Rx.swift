//
//  DataState+Rx.swift
//  DataState+Rx
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Observable {
    
    func loadRemote(with relay: BehaviorRelay<DataState<Element>>,
                           onPartial: ((PartialEvent<Element>) -> Void)? = nil) -> Disposable {
        return load(with: relay, converter: { event -> PartialEvent<Element> in
            switch event {
            case .load:
                return .remoteLoad
            case .success(let data):
                return .remoteSuccess(data: data)
            case .error(let error):
                return .remoteError(error: error)
            }
        }, onPartial: onPartial)
    }
    
    func loadLocal(with relay: BehaviorRelay<DataState<Element>>,
                          onPartial: ((PartialEvent<Element>) -> Void)? = nil) -> Disposable {
        return load(with: relay, converter: { event -> PartialEvent<Element> in
            switch event {
            case .load:
                return .localLoad
            case .success(let data):
                return .localSuccess(data: data)
            case .error(let error):
                return .localError(error: error)
            }
        }, onPartial: onPartial)
    }
}

public extension DataState {
    
    static var relay: BehaviorRelay<DataState<Data>> {
        return BehaviorRelay<DataState<Data>>(value: DataState.initialState)
    }
    
    static func relay(with initialValue: DataState<Data>) -> BehaviorRelay<DataState<Data>> {
        return BehaviorRelay<DataState<Data>>(value: initialValue)
    }
    
    static func relay(initialData: Data? = nil,
                             localEnabled: Bool = false,
                             remoteEnabled: Bool = false) -> BehaviorRelay<DataState<Data>> {
        return BehaviorRelay<DataState<Data>>(value: DataState(data: initialData,
                                                               localEnabled: localEnabled,
                                                               localLoading: localEnabled,
                                                               remoteEnabled: remoteEnabled,
                                                               remoteLoading: remoteEnabled)
        )
    }
}
