//
//  M4IndicatorTabConverter.swift
//  M4Tab
//
//  Created by Chen,Meisong on 2019/5/24.
//  Copyright © 2019 xyz.chenms. All rights reserved.
//

import UIKit

class M4IndicatorTabConverter {
    public var maxExtraWidth: CGFloat = 10
}

extension M4IndicatorTabConverter {
    public func convert(leftX: CGFloat, rightX: CGFloat, leftPercent: CGFloat) -> (M4IndicatorInfo) {
        // x-线性
        let distance:CGFloat = rightX - leftX;
        let currentXModifier = distance * (1 - leftPercent);
        
        // width-黏性
        var curWidthModifier: CGFloat = 0.0
        if (leftPercent <= 0.25) {
            curWidthModifier = maxExtraWidth * (leftPercent / 0.25)
        } else if (leftPercent >= 0.75) {
            curWidthModifier = maxExtraWidth * ((1 - leftPercent) / (1 - 0.75))
        } else {
            curWidthModifier = maxExtraWidth
        }
        
        let info = M4IndicatorInfo()
        info.xModifier = currentXModifier
        info.widthModifier = curWidthModifier
        
        return info
    }
}

class M4IndicatorInfo {
    var xModifier: CGFloat = 0
    var widthModifier: CGFloat = 0
}
