//
//  CollectionState+Rx.swift
//  CollectionState+Rx
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Observable {
    
    public func loadRemote<E>(with relay: BehaviorRelay<CollectionState<E>>,
                              onPartial: ((PartialEvent<Element>) -> Void)? = nil) -> Disposable where Element == [E] {
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

    public func loadMore<E>(with relay: BehaviorRelay<CollectionState<E>>,
                            andPage page: Int,
                            onPartial: ((PartialEvent<[E]>) -> Void)? = nil) -> Disposable where Element == Paged<[E]> {
        relay.accept(relay.value.reduce(partial: .paginationLoad))
        return load(with: relay, converter: { (event: LoadEvent<Paged<[E]>>) -> PartialEvent<[E]> in
            switch event {
            case .load:
                return .paginationLoad
            case .success(let data):
                return .paginationSuccess(data: data.data ?? [], page: page, totalPages: data.pagesCount ?? 1, totalItems: data.itemsCount ?? 0)
            case .error(let error):
                return .paginationError(error: error)
            }
        }, onPartial: onPartial)
    }

    public func refreshPagedData<E>(with relay: BehaviorRelay<CollectionState<E>>,
                                    onPartial: ((PartialEvent<[E]>) -> Void)? = nil) -> Disposable where Element == Paged<[E]> {
        relay.accept(relay.value.reduce(partial: .refreshLoading))
        return loadMore(with: relay, andPage: 1, onPartial: onPartial)
    }

    public func loadLocal<E>(with relay: BehaviorRelay<CollectionState<E>>,
                             onPartial: ((PartialEvent<Element>) -> Void)? = nil) -> Disposable where Element == [E] {
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

public extension CollectionState {
    
    public static var relay: BehaviorRelay<CollectionState<Data>> {
        return BehaviorRelay<CollectionState<Data>>(value: CollectionState.initialState)
    }
    
    public static func relay(with initialValue: CollectionState<Data>) -> BehaviorRelay<CollectionState<Data>> {
        return BehaviorRelay<CollectionState<Data>>(value: initialValue)
    }
    
    public static func relay(data: [Data] = [],
                             localEnabled: Bool = false,
                             remoteEnabled: Bool = false,
                             paginationEnabled: Bool = false) -> BehaviorRelay<CollectionState<Data>> {
        return BehaviorRelay<CollectionState<Data>>(value: CollectionState(data: data,
                                                                           localEnabled: localEnabled,
                                                                           localLoading: localEnabled,
                                                                           remoteEnabled: remoteEnabled || paginationEnabled,
                                                                           remoteLoading: remoteEnabled || paginationEnabled,
                                                                           paginationEnabled: paginationEnabled,
                                                                           paginationLoading: paginationEnabled)
        )
    }
}
