//
//  utils.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 09/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

func documentsDirectory() -> URL {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    return path[0]
}

func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("CheckList.plist")
}
