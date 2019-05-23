//
//  ViewController.swift
//  M4Tab
//
//  Created by Chen,Meisong on 2019/5/23.
//  Copyright © 2019 xyz.chenms. All rights reserved.
//

import UIKit

struct Data: Titleable {
    var title: String {
        return "你好你好"
    }
}

class ViewController: UIViewController {
    lazy var tab: M4TabView = {
        let tab = M4TabView(frame: CGRect(x: 0, y: 64, width: 300, height: 100))
        tab.didSelectedIndexCallback = {
            let offset = CGPoint(x: $0 * 300, y: 0)
            self.pageContainer.setContentOffset(offset, animated: true)
        }
        tab.configDatas([Data(), Data()], selectedIndex: 0)
        
        return tab
    }()
    lazy var pageContainer: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 164, width: 300, height: 300))
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: 300 * 2, height: 300)
        scrollView.delegate = self
        
        let page0 = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        page0.backgroundColor = UIColor.red
        scrollView.addSubview(page0)
        
        let page1 = UIView(frame: CGRect(x: 300, y: 0, width: 300, height: 300))
        page1.backgroundColor = UIColor.blue
        scrollView.addSubview(page1)
        
        return scrollView
    }()
    
    lazy var leftPercentConverter: M4LeftPercentScrollConverter = {
        let converter = M4LeftPercentScrollConverter()
        converter.callback = { leftIndex, leftPercent in
            self.tab.accept(leftIndex: leftIndex, leftPercent: leftPercent)
        }
        
        return converter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        
        addSubViews()
    }
    
    private func addSubViews() {
        view.addSubview(tab)
        view.addSubview(pageContainer)
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        leftPercentConverter.scrollViewDidScroll(scrollView)
    }
}
