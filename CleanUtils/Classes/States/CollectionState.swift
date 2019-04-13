//
//  CollectionState.swift
//  CollectionState
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

public struct CollectionState<Data> : State {

    public typealias T = [Data]
    public typealias P = PartialEvent<[Data]>
    
    public static var initialState: CollectionState<Data> {
        return CollectionState(data: [],
                               localEnabled: false,
                               localLoading: false,
                               remoteEnabled: true,
                               remoteLoading: true,
                               refreshLoading: false,
                               error: nil,

                               paginationEnabled: false,
                               paginationLoading: false,
                               currentPage: 1,
                               totalPages: 0
        )
    }
    
    public let data: [Data]?
    public let localEnabled: Bool
    public let localLoading: Bool
    public let remoteEnabled: Bool
    public let remoteLoading: Bool
    public let refreshLoading: Bool
    public let error: Error?

    public let paginationEnabled: Bool
    public let paginationLoading: Bool
    public let currentPage: Int
    public let totalPages: Int
    public let totalItems: Int

    public let canReloadData: Bool

    public init(data: [Data]? = [],
                localEnabled: Bool = false,
                localLoading: Bool = false,
                remoteEnabled: Bool = false,
                remoteLoading: Bool = false,
                refreshLoading: Bool = false,
                error: Error? = nil,
                paginationEnabled: Bool = false,
                paginationLoading: Bool = false,
                currentPage: Int = 1,
                totalPages: Int = 0,
                totalItems: Int = 0,
                canReloadData: Bool = false) {
        self.data = data
        self.localEnabled = localEnabled
        self.localLoading = localLoading
        self.remoteEnabled = remoteEnabled
        self.remoteLoading = remoteLoading
        self.refreshLoading = refreshLoading
        self.error = error
        self.paginationEnabled = paginationEnabled
        self.paginationLoading = paginationLoading
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
        self.canReloadData = canReloadData
    }

    public func copy(data: [Data]? = nil,
                     localEnabled: Bool? = nil,
                     localLoading: Bool? = nil,
                     remoteEnabled: Bool? = nil,
                     remoteLoading: Bool? = nil,
                     refreshLoading: Bool? = nil,
                     error: Error? = nil,
                     paginationEnabled: Bool? = nil,
                     paginationLoading: Bool? = nil,
                     currentPage: Int? = nil,
                     totalPages: Int? = nil,
                     totalItems: Int? = nil,
                     canReloadData: Bool? = nil) -> CollectionState<Data> {
        return CollectionState<Data>(
            data: data ?? self.data,
            localEnabled: localEnabled ?? self.localEnabled,
            localLoading: localLoading ?? self.localLoading,
            remoteEnabled: remoteEnabled ?? self.remoteEnabled,
            remoteLoading: remoteLoading ?? self.remoteLoading,
            refreshLoading: refreshLoading ?? self.refreshLoading,
            error: error ?? self.error,
            paginationEnabled: paginationEnabled ?? self.paginationEnabled,
            paginationLoading: paginationLoading ?? self.paginationLoading,
            currentPage: currentPage ?? self.currentPage,
            totalPages: totalPages ?? self.totalPages,
            totalItems: totalItems ?? self.totalItems,
            canReloadData: canReloadData ?? self.canReloadData
        )
    }

    public func copy<D>(newData: [D]) -> CollectionState<D> {
        return CollectionState<D>(
            data: newData,
            localEnabled: self.localEnabled,
            localLoading: self.localLoading,
            remoteEnabled: self.remoteEnabled,
            remoteLoading: self.remoteLoading,
            refreshLoading: self.refreshLoading,
            error: self.error,
            paginationEnabled: self.paginationEnabled,
            paginationLoading: self.paginationLoading,
            currentPage: self.currentPage,
            totalPages: self.totalPages,
            totalItems: self.totalItems,
            canReloadData: self.canReloadData
        )
    }

    public func isDataEmpty(_ data: [Data]?) -> Bool {
        if let data = data {
            return data.isEmpty
        } else {
            return true
        }
    }

    public var isLoading: Bool {
        return localLoading || remoteLoading || refreshLoading || paginationLoading
    }
    
    public func reduce(partial: P) -> CollectionState<Data> {
        switch partial {
        case .localLoad:
            return copy(localLoading: true, canReloadData: false)
            
        case .localSuccess(let data):
            let dataEmpty = self.isDataEmpty(data)
            if !dataEmpty || !remoteEnabled {
                return copy(data: data, localLoading: false, canReloadData: true)
            } else if !remoteLoading && dataEmpty {
                return copy(localLoading: false, canReloadData: true)
            } else {
                return copy(canReloadData: false)
            }
            
        case .localError(let error):
            return copy(data: nil,
                        localLoading: false,
                        remoteLoading: false,
                        error: error,
                        canReloadData: true)
            
        case .remoteLoad:
            return copy(remoteLoading: true, canReloadData: false)
            
        case .remoteSuccess(let data):
            return copy(data: localEnabled ? self.data : data,
                        localLoading: (localLoading && !self.isDataEmpty(data)),
                        remoteLoading: false,
                        refreshLoading: false,
                        canReloadData: true)
            
        case .remoteError(let error):
            if localLoading && isDataEmpty {
                return copy(localLoading: false,
                            remoteLoading: false,
                            refreshLoading: false,
                            error: error,
                            canReloadData: false)
            } else {
                return copy(remoteLoading: false,
                            refreshLoading: false,
                            error: error,
                            canReloadData: true)
            }
            
        case .refreshLoading:
            return copy(data: [Data](),
                        refreshLoading: true,
                        currentPage: 1,
                        canReloadData: false)
            
        case .reset:
            return copy(data: [Data](),
                        localLoading: localEnabled,
                        remoteLoading: remoteEnabled,
                        refreshLoading: false,
                        error: nil,
                        canReloadData: true)
        case .empty:
            return copy(data: [Data](),
                        localLoading: false,
                        remoteLoading: false,
                        refreshLoading: false,
                        error: nil,
                        canReloadData: true)
        case .paginationLoad:
            return copy(remoteLoading: true,
                        paginationLoading: true,
                        canReloadData: false)
        case .paginationSuccess(let data, let page, let totalPages, let totalItems):
            var newData = [Data]()
            if let previousData = self.data {
                newData.append(contentsOf: previousData)
            }
            newData.append(contentsOf: data)
            return copy(data: newData,
                        remoteLoading: false,
                        refreshLoading: false,
                        paginationLoading: false,
                        currentPage: page,
                        totalPages: totalPages,
                        totalItems: totalItems,
                        canReloadData: true)
        case .paginationError(let error):
            return copy(remoteLoading: false,
                        refreshLoading: false,
                        error: error,
                        paginationLoading: false,
                        canReloadData: true)
        }
    }
}

public extension CollectionState {

    func canLoadMore() -> Bool {
        if isLoading {
            return false
        }
        if currentPage >= totalPages {
            return false
        }
        return true
    }
}
