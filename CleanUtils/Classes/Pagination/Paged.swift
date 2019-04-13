//
//  Paged.swift
//  Paged
//
//  Created by Nicolas Ribeiro on 12/04/2019.
//  Copyright © 2019 Tonbouy. All rights reserved.
//

import Foundation

public struct Paged<T> {
    public let data: T?
    public let itemsCount: Int?
    public let pagesCount: Int?

    public init(data: T?, itemsCount: Int?, pagesCount: Int?) {
        self.data = data
        self.itemsCount = itemsCount
        self.pagesCount = pagesCount
    }

    public func copy(data: T? = nil, itemsCount: Int? = nil, pagesCount: Int? = nil) -> Paged<T> {
        return Paged<T>(data: data ?? self.data, itemsCount: itemsCount ?? self.itemsCount, pagesCount: pagesCount ?? self.pagesCount)
    }
}
