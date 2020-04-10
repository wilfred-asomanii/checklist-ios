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
    var prevSelectedIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            //            UserDefaults.standard.synchronize() // this forces userDefaults to persist to disk immediately its updated
        }
    }

    init() {
        _ = loadData()
        registerDefaults()
        handleFirstTime()
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

    func sortChecklists() {
        checklists.sort() { list1, list2 in
            // compare 2 strings in a case agnostic way
            // also compare based on locale (sorting english can be diff from sorting german
            return list1.title.localizedCompare(list2.title) == .orderedAscending
        }
    }

    func registerDefaults() {
        let defaults = ["ChecklistIndex": -1, "FirstTime": true] as [String: Any]
        UserDefaults.standard.register(defaults: defaults)
    }

    func handleFirstTime() {
        if UserDefaults.standard.bool(forKey: "FirstTime") {
            checklists.append(Checklist(title: "To Do", iconName: "Appointments"))
            prevSelectedIndex = 0
            UserDefaults.standard.set(false, forKey: "FirstTime")
            UserDefaults.standard.synchronize()
        }
    }

    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return path[0]
    }

    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("CheckList.plist")
    }
}
