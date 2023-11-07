//
//  UserIconViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/5/19.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import TLPhotoPicker
import FirebaseStorage

class UserIconViewController: UIViewController, TLPhotosPickerViewControllerDelegate {

    @IBOutlet weak var img_Photo: UIImageView!
    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var img_Plus: UIImageView!
    @IBOutlet weak var lbl_text: UILabel!
    
    var TLConfig = TLPhotosPickerConfigure()
    var TLimgPicker = TLPhotosPickerViewController()
    
    var hasImg = false
    var isVideo = false
    var tempImg = UIImage()
    var foldername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Next.isEnabled = false
        btn_Next.layer.cornerRadius = btn_Next.frame.height / 2
        btn_Next.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        //
        TLConfig.usedCameraButton = false
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
        TLimgPicker.delegate = self
        TLimgPicker.configure = TLConfig
        TLimgPicker.configure.allowedVideo = false
        TLimgPicker.configure.maxSelectedAssets = 1
        let touch = UITapGestureRecognizer(target: self, action: #selector(choosePhoto(_:)))
        self.img_Plus.addGestureRecognizer(touch)
        self.img_Photo.addGestureRecognizer(touch)
        //
        img_Photo.isUserInteractionEnabled = true
        img_Photo.contentMode = .scaleAspectFill
        img_Photo.layer.masksToBounds = true
        //
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = Colors.themePurple.cgColor
        yourViewBorder.lineDashPattern = [4, 6]
        yourViewBorder.frame = img_Photo.bounds
        yourViewBorder.lineWidth = 6
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: img_Photo.bounds).cgPath
        img_Photo.layer.addSublayer(yourViewBorder)
    }
       
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        if TLimgPicker.selectedAssets.count != 0 {
            img_Plus.isHidden = true
            btn_Next.isEnabled = true
            hasImg = true
            btn_Next.applyGradient(colors: [#colorLiteral(red: 1, green: 0.2477881908, blue: 0.964976728, alpha: 1) , #colorLiteral(red: 0.700879395, green: 0.341196537, blue: 0.9322934747, alpha: 1)], cornerRadius: btn_Next.frame.height/2)
            img_Photo.layer.sublayers = .none
            for asset in TLimgPicker.selectedAssets {
                img_Photo.image = getImg(asset: asset.phAsset!)!
                tempImg = getImg(asset: asset.phAsset!)!
            }
        }
    }
       
    func photoPickerDidCancel() {
    
    }
       
    func dismissComplete() {
        //完成照片選取並離開
    }
    
    func uploadImgs(img:UIImage)
    {
        let DateTimeStr = getTPETime(format: "yyyyMMddHHmmss")
        let filename = "Head_\(DateTimeStr)"
        let storageRef = Storage.storage().reference().child("UserPhoto/" + foldername).child("\(filename).jpg")
        if let uploadData = img.jpegData(compressionQuality: 0.8)
        {
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            // 這行就是 FirebaseStorage 關鍵的存取方法。
            _ = storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                guard let metadata = metadata else {
                    // 連線失敗
                    self.btn_Next.isEnabled = true
                    shortInfoMsg(msg: "圖片上傳失敗，請重新上傳圖片", vc: self, sec: 2)
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                storageRef.downloadURL() { url, error in
                    guard let url = url, error == nil else
                    {   //下載圖片網址失敗
                        self.btn_Next.isEnabled = true
                        shortInfoMsg(msg: "圖片上傳失敗，請重新上傳圖片", vc: self, sec: 2)
                        return
                    }
                    let endIndex = url.absoluteString.range(of: "&token=")?.lowerBound ?? url.absoluteString.endIndex
                    globalData.user_img = String(url.absoluteString[ ..<endIndex])
                    self.btn_Next.isEnabled = true
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "NewLocationVC") as! NewLocationVC
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }
        }
    }
    
    @objc func choosePhoto(_ sender: UIButton)
    {
        TLimgPicker.selectedAssets.removeAll()
        self.present(TLimgPicker, animated: true, completion: nil)
        TLimgPicker.collectionView.reloadData()
    }
    
    // MARK: - @IBAction
    @IBAction func back(_ sender: Any) {
           self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextPage(_ sender: Any) {
        btn_Next.isEnabled = false
        uploadImgs(img: tempImg)
    }
}
