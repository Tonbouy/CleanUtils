//
//  State.swift
//  State
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

public protocol State: ViewState where P == PartialEvent<T> {
    associatedtype T
    
    var data: T? { get }
    var localEnabled: Bool { get }
    var localLoading: Bool { get }
    var remoteEnabled: Bool { get }
    var remoteLoading: Bool { get }
    var refreshLoading: Bool { get }
    var error: Error? { get }
    
    func isDataEmpty(_ data: T?) -> Bool
}

public extension State {
    
    public var isGlobalLoading: Bool {
        return isDataEmpty && (remoteLoading || localLoading)
    }
    
    public var isLoading: Bool {
        return localLoading || remoteLoading || refreshLoading
    }
    
    public var isDataEmpty: Bool {
        return isDataEmpty(data)
    }
    
    public var isEmpty: Bool {
        return isDataEmpty && !isGlobalLoading
    }
    
    public var hintError: Error? {
        return isDataEmpty ? nil : error
    }
    
    public var globalError: Error? {
        if !isDataEmpty {
            return nil
        } else if isLoading {
            return nil
        }
        return error
    }
}

public enum PartialEvent<T> : PartialState {
    case localLoad
    case localSuccess(data: T)
    case localError(error: Error)
    case remoteLoad
    case remoteSuccess(data: T)
    case remoteError(error: Error)
    case refreshLoading
    case reset
    case empty

    case paginationLoad
    case paginationSuccess(data: T, page: Int, totalPages: Int, totalItems: Int)
    case paginationError(error: Error)
}
