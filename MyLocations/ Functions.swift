//
//   Functions.swift
//  MyLocations
//
//  Created by yanjixian on 2021/7/6.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(
    deadline: .now() + seconds,
    execute: run)
}

