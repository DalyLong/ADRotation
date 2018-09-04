//
//  ADRotation.swift
//  ADRotationDemo
//
//  Created by Public on 2018/9/4.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit

protocol ADRotationDelegate:NSObjectProtocol {
    /// 点击文字回调
    func adRotation(adRotation:ADRotation , didSelectAt index:Int)
    /// 文字滚动回调
    func adRotation(adRotation:ADRotation , didScrollTo index:Int)
}

class ADRotation: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

    weak var delegate:ADRotationDelegate?
    
    ///是否自动滚动,默认true
    var isAutoScroll : Bool = true{
        didSet{
            resetRotation()
        }
    }
    ///自动滚动间隔时间,默认2s
    var autoScrollTimeInterval : TimeInterval = 2{
        didSet{
            resetRotation()
        }
    }
    ///是否无限循环,默认true
    var isInfiniteLoop : Bool = true{
        didSet{
            if datas != nil {
                datas = datas!
            }
        }
    }
    ///是否支持手动滑动,默认true
    var isTouchScroll : Bool = true{
        didSet{
            mainView?.isScrollEnabled = isAutoScroll
        }
    }
    ///字体
    var titleFont : UIFont = UIFont.systemFont(ofSize: 17){
        didSet{
            mainView?.reloadData()
        }
    }
    ///字体颜色
    var titleColor : UIColor = UIColor.black{
        didSet{
            mainView?.reloadData()
        }
    }
    ///基础数组的赋值
    var datas : Array<String>?{
        didSet{
            if datas != nil{
                invalidateTimer()
                totalItemsCount = isInfiniteLoop ? datas!.count * 100 : datas!.count
                if (datas!.count != 1) {
                    mainView?.isScrollEnabled = true
                    resetRotation()
                } else {
                    mainView?.isScrollEnabled = false
                }
                mainView?.reloadData()
            }
        }
    }
    
    private var mainView : UICollectionView?
    private var flowLayout : UICollectionViewFlowLayout?
    private var timer : Timer?
    private var totalItemsCount : Int = 0
    
    ///重写的初始化方法
    init(frame: CGRect,titles:Array<String>) {
        super.init(frame: frame)
        self.datas = titles
        self.initialization()
        self.setupMainView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化配置
    private func initialization() {
        autoScrollTimeInterval = 2.0
        isAutoScroll = true
        isInfiniteLoop = true
        isTouchScroll = true
    }
    
    private func setupMainView() {
        self.backgroundColor = UIColor.white
        flowLayout = UICollectionViewFlowLayout()
        flowLayout?.minimumLineSpacing = 0
        flowLayout?.scrollDirection = .vertical;
        
        mainView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout!)
        mainView?.backgroundColor = UIColor.clear
        mainView?.isPagingEnabled = true
        mainView?.showsHorizontalScrollIndicator = false
        mainView?.showsVerticalScrollIndicator = false
        mainView?.register(ADRotationCell.self, forCellWithReuseIdentifier: "ADRotationCell")
        mainView?.dataSource = self
        mainView?.delegate = self
        mainView?.scrollsToTop = false
        self.addSubview(mainView!)
    }
    
    //刷新界面
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout?.itemSize = self.frame.size
        
        mainView?.frame = self.bounds
        if (mainView?.contentOffset.x == 0 &&  (totalItemsCount != 0)) {
            var targetIndex = 0
            if (isInfiniteLoop) {
                targetIndex = Int(totalItemsCount / 2)
            }else{
                targetIndex = 0
            }
            mainView?.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: .bottom, animated: false)
        }
    }
    
    //重置timer
    private func resetRotation(){
        invalidateTimer()
        if (isAutoScroll == true) {
            setupTimer()
        }
    }
    
    //解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) {
            invalidateTimer()
        }
    }
    
    //collectionView的delegate和datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ADRotationCell", for: indexPath) as! ADRotationCell
        let itemIndex = indexPath.item % (self.datas?.count)!;
        cell.titleLabel?.text = self.datas?[itemIndex]
        cell.titleLabel?.textColor = titleColor
        cell.titleLabel?.font = titleFont
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexOnPageControl = indexPath.row % self.datas!.count
        delegate?.adRotation(adRotation: self, didScrollTo: indexOnPageControl)
    }
    
    //timer设置
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func automaticScroll(){
        if (0 == totalItemsCount){
            return
        }
        let currentIndex = self.currentIndex()
        var targetIndex = currentIndex + 1
        if (targetIndex >= totalItemsCount) {
            if (isInfiniteLoop) {
                targetIndex = Int(totalItemsCount / 2)
                mainView?.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: .bottom, animated: true)
            }
            return
        }
        mainView?.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: .bottom, animated: true)
    }
    
    private func currentIndex() -> Int {
        if (mainView?.bounds.size.width == 0 || mainView?.bounds.size.height == 0) {
            return 0
        }
        
        var index = 0
        index = Int((mainView!.contentOffset.y + flowLayout!.itemSize.height * 0.5) / flowLayout!.itemSize.height)
        
        return max(0, index)
    }
    
    //UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 解决清除timer时偶尔会出现的问题
        if (self.datas!.count < 0){
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (isAutoScroll == true) {
            self.invalidateTimer()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (isAutoScroll == true) {
            self.setupTimer()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(mainView!)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 解决清除timer时偶尔会出现的问题
        if (self.datas!.count < 0){
            return
        }
        let itemIndex = self.currentIndex()
        let indexOnPageControl = itemIndex % self.datas!.count
        delegate?.adRotation(adRotation: self, didScrollTo: indexOnPageControl)
    }
    
    //销毁
    deinit {
        mainView?.delegate = nil
        mainView?.dataSource = nil
    }

}
