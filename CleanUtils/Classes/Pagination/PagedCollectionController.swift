//
//  PagedCollectionController.swift
//  PagedCollectionController
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class PagedCollectionController<Data>: PagedDataSource {

    public let relay: BehaviorRelay<CollectionState<Data>>

    private var disposeBag = DisposeBag()
    private let request: (_ page: Int) -> Observable<Paged<[Data]>>

    public init(withRequest request: @escaping (_ page: Int) -> Observable<Paged<[Data]>>) {
        self.relay = CollectionState.relay(paginationEnabled: true)
        self.request = request
    }

    public func dispose() {
        disposeBag = DisposeBag()
    }

    public func loadMore() {
        let state = relay.value
        if !state.canLoadMore() {
            return
        }

        let page = state.currentPage + 1
        request(page)
            .loadMore(with: relay, andPage: page)
            .disposed(by: disposeBag)
    }

    public func refreshData() {
        dispose()
        request(1)
            .refreshPagedData(with: relay)
            .disposed(by: disposeBag)
    }
}
