//
//  State+UIKit.swift
//  State+UIKit
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension ObservableType where E: State {

    func bindToPickerView<T>(_ pickerView: UIPickerView) -> Disposable where E == CollectionState<T> {
        return subscribe(onNext: { _ in
            pickerView.reloadAllComponents()
        })
    }

    func bindToPagedCollectionView<T>(_ collectionView: PagedUICollectionView) -> Disposable where E == DataState<T> {
        return self.do(onNext: { state in
            collectionView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            collectionView.reloadData()
        })
    }

    func bindToPagedCollectionView<T>(_ collectionView: PagedUICollectionView) -> Disposable where E == CollectionState<T> {
        return self.do(onNext: { state in
            collectionView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            collectionView.reloadData()
        })
    }

    func bindToPagedTableView<T>(_ tableView: PagedUITableView) -> Disposable where E == DataState<T> {
        return self.do(onNext: { state in
            tableView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            tableView.reloadData()
        })
    }

    func bindToPagedTableView<T>(_ tableView: PagedUITableView) -> Disposable where E == CollectionState<T> {
        return self.do(onNext: { state in
            tableView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            tableView.reloadData()
        })
    }
}
