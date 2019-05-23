//
//  M4ItemTabConverter.swift
//  M4Tab
//
//  Created by Chen,Meisong on 2019/5/24.
//  Copyright © 2019 xyz.chenms. All rights reserved.
//

import UIKit

class M4ItemTabConverter {
    static let kTextScale: CGFloat = 0.75
    
    var normalColor: UIColor {
        didSet {
            updateColorDelta()
        }
    }
    var selectedColor: UIColor {
        didSet {
            updateColorDelta()
        }
    }
    var normalColorComponents: [CGFloat]?
    var selectedColorComponents: [CGFloat]?
    var colorDelta: [CGFloat]?
    
    public var normalTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: M4ItemTabConverter.kTextScale, y: M4ItemTabConverter.kTextScale)
    }
    public var selectedTransform: CGAffineTransform {
        return CGAffineTransform.identity
    }
    
    init() {
        normalColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        selectedColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

extension M4ItemTabConverter {
    public func convert(leftPercent: CGFloat) -> (M4ItemInfo?) {
        guard let normalColorComponents = normalColorComponents,
            let colorDelta = colorDelta
            else { return nil}
        
        let itemInfo = M4ItemInfo()
        itemInfo.leftColor = UIColor(red: normalColorComponents[0] + colorDelta[0] * leftPercent, green: normalColorComponents[1] + colorDelta[1] * leftPercent, blue: normalColorComponents[2] + colorDelta[2] * leftPercent, alpha: normalColorComponents[3] + colorDelta[3] * leftPercent)
        let rightPercent = 1 - leftPercent
        itemInfo.rightColor = UIColor(red: normalColorComponents[0] + colorDelta[0] * rightPercent, green: normalColorComponents[1] + colorDelta[1] * rightPercent, blue: normalColorComponents[2] + colorDelta[2] * rightPercent, alpha: normalColorComponents[3] + colorDelta[3] * rightPercent)
        
        let leftScale = M4ItemTabConverter.kTextScale + (1 - M4ItemTabConverter.kTextScale) * leftPercent
        itemInfo.leftTransform = CGAffineTransform(scaleX: leftScale, y: leftScale)
        let rightScale = M4ItemTabConverter.kTextScale + (1 - M4ItemTabConverter.kTextScale) * rightPercent
        itemInfo.rightTransform = CGAffineTransform(scaleX: rightScale, y: rightScale)
        
        return itemInfo
    }
}

extension M4ItemTabConverter {
    private func updateColorDelta() {
        guard let normalComponents = normalColor.cgColor.components,
            let selectedComponents = selectedColor.cgColor.components
            else { return }
        
        guard let normal4Components = build4ColorComponents(components: normalComponents),
            let selected4Components = build4ColorComponents(components: selectedComponents)
        else { return  }
        
        self.normalColorComponents = normal4Components
        self.selectedColorComponents = selected4Components
        
        let delta = [selected4Components[0] - normal4Components[0],
                     selected4Components[1] - normal4Components[1],
                     selected4Components[2] - normal4Components[2],
                     selected4Components[3] - normal4Components[3]]
        colorDelta = delta
    }
    
    private func build4ColorComponents(components:[CGFloat]) -> ([CGFloat]?)  {
        let count = components.count
        if count == 4 {
            return components
        } else if count == 2 {
            return [components[0], components[0], components[0], components[1]]
        } else {
            return nil
        }
    }
}

class M4ItemInfo {
    var leftColor: UIColor?
    var rightColor: UIColor?
    var leftTransform: CGAffineTransform?
    var rightTransform: CGAffineTransform?
}
