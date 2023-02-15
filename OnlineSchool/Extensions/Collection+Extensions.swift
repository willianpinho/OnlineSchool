//
//  Collection+Extensions.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 15/02/23.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
