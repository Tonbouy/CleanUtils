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

    public func bindToPickerView<T>(_ pickerView: UIPickerView) -> Disposable where E == CollectionState<T> {
        return subscribe(onNext: { _ in
            pickerView.reloadAllComponents()
        })
    }

    public func bindToPagedCollectionView<T>(_ collectionView: PagedUICollectionView) -> Disposable where E == DataState<T> {
        return self.do(onNext: { state in
            collectionView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            collectionView.reloadData()
        })
    }

    public func bindToPagedCollectionView<T>(_ collectionView: PagedUICollectionView) -> Disposable where E == CollectionState<T> {
        return self.do(onNext: { state in
            collectionView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            collectionView.reloadData()
        })
    }

    public func bindToPagedTableView<T>(_ tableView: PagedUITableView) -> Disposable where E == DataState<T> {
        return self.do(onNext: { state in
            tableView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            tableView.reloadData()
        })
    }

    public func bindToPagedTableView<T>(_ tableView: PagedUITableView) -> Disposable where E == CollectionState<T> {
        return self.do(onNext: { state in
            tableView.setLoading(state.isGlobalLoading)
        }).subscribe(onNext: { _ in
            tableView.reloadData()
        })
    }

    public func bind<T>(to tableView: UITableView) -> Disposable where E == CollectionState<T> {
        switch tableView {
        case let tableView as PagedUITableView:
            return self.do(onNext: { state in
                tableView.setLoading(state.isGlobalLoading)
            }).subscribe(onNext: { _ in
                tableView.reloadData()
            })
        default:
            return subscribe(onNext: { _ in
                tableView.reloadData()
            })
        }
    }
}
