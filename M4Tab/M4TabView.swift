//
//  M4TabView.swift
//  M4Tab
//
//  Created by Chen,Meisong on 2019/5/23.
//  Copyright © 2019 xyz.chenms. All rights reserved.
//

import UIKit

// TODO:@【m2】:还没处理items长度之和超过屏幕的情况

protocol Titleable {
    var title: String { get }
}

enum TabAlignType {
    case left
    case center
}

class M4TabView: UIView {
    // UI
    static let kItemBetween: CGFloat = 24.0
    static let kIndicatorXModifier: CGFloat = 3.0
    static let kIndicatorYMargin: CGFloat = 5.0
    static let kIndicatorWidth: CGFloat = 12.0
    static let kIndicatorHeight: CGFloat = 5.0
    static let kIndicatorExtraSideLength: CGFloat = 5.0
    static let kIndicatorExtraXMargin: CGFloat = 3.0
    static let kAnimationDuration: Double = 0.2
    
    lazy var scrollContainer: UIScrollView = {
        let scrollContainer = UIScrollView()
        scrollContainer.showsHorizontalScrollIndicator = false
        scrollContainer.showsVerticalScrollIndicator = false
        return scrollContainer
    }()
    lazy var selectedIndicator: UIView = {
        let selectedIndicator = UIView()
        selectedIndicator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        selectedIndicator.layer.cornerRadius = M4TabView.kIndicatorHeight / 2
        return selectedIndicator
    }()
    lazy var selectedIndicatorExtra: UIView = {
        let selectedIndicatorExtra = UIView()
        selectedIndicatorExtra.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        selectedIndicatorExtra.layer.cornerRadius = M4TabView.kIndicatorExtraSideLength / 2
        return selectedIndicatorExtra
    }()
    lazy var items: [UIButton] = {
        let items = [UIButton]()
        return items
    }()
    var normalColor: UIColor {
        didSet {
            self.itemConverter.normalColor = normalColor
        }
    }
    var selectedColor: UIColor {
        didSet {
            self.itemConverter.selectedColor = selectedColor
        }
    }
    lazy var itemConverter: M4ItemTabConverter = {
        let converter = M4ItemTabConverter()
        converter.normalColor = self.normalColor
        converter.selectedColor = self.selectedColor
        
        return converter
    }();
    lazy var indicatorConverter: M4IndicatorTabConverter = {
        let converter = M4IndicatorTabConverter()
        converter.maxExtraWidth = 20
        
        return converter
    }();
    
    lazy var titleFont: UIFont = {
        let titleFont = UIFont.boldSystemFont(ofSize: 26)
        return titleFont
    }()
    var alignType = TabAlignType.left
    
    // data
    var datas:[Titleable]?
    var selectedIndex = 0
    
    // callback
    var didSelectedIndexCallback: ((Int) -> ())?
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        normalColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        selectedColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        super.init(frame: frame)
        
        addSubViews()
        makeLayout()
    }
}

extension M4TabView {
    private func addSubViews() {
        addSubview(scrollContainer)
        scrollContainer.addSubview(selectedIndicator)
        scrollContainer.addSubview(selectedIndicatorExtra)
    }
    
    private func makeLayout() {
        scrollContainer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: M4TabView.kIndicatorHeight)
        selectedIndicator.frame = CGRect(x: M4TabView.kIndicatorXModifier, y: 0, width:M4TabView.kIndicatorWidth , height: M4TabView.kIndicatorHeight)
        selectedIndicatorExtra.frame = CGRect(x: selectedIndicator.frame.maxX +  M4TabView.kIndicatorExtraXMargin, y: 0, width:M4TabView.kIndicatorExtraSideLength , height: M4TabView.kIndicatorExtraSideLength)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var indicatorFrame = selectedIndicator.frame
        indicatorFrame.origin.y = scrollContainer.bounds.height - indicatorFrame.size.height
        selectedIndicator.frame = indicatorFrame
        
        var indicatorExtraFrame = selectedIndicatorExtra.frame
        indicatorExtraFrame.origin.y = selectedIndicator.frame.minY - (selectedIndicatorExtra.bounds.height - selectedIndicator.bounds.height) / 2
        selectedIndicatorExtra.frame = indicatorExtraFrame
    }
}

extension M4TabView {
    public func configDatas(_ datas: [Titleable]?, selectedIndex: Int) {
        guard let datas = datas,
            datas.count > 0,
            selectedIndex >= 0 else { return }
        
        self.datas = datas
        items.forEach {
            $0.removeFromSuperview()
        }
        var tailX: CGFloat = 0.0
        datas.forEach {
            let title = $0.title
            let size = sizeForSingleLineText(title as NSString, font: titleFont)
            let item = buildItem(title)
            item.frame = CGRect(x: tailX, y: 0, width: ceil(size.width), height: ceil(size.height));
            scrollContainer.addSubview(item)
            items.append(item)
            tailX = (item.frame.maxX + M4TabView.kItemBetween)
        }
        
        let scrollHeight = items.last!.frame.maxY - fontYPadding(titleFont) + M4TabView.kIndicatorYMargin + M4TabView.kIndicatorHeight;
        scrollContainer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: scrollHeight)
        scrollContainer.contentSize = CGSize(width: items.last!.frame.maxX, height: scrollHeight);
        
        // UI
        items.forEach {
            $0.transform = itemConverter.normalTransform
        }
        updateUI(selectedIndex: self.selectedIndex)
    }
    
    private func buildItem(_ title: String) -> (UIButton) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = titleFont
        button.setTitleColor(normalColor, for: .normal)
        button.addTarget(self, action: #selector(onTapItem), for: .touchUpInside)
        
        return button
    }
    
    @objc private func onTapItem(item: UIButton) {
        if let index = items.firstIndex(of: item) {
            didSelectedIndexCallback?(index)
        }
    }
}

extension M4TabView: M4LeftPercentAcceptable {
    func accept(leftIndex: Int, leftPercent: CGFloat) -> () {
        guard leftIndex >= 0, leftIndex + 1 <= items.count - 1 else { return }
        
        guard let itemInfo = itemConverter.convert(leftPercent: leftPercent) else { return }
        
        // item
        let leftItem = items[leftIndex]
        leftItem.setTitleColor(itemInfo.leftColor, for: .normal)
        leftItem.transform = itemInfo.leftTransform ?? CGAffineTransform.identity
        
        let rightItem = items[leftIndex + 1]
        rightItem.setTitleColor(itemInfo.rightColor, for: .normal)
        rightItem.transform = itemInfo.rightTransform ?? CGAffineTransform.identity
        
        // indicator
        let leftX = leftItem.frame.minX;
        let rightX = rightItem.frame.minX
        let indicatorInfo = indicatorConverter.convert(leftX: leftX, rightX: rightX, leftPercent: leftPercent)
        var indicatorFrame = selectedIndicator.frame
        indicatorFrame.origin.x = leftX + M4TabView.kIndicatorXModifier + indicatorInfo.xModifier
        indicatorFrame.size.width = M4TabView.kIndicatorWidth + indicatorInfo.widthModifier
        selectedIndicator.frame = indicatorFrame
        
        var indicatorExtraFrame = selectedIndicatorExtra.frame
        indicatorExtraFrame.origin.x = selectedIndicator.frame.minX + M4TabView.kIndicatorWidth + M4TabView.kIndicatorExtraXMargin
        selectedIndicatorExtra.frame = indicatorExtraFrame
    }
}

extension M4TabView {
    private func updateUI(selectedIndex: Int, animated: Bool) {
        if animated {
            UIView.animate(withDuration: M4TabView.kAnimationDuration) {
                self.updateUI(selectedIndex: selectedIndex)
            }
        } else {
            self.updateUI(selectedIndex: selectedIndex)
        }
    }
    
    private func updateUI(selectedIndex: Int) {
        if self.selectedIndex != selectedIndex {
            let lastItem = items[self.selectedIndex]
            lastItem.setTitleColor(normalColor, for: .normal)
            lastItem.transform = itemConverter.normalTransform
        }
        
        let curItem = items[selectedIndex]
        curItem.setTitleColor(selectedColor, for: .normal)
        curItem.transform = itemConverter.selectedTransform
        
        let indicatorX = curItem.frame.origin.x;
        var indicatorFrame = selectedIndicator.frame
        indicatorFrame.origin.x = indicatorX + M4TabView.kIndicatorXModifier
        selectedIndicator.frame = indicatorFrame
        
        var indicatorExtraFrame = selectedIndicatorExtra.frame
        indicatorExtraFrame.origin.x = selectedIndicator.frame.minX + M4TabView.kIndicatorWidth + M4TabView.kIndicatorExtraXMargin
        selectedIndicatorExtra.frame = indicatorExtraFrame
        
        self.selectedIndex = selectedIndex
    }
}

extension M4TabView {
    private func sizeForSingleLineText(_ text: NSString, font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let rect = text.boundingRect(with: CGSize(width: 10000, height: 10000),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: attributes,
                                     context: nil)
        
        return rect.size
    }
    
    private func fontYPadding(_ font: UIFont) -> CGFloat {
        let padding =  (font.lineHeight - font.pointSize) / 2
        
        return max(padding, 0)
    }
}
