//
//  DataState.swift
//  DataState
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

public struct DataState<Data> : State {
    
    public typealias T = Data
    public typealias P = PartialEvent<Data>
    
    public static var initialState: DataState<Data> {
        return DataState(data: nil,
                         localEnabled: true,
                         localLoading: true,
                         remoteEnabled: true,
                         remoteLoading: true,
                         refreshLoading: false,
                         error: nil)
    }
    
    public let data: Data?
    public let localEnabled: Bool
    public let localLoading: Bool
    public let remoteEnabled: Bool
    public let remoteLoading: Bool
    public let refreshLoading: Bool
    public let error: Error?

    public init(data: Data? = nil,
                localEnabled: Bool = false,
                localLoading: Bool = false,
                remoteEnabled: Bool = false,
                remoteLoading: Bool = false,
                refreshLoading: Bool = false,
                error: Error? = nil) {
        self.data = data
        self.localEnabled = localEnabled
        self.localLoading = localLoading
        self.remoteEnabled = remoteEnabled
        self.remoteLoading = remoteLoading
        self.refreshLoading = refreshLoading
        self.error = error
    }
    
    public func copy(data: Data? = nil,
                     localEnabled: Bool? = nil,
                     localLoading: Bool? = nil,
                     remoteEnabled: Bool? = nil,
                     remoteLoading: Bool? = nil,
                     refreshLoading: Bool? = nil,
                     error: Error? = nil) -> DataState<Data> {
        return DataState(
            data: data ?? self.data,
            localEnabled: localEnabled ?? self.localEnabled,
            localLoading: localLoading ?? self.localLoading,
            remoteEnabled: remoteEnabled ?? self.remoteEnabled,
            remoteLoading: remoteLoading ?? self.remoteLoading,
            refreshLoading: refreshLoading ?? self.refreshLoading,
            error: error ?? self.error
        )
    }
    
    public func isDataEmpty(_ data: Data?) -> Bool {
        return data == nil
    }
    
    public func reduce(partial: P) -> DataState<Data> {
        switch partial {
        case .localLoad:
            return copy(localLoading: true)
            
        case .localSuccess(let data):
            let dataEmpty = self.isDataEmpty(data)
            if !dataEmpty || !remoteEnabled {
                return copy(data: data, localLoading: false)
            } else if !remoteLoading && dataEmpty {
                return copy(localLoading: false)
            } else {
                return copy()
            }
            
        case .localError(let error):
            return copy(data: nil,
                        localLoading: false,
                        remoteLoading: false,
                        error: error)
            
        case .remoteLoad:
            return copy(remoteLoading: true)
            
        case .remoteSuccess(let data):
            return copy(data: localEnabled ? self.data : data,
                        localLoading: (localLoading && !self.isDataEmpty(data)),
                        remoteLoading: false,
                        refreshLoading: false)
            
        case .remoteError(let error):
            if localLoading && isDataEmpty {
                return copy(localLoading: false,
                            remoteLoading: false,
                            refreshLoading: false,
                            error: error)
            } else {
                return copy(remoteLoading: false,
                            refreshLoading: false,
                            error: error)
            }
            
        case .refreshLoading:
            return copy(data: nil, refreshLoading: true)
            
        case .reset:
            return DataState(data: nil,
                             localEnabled: localEnabled,
                             localLoading: localEnabled,
                             remoteEnabled: remoteEnabled,
                             remoteLoading: remoteEnabled,
                             refreshLoading: false,
                             error: nil)
        case .empty:
            return DataState(data: nil,
                             localEnabled: localEnabled,
                             localLoading: false,
                             remoteEnabled: remoteEnabled,
                             remoteLoading: false,
                             refreshLoading: false,
                             error: nil)
        case .paginationError, .paginationLoad, .paginationSuccess:
            return self
        }
    }
}
