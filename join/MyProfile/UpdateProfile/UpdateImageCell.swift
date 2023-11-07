//
//  UpdateUserCVCell.swift
//  join
//
//  Created by 連亮涵 on 2020/7/24.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import TLPhotoPicker
import FirebaseStorage

class UpdateImageCell: UICollectionViewCell, TLPhotosPickerViewControllerDelegate {
    
    var TLConfig = TLPhotosPickerConfigure()
    var TLimgPicker = TLPhotosPickerViewController()
    
    let img_photo = UIImageView()
    let img_updatePhoto = UIImageView()
    var num: String = ""
    var new_img_url: String = ""
    var isVideo = false
    var upload_img = UIGestureRecognizer()
    var delete_img = UIGestureRecognizer()
    
    func init_photo(img_url:String,
                    size:CGFloat,
                    num: String)
    {
        self.num = num
        TLimgPicker.delegate = self
        TLConfig.usedCameraButton = false
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
        upload_img = UITapGestureRecognizer(target: self, action: #selector(choosePhoto(_:)))
        delete_img = UITapGestureRecognizer(target: self, action: #selector(delet))
        //
        img_photo.frame = CGRect(x: 0, y: 0, width: size, height: size)
        img_photo.layer.borderColor = Colors.themePurple.cgColor
        img_photo.contentMode = .scaleAspectFill
        img_photo.layer.masksToBounds = true
        img_photo.layer.borderWidth = 1
        img_photo.layer.cornerRadius = self.frame.height / 2
        img_photo.isUserInteractionEnabled = true
        self.addSubview(img_photo)
        //
        img_updatePhoto.isUserInteractionEnabled = true
        img_updatePhoto.tintColor = Colors.themePurple
        
        if img_url != "" {
            DownloadImage(view: img_photo, img: img_url, id: "",placeholder: nil)
            
            if  img_url == globalData.user_img {
                img_photo.addGestureRecognizer(upload_img)
            } else {
                img_updatePhoto.frame = CGRect(x: img_photo.frame.origin.x + img_photo.frame.width - 23, y: img_photo.frame.origin.y + img_photo.frame.height - 25, width: 25, height: 25)
                img_updatePhoto.image = UIImage(named: "baseline_delete_black_36pt")
                img_updatePhoto.addGestureRecognizer(delete_img)
                self.addSubview(img_updatePhoto)
            }
            
        } else {
            img_photo.backgroundColor = .white
            img_updatePhoto.image = BasicIcons.add_36pt
            img_updatePhoto.frame = CGRect(x: img_photo.frame.origin.x + img_photo.frame.width/2 - 14, y: img_photo.frame.origin.y + img_photo.frame.height/2 - 14, width: 30, height: 30)
            img_updatePhoto.addGestureRecognizer(upload_img)
            img_photo.addSubview(img_updatePhoto)
        }
    }
    
    func uploadImgs(img:UIImage)
    {
        let DateTimeStr = getTPETime(format: "yyyyMMddHHmmss")
        var filename: String
        
        if num == "1" {
            filename = "Head_\(DateTimeStr)"
        } else {
            filename = "\(num)_\(DateTimeStr)"
        }
        
        let storageRef = Storage.storage().reference().child("UserPhoto/" + globalData.folderName).child("\(filename).jpg")
        if let uploadData = img.jpegData(compressionQuality: 0.8)
        {
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            // 這行就是 FirebaseStorage 關鍵的存取方法。
            _ = storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    //關閉發文提示
                    dismissAlert(selfVC: self.findViewController()!)
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                storageRef.downloadURL() { url, error in
                    guard let url = url, error == nil else
                    {
                        ShowErrMsg(code: 0,msg: "圖片上傳失敗",vc: self.findViewController()!)
                        return
                    }
                    let endIndex = url.absoluteString.range(of: "&token=")?.lowerBound ?? url.absoluteString.endIndex
                    self.new_img_url = String(url.absoluteString[ ..<endIndex])
                    self.callUpdateImgService(isDelet: false)
                }
            }
        }
    }
    
    func callUpdateImgService(isDelet: Bool)
    {
        if isDelet {
            self.new_img_url = ""
        }
        let request = createHttpRequest(Url: globalData.UpdateImgUrl, HttpType: "POST", Data: "token=\(globalData.token)&img_url=\(self.new_img_url)&photo_no=\(self.num)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self.findViewController()!)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        switch self.num {
                        case "1":
                            globalData.user_img = self.new_img_url
                        case "2":
                            globalData.img_url2 = self.new_img_url
                        case "3":
                            globalData.img_url3 = self.new_img_url
                        case "4":
                            globalData.img_url4 = self.new_img_url
                        case "5":
                            globalData.img_url5 = self.new_img_url
                        case "6":
                            globalData.img_url6 = self.new_img_url
                        default:
                            break
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload_photo"), object: nil)
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        
                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.findViewController()!.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self.findViewController()!)
                    }
                }
            }
        }
        task.resume()
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset])
    {
        for asset in TLimgPicker.selectedAssets
        {
            img_photo.image = getImg(asset: asset.phAsset!)!
            img_updatePhoto.frame = CGRect(x: img_photo.frame.origin.x + img_photo.frame.width - 25, y: img_photo.frame.origin.y + img_photo.frame.height - 25, width: 30, height: 30)
            img_updatePhoto.image = UIImage(named: "baseline_delete_black_36pt")
            img_updatePhoto.removeGestureRecognizer(upload_img)
            img_updatePhoto.addGestureRecognizer(delete_img)
            uploadImgs(img: getImg(asset: asset.phAsset!)!)
        }
    }
       
    func photoPickerDidCancel()
    {
        //取消選取照片
    }
       
    func dismissComplete()
    {
        //完成照片選取並離開
    }
    @objc func choosePhoto(_ sender: UIButton)
    {
        isVideo = false
        TLimgPicker.configure = TLConfig
        TLimgPicker.configure.allowedVideo = false
        TLimgPicker.configure.maxSelectedAssets = 1
        TLimgPicker.selectedAssets.removeAll()
        self.findViewController()!.present(TLimgPicker, animated: true, completion: nil)
        TLimgPicker.collectionView.reloadData()
    }
    
    @objc func delet()
    {
        img_photo.image = .none
        img_photo.layer.borderWidth = 1
        img_updatePhoto.image = BasicIcons.add_36pt
        img_updatePhoto.frame = CGRect(x: img_photo.frame.origin.x + img_photo.frame.width/2 - 14, y: img_photo.frame.origin.y + img_photo.frame.height/2 - 14, width: 30, height: 30)
        img_updatePhoto.removeGestureRecognizer(delete_img)
        img_updatePhoto.addGestureRecognizer(upload_img)
        callUpdateImgService(isDelet: true)
    }
}
