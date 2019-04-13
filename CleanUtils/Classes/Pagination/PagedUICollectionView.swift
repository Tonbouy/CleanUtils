//
//  PagedUICollectionView.swift
//  PagedUICollectionView
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol PagedUICollectionViewDataSource: UICollectionViewDataSource, PagedDataSource {

}

open class PagedUICollectionView: UICollectionView {

    public var loadingColor = UIColor.lightGray {
        didSet {
            self.refreshControl?.tintColor = loadingColor
        }
    }
    public var activityIndicator: UIActivityIndicatorView!
    public var isLoading = false

    open var pagedDataSource: PagedUICollectionViewDataSource?

    open override var dataSource: UICollectionViewDataSource? {
        didSet {
            if let pagin = dataSource as? PagedUICollectionViewDataSource {
                pagedDataSource = pagin
                setupRefresher()
            }
        }
    }

    func setupRefresher() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = loadingColor
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
    }

    open override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        if let count = dataSource?.collectionView(self, numberOfItemsInSection: indexPath.section) {
            if indexPath.row >= (count - 5) {
                self.loadMore()
            }
        }
        return super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    @objc func refreshData() {
        if isLoading {
            refreshControl?.endRefreshing()
        }
        pagedDataSource?.refreshData()
    }

    func loadMore() {
        pagedDataSource?.loadMore()
    }

    public func setLoading(_ loading: Bool) {
        if loading {
            showLoading()
        } else {
            hideLoading()
        }
        isLoading = loading
    }

    private func showLoading() {
        if isLoading || refreshControl?.isRefreshing == true {
            return
        }
        showSpinning()
    }

    private func hideLoading() {
        if activityIndicator == nil || !isLoading {
            return
        }
        refreshControl?.endRefreshing()
        self.activityIndicator.stopAnimating()
    }

    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = loadingColor
        return activityIndicator
    }

    private func showSpinning() {
        if activityIndicator == nil {
            activityIndicator = createActivityIndicator()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(activityIndicator)
            centerActivityIndicatorInButton()
        }
        refreshControl?.endRefreshing()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}

public extension Reactive where Base: PagedUICollectionView {

    /// Bindable sink for `loading` property.
    public var isLoading: Binder<Bool> {
        return Binder(self.base) { element, value in
            element.setLoading(value)
        }
    }
}
