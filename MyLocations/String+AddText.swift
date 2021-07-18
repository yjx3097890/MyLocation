//
//  String+AddText.swift
//  MyLocations
//
//  Created by yan jixian on 2021/7/17.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = " ") {
        if let temp = text {
            if isEmpty {
                self += temp
            } else {
                self += (separator + temp)
            }
        }
    }
}
