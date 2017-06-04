//
//  Log.swift
//  test
//
//  Created by admin on 15/1/2016.
//  Copyright © 2016 Eric Cheung. All rights reserved.
//

import Foundation

func dlog(message: String = "", file: String = #file, function: String = #function, lineNum: Int = #line) {
    #if DEBUG
        
        let fileUrl = NSURL(fileURLWithPath: file)
        let filePathComponents = fileUrl.pathComponents!
        print("\(filePathComponents.last!)    \(function)    Line \(lineNum)    \(message)")
        
    #else
        // do nothing
    #endif
}
