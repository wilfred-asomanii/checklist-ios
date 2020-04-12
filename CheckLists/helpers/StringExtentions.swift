//
//  StringExtentions.swift
//  CheckLists
//
//  Created by Wilfred Asomani on 12/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

extension String {
    func ranges(of text: String) -> [Range<String.Index>] {

        var ranges = [Range<String.Index>]()

        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: text, options: .caseInsensitive, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: .current),
        ranges.firstIndex(of: range) == nil {
                ranges.append(range)
        }

        return ranges
    }
}
