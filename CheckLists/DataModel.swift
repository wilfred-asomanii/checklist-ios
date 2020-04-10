//
//  DataModel.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 10/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class DataModel {
    var checklists = [Checklist]()

    init() {
        let _ = loadData()
    }

    func saveData() {
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(checklists)
        try? data?.write(to: dataFilePath())
    }

    func loadData() -> [Checklist] {
        if let data = try? Data(contentsOf: dataFilePath()) {
            let decoder = PropertyListDecoder()
            checklists = (try? decoder.decode([Checklist].self, from: data)) ?? []
        }

        return checklists
    }

    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return path[0]
    }

    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("CheckList.plist")
    }
}
