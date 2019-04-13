//
//  ActionState.swift
//  ActionState
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

public struct ActionState: ViewState {
    
    public typealias P = Partial
    
    public static var initialState: ActionState {
        return ActionState(response: nil, loading: false, error: nil)
    }

    public let response: Any?
    public let loading: Bool
    public let error: Error?
    
    public func reduce(partial: Partial) -> ActionState {
        switch partial {
        case .execute:
            return ActionState(response: nil, loading: true, error: nil)
        case .success(let response):
            return ActionState(response: response, loading: false, error: nil)
        case .failure(let error):
            return ActionState(response: nil, loading: false, error: error)
        case .reset:
            return ActionState(response: nil, loading: false, error: nil)
        }
    }
    
    public enum Partial: PartialState {
        case execute
        case success(response: Any)
        case failure(error: Error)
        case reset
    }
}
