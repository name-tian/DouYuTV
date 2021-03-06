//
//  PageTitleView.swift
//  DouYu
//
//  Created by 田全军 on 17/1/12.
//  Copyright © 2017年 Quanjun. All rights reserved.
//

import UIKit

// MARK: 自定义协议
protocol PageTitleViewDelegate : class {
    func pageTitleView(_ titleView : PageTitleView, selectedIndex index : Int)
}

// MARK: 定义常量
private let kScrollLineH : CGFloat = 2
private let kScrollLineSpace : CGFloat = 20
private let kNormalColor : (CGFloat, CGFloat, CGFloat) = (85, 85, 85)
private let kSelectColor : (CGFloat, CGFloat, CGFloat) = (255, 128, 0)


class PageTitleView: UIView {

    //MARK:定义属性
    var currentIndex: Int = 0
    var titles : [String]
    weak var delegate: PageTitleViewDelegate?
    
    // MARK: 懒加载属性
    fileprivate lazy var titleLables : [UILabel] = [UILabel]()
    fileprivate lazy var titleScroll : UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false  //分页效果
        scrollView.scrollsToTop = false   //false后,点击可以回到顶部
        return scrollView
    }()
    fileprivate lazy var ScrollLine : UIView = {
       let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.orange
        return scrollLine
    }()
    
    // MARK: 自定义构造函数
    init(frame: CGRect, titles : [String]) {
        self.titles = titles
        
        super.init(frame: frame)
        
        //设置界面
        onFinishView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: 设置界面
extension PageTitleView{
    
    //设置界面
    fileprivate func onFinishView(){
        // 1.添加UIScrollView
        addSubview(titleScroll)
        titleScroll.frame = bounds
        
        // 2.添加title对应的Label
        setupTitleLables()
        
        // 3.设置底线和滚动的滑块
        setupBottomLineAndScrollLine()
    }
    
    //创建标题Lable
    fileprivate func setupTitleLables(){
        let lableW : CGFloat = frame.size.width / CGFloat(titles.count)
        let lableH : CGFloat = frame.size.height - kScrollLineH
        let lableY : CGFloat = 0
        
        for (index, title) in titles.enumerated(){
            let lable = UILabel()
            
            lable.text = title
            lable.textAlignment = .center
            lable.tag = index
            lable.font = UIFont.systemFont(ofSize: 16)
            
            let lableX = lableW * CGFloat(index)
            lable.frame = CGRect(x: lableX, y: lableY, width: lableW, height: lableH)
            titleScroll.addSubview(lable)
            
            titleLables.append(lable)
            
            //监听label的点击
            lable.isUserInteractionEnabled = true
            lable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PageTitleView.titleLabelClick(_:))))
        }
    }
    
    // 3.设置底线和滚动的滑块
    fileprivate func setupBottomLineAndScrollLine(){
        //1,添加底线
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.lightGray
        let bottomLineH : CGFloat = 0.5
        bottomLine.frame = CGRect(x: 0, y: frame.size.height - bottomLineH, width: frame.size.width, height: bottomLineH)
        addSubview(bottomLine)
        
        //2,添加滑块
        //2-1获得第一个lable的frame
        guard let firstLable = titleLables.first else {return}
        firstLable.textColor = UIColor.orange
        //2-2设置scrollLine的属性
        titleScroll.addSubview(ScrollLine)
        ScrollLine.frame = CGRect(x: firstLable.frame.origin.x + kScrollLineSpace / 2.0, y: frame.size.height - kScrollLineH, width: firstLable.frame.size.width - kScrollLineSpace, height: kScrollLineH)
    }
}

// MARK: 监听label的点击
extension PageTitleView{
    @objc fileprivate func titleLabelClick(_ tap: UITapGestureRecognizer){
        // 0.获取当前Label
        guard let currentLabel = tap.view as? UILabel else { return }
        
        // 1.如果是重复点击同一个Title,那么直接返回
        if currentLabel.tag == currentIndex { return }
        
        // 2.获取之前的Label
        let oldLabel = titleLables[currentIndex]
        
        // 3.切换文字的颜色
        currentLabel.textColor = UIColor.orange
        oldLabel.textColor = UIColor.black
        
        // 4.保存最新Label的下标值
        currentIndex = currentLabel.tag
        
        // 5.滚动条位置发生改变
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.ScrollLine.frame.origin.x = currentLabel.frame.origin.x + kScrollLineSpace / 2
        }) 
        delegate?.pageTitleView(self, selectedIndex: currentIndex)
    }
}

// MARK:- 对外暴露的方法
extension PageTitleView {
    func setTitleWithProgress(_ progress : CGFloat, sourceIndex : Int, targetIndex : Int) {
        // 1.取出sourceLabel/targetLabel
        let sourceLabel = titleLables[sourceIndex]
        let targetLabel = titleLables[targetIndex]
        
        // 2.处理滑块的逻辑
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = moveTotalX * progress + kScrollLineSpace / 2
        ScrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
        // 3.颜色的渐变(复杂)
        // 3.1.取出变化的范围
        let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1, kSelectColor.2 - kNormalColor.2)
        
        // 3.2.变化sourceLabel
        sourceLabel.textColor = UIColor(r: kSelectColor.0 - colorDelta.0 * progress, g: kSelectColor.1 - colorDelta.1 * progress, b: kSelectColor.2 - colorDelta.2 * progress)
        
        // 3.2.变化targetLabel
        targetLabel.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        
        // 4.记录最新的index
        currentIndex = targetIndex
    }
}
