//
//  ImageCellView.swift
//  join
//
//  Created by 連亮涵 on 2020/6/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class ImageCellView: UIView {

    let img_Main = UIImageView()
    let btn_cancel = UIButton()
    let imgView = UIImageView()
    let loadingIndicator = UIActivityIndicatorView()
    var fullImage = UIImage()
    var isVideo = false
    var url : URL!
        
    func initwithImage(img: UIImage,isVideo: Bool) -> ImageCellView
    {
        self.isVideo = isVideo
        fullImage = img
        self.frame.size = CGSize(width: 80,height: 80)
        //設定圖片
        imgView.frame = CGRect(x:0,y: 0,width: 80,height: 80)
        imgView.image = fullImage //getImg(asset: asset.phAsset!)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        self.addSubview(imgView)
        //取消按鈕
        btn_cancel.frame = CGRect(x: 56,y: 0,width: 24,height: 24)
        btn_cancel.setImage(UIImage(named: "baseline_close_black_36pt"), for: .normal)
        btn_cancel.imageView?.tintColor = .lightGray
        btn_cancel.addTarget(self, action: #selector(removeSelf), for: .touchUpInside)
        self.addSubview(btn_cancel)
        if isVideo
        {
            imgView.alpha = 0.5
            loadingIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            loadingIndicator.center = imgView.center
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.white
            loadingIndicator.color = Colors.themePurple
            self.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
        }
        return self
    }
        
    func setUrl(url: URL)
    {
        self.url = url
        DispatchQueue.main.async {
            self.imgView.alpha = 1
            self.loadingIndicator.stopAnimating()
        }
    }
        
    @objc func removeSelf()
    {
        //刪除後重整layout
        let parent = self.findViewController() as! PostVC
        self.removeFromSuperview()
        parent.setSvImageLayout()

    }
        
}

