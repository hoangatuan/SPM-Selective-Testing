//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

func log(
    message: @autoclosure () -> String
) {
    debugPrint(message())
}
