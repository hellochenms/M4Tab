//
//  M4LeftPercentScrollTranslator.swift
//  M4Tab
//
//  Created by Chen,Meisong on 2019/5/24.
//  Copyright © 2019 xyz.chenms. All rights reserved.
//

import UIKit

protocol M4LeftPercentAcceptable {
    func accept(leftIndex: Int, leftPercent: CGFloat) -> ()
}

class M4LeftPercentScrollConverter {
    public var callback: ((_ leftIndex: Int, _ leftPercent: CGFloat) -> ())?
}

extension M4LeftPercentScrollConverter {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        guard offsetX >= 0,
            offsetX <= scrollView.contentSize.width - scrollView.bounds.width
            else { return }
        
        let pageWidth = scrollView.bounds.width
        let uniOffsetX = offsetX / pageWidth
        let leftIndex = Int(uniOffsetX)
        var leftPercent = 1 - uniOffsetX - CGFloat(leftIndex)
        leftPercent =  min(max(leftPercent, 0), 1)
        
        callback?(leftIndex, leftPercent)
    }
}
