//
//  PostVC.swift
//  join
//
//  Created by 連亮涵 on 2020/6/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import UIKit
import TLPhotoPicker
import Firebase
import FirebaseStorage
import Agrume
import MobileCoreServices
import Photos
import PhotosUI
import MobileCoreServices

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,TLPhotosPickerViewControllerDelegate  {
    
    @IBOutlet weak var sv_main: UIScrollView!
    @IBOutlet weak var v_user: UIView!
    @IBOutlet weak var img_userIcon: UIImageView!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var txt_postText: UITextView!
    @IBOutlet weak var sv_image: UIScrollView!
    @IBOutlet weak var v_bottons: UIView!
    @IBOutlet weak var btn_back: UIBarButtonItem!
    @IBOutlet weak var btn_submit: UIBarButtonItem!

    let imgPicker = UIImagePickerController()
    var TLimgPicker = TLPhotosPickerViewController()
    var TLvideoPicker = TLPhotosPickerViewController()
    var TLConfig = TLPhotosPickerConfigure()
    
    var postTextHeight: CGFloat!
    var originMainHeight: CGFloat = 0
    var keyBoardHeight: CGFloat = 0
    
    var isVideo = false
    var isupdate = false
    var videoExporting = 0
    var imgPath : [String] = []
    var fullPost =  Post()
    var imageCount = 0
    var pid = ""
    var uid = ""
    var placehoalderText = "發文附圖是禮貌噢！請至少上傳一張圖片或影片（上限三張），文字上限五千字。"

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        self.view.addGestureRecognizer(tap)
        setDelegates()
        configureTLPicker()
        configureTextView()
        configureUserInfo()
        checkisupdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        originMainHeight = sv_main.frame.size.height
    }
    
    func setDelegates() {
        sv_main.delegate = self
        imgPicker.delegate = self
        TLimgPicker.delegate = self
        TLvideoPicker.delegate = self
        txt_postText.delegate = self
    }
    
    func configureTLPicker() {
        TLConfig.usedCameraButton = false
        TLConfig.maxSelectedAssets = 3
        TLConfig.doneTitle = "確認"
        TLConfig.cancelTitle = "取消"
    }
    
    func configureUserInfo() {
        img_userIcon.layer.cornerRadius = img_userIcon.frame.width/2
        img_userIcon.contentMode = .scaleAspectFill
        DownloadImage(view: img_userIcon, img: globalData.user_img, id: "uid:" + uid, placeholder: UIImage(named: "user.png"))
        lbl_username.text = globalData.username
    }
    
    func configureTextView() {
        txt_postText.text = placehoalderText
        txt_postText.textColor = UIColor.black.withAlphaComponent(0.4)
        postTextHeight = txt_postText.frame.height
    }
    
    func checkisupdate()
    {
        if !isupdate {
            (self.findTabBarController() as! MainTabBar).tabBar.isHidden = true
        } else {
            self.title = "修改貼文"
            txt_postText.text = fullPost.text
            txt_postText.textColor = UIColor.black.withAlphaComponent(0.75)
            let imgs:[String] = fullPost.img_url.components(separatedBy: ",")
            for img in imgs {
                if img.contains("/Video") {
                    var img_video = img.replacingOccurrences(of: "/Video", with: "/Image")
                    img_video = img_video.replacingOccurrences(of: "mp4", with: "jpg")
                    let imgUrl = URL(string: img_video)
                    let data = try? Data(contentsOf: imgUrl!)
                    let downloadedImg = UIImage(data: data!)
                    let imgView = ImageCellView().initwithImage(img: downloadedImg!, isVideo: true)
                    self.sv_image.addSubview(imgView)
                    self.setSvImageLayout()
                    imgView.url = URL(string: img)
                    imgView.imgView.alpha = 1
                    imgView.loadingIndicator.stopAnimating()
                } else {
                    let imgUrl = URL(string: img)
                    let data = try? Data(contentsOf: imgUrl!)
                    let downloadedImg = UIImage(data: data!)
                    let imgView = ImageCellView().initwithImage(img: downloadedImg!, isVideo: false)
                    sv_image.addSubview(imgView)
                    setSvImageLayout()
                }
            }
        }
    }
    
    func setSvImageLayout() {
        imageCount = 0
        for cell in sv_image.subviews {
            cell.frame.origin = CGPoint(x: imageCount * 85,y: 0)
            imageCount += 1
        }
        sv_image.contentSize.width = CGFloat(imageCount * 85)
    }
    
    func uploadImgs() {
        var count = 0
        var fileName: String
        var imgPaths: [String] = []
        let DateStr = getTPETime(format: "yyyyMMdd")
        let DateTimeStr = getTPETime(format: "yyyyMMddHHmmss")
            
        for subview in sv_image.subviews
        {
            if let imgview = subview as? ImageCellView
            {
                fileName = globalData.token + DateTimeStr + String(count)
                count += 1
                if imgview.isVideo
                {
                    if !imgview.url.absoluteString.contains("firebasestorage")
                    {
                        let storageRef = Storage.storage().reference().child("Video").child(DateStr).child("\(fileName).mp4")
                        if let videoURL = imgview.url as URL? {
                            let metaData = StorageMetadata()
                            metaData.contentType = "video/mp4"
                            storageRef.putFile(from: videoURL as URL, metadata: metaData) { (metadata, error) in
                                guard let metadata = metadata else {
                                    // Uh-oh, an error occurred!
                                    dismissAlert(selfVC: self)
                                    {ShowErrMsg(code: 0, msg: "影片上傳失敗:\(error!)", vc: self)}
                                    return
                                }
                                // Metadata contains file metadata such as size, content-type.
                                _ = metadata.size
                                storageRef.downloadURL() { url, error in
                                guard let url = url, error == nil else {
                                    ShowErrMsg(code: 0,msg: "圖片上傳失敗",vc: self)
                                    return
                                }
                                    let endIndex = url.absoluteString.range(of: "&token=")?.lowerBound ?? url.absoluteString.endIndex
                                    let img_url  = String(url.absoluteString[ ..<endIndex])
                                    imgPaths.append(img_url)
                                    if imgPaths.count == self.sv_image.subviews.count
                                    {
                                        imgPaths.sort { $0.suffix(29) < $1.suffix(29) }
                                        self.callUpFilesService(imgPaths: imgPaths,poType: 0)
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        let img_url = String(imgview.url.absoluteString)
                        imgPaths.append(img_url)
                        if imgPaths.count == self.sv_image.subviews.count
                        {
                            imgPaths.sort { $0.suffix(29) < $1.suffix(29) }
                            self.callUpFilesService(imgPaths: imgPaths,poType: 0)
                        }
                    }
                    let imgStorageRef = Storage.storage().reference().child("Image").child(DateStr).child("\(fileName).jpg")
                    if let uploadData = imgview.fullImage.jpegData(compressionQuality: 0.8) {
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpeg"
                        // 這行就是 FirebaseStorage 關鍵的存取方法。
                        imgStorageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                            guard let _ = metadata else {
                                // Uh-oh, an error occurred!
                                //關閉發文提示
                                dismissAlert(selfVC: self)
                                return
                            }
                        }
                    }
                }
                else
                {
                    let storageRef = Storage.storage().reference().child("Image/" + DateStr).child("\(fileName).jpg")
                    if let uploadData = imgview.fullImage.jpegData(compressionQuality: 0.8) {
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpeg"
                        // 這行就是 FirebaseStorage 關鍵的存取方法。
                        _ = storageRef.putData(uploadData, metadata: metaData) { (metadata, error) in
                            guard let metadata = metadata else {
                                // Uh-oh, an error occurred!
                                //關閉發文提示
                                dismissAlert(selfVC: self)
                                return
                            }
                            // Metadata contains file metadata such as size, content-type.
                            _ = metadata.size
                            storageRef.downloadURL() { url, error in
                            guard let url = url, error == nil else
                            {
                                ShowErrMsg(code: 0,msg: "圖片上傳失敗",vc: self)
                                return
                            }
                            let endIndex = url.absoluteString.range(of: "&token=")?.lowerBound ?? url.absoluteString.endIndex
                            let img_url  = String(url.absoluteString[ ..<endIndex])
                            imgPaths.append(img_url)
                            if imgPaths.count == self.sv_image.subviews.count
                            {
                                imgPaths.sort { $0.suffix(29) < $1.suffix(29) }
                                self.callUpFilesService(imgPaths: imgPaths,poType: 0)
                            }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func callUpFilesService(imgPaths: [String],poType: Int)
    {
        let imgPath = imgPaths.joined(separator:",")
        var url = ""
        var data = ""
        if isupdate {
            url  = globalData.UpdatepostUrl
            data = "token=\(globalData.token)&pid=\(self.pid)&text=\(txt_postText.text!)&img_url=\(imgPath)"
        } else {
            url  = globalData.NewPostUrl
            data = "token=\(globalData.token)&text=\(txt_postText.text!)&img_url=\(imgPath)"
        }
        let request = createHttpRequest(Url: url, HttpType: "POST", Data: data)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                DispatchQueue.main.async {
                    dismissAlert(selfVC: self)
                }
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    //關閉發文提示
                    dismissAlert(selfVC: self)
                    {
                        if responseJSON["code"] as! Int == 0
                        {
                            var txt = ""
                            if self.isupdate {
                                txt = "文章修改成功"
                            } else {
                                txt = "文章發送成功"
                            }
                            shortInfoMsg(msg: txt, vc: self, sec: 2) {
                                (self.findViewController() as? Pi_FullPostVC)?.refresh()
                                self.txt_postText.text = ""
                                self.textViewDidEndEditing(self.txt_postText)
                                for imgView in self.sv_image.subviews {imgView.removeFromSuperview()}
                                self.imageCount = 0
                                self.back(0)
                            }
                        }
                        else if responseJSON["code"] as! Int == 129
                        {
                            Alert.maxPostAlert(vc: self)
                        }
                        else if responseJSON["code"] as! Int == 128
                        {
                            let msg = responseJSON["msg"] as! String
                            let reason = responseJSON["reason"] as! String
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                            vc.reason = msg + reason
                            self.present(vc, animated: true, completion: nil)
                        }
                        else
                        {
                            ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK: -TextVIew
    func textViewDidChange(_ textView: UITextView) {
        if (textView.contentSize.height > postTextHeight || textView.frame.height > postTextHeight) {
            //字文字超出邊界時加大高度
            textView.frame.size = textView.contentSize
            textView.scrollRangeToVisible(NSMakeRange(0, 0))
            //調整下方View的位置
            sv_image.frame = CGRect(x: sv_image.frame.origin.x, y: txt_postText.frame.height + txt_postText.frame.origin.y + 5, width: sv_image.frame.width, height:sv_image.frame.height)
                v_bottons.frame = CGRect(x: v_bottons.frame.origin.x, y: sv_image.frame.height + sv_image.frame.origin.y + 5, width: v_bottons.frame.width, height:v_bottons.frame.height)
            sv_main.contentSize.height =  v_bottons.frame.origin.y + v_bottons.frame.height
            //若內容超出螢幕 調整視覺位置到最底
            if(sv_main.contentSize.height > sv_main.frame.height) {
                sv_main.setContentOffset(CGPoint(x: 0, y: sv_main.contentSize.height - sv_main.frame.height), animated: false)
            }
        }
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        //開始編輯後去除placeholder
        if textView.textColor == UIColor.black.withAlphaComponent(0.4) {
            textView.text = ""
            textView.textColor = UIColor.black.withAlphaComponent(0.75)
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        //結束編輯後依字數生成placeholder
        if !textView.hasText {
            textView.text = placehoalderText
            textView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    //MARK: - PickPhoto
    func photoPickerDidCancel() {
        // cancel
    }
        
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        if isVideo
        {
            for asset in TLvideoPicker.selectedAssets
            {
                videoExporting += 1
                let imgView = ImageCellView().initwithImage(img: getImg(asset: asset.phAsset!)!, isVideo: true)
                self.sv_image.addSubview(imgView)
                self.setSvImageLayout()
                asset.exportVideoFileMedium(outputFileType: .mp4, progressBlock: .none){ (url,mineType) in
                    imgView.setUrl(url: url)
                    self.videoExporting -= 1
                }
            }
        }
        else
        {
            for asset in TLimgPicker.selectedAssets
            {
                let imgView = ImageCellView().initwithImage(img: getImg(asset: asset.phAsset!)!, isVideo: false)
                sv_image.addSubview(imgView)
            }
            setSvImageLayout()
        }
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 取得照片
        let image = info[.originalImage] as! UIImage
        let imgView = ImageCellView().initwithImage(img: image,isVideo: false)
        sv_image.addSubview(imgView)
        imageCount += 1
        //取得照片後將imagePickercontroller dismiss
        picker.dismiss(animated: true, completion: nil)
        setSvImageLayout()
    }
    
    //MARK: - @IBAction
    @IBAction func submit(_ sender: Any) {
        txt_postText.resignFirstResponder()
        if videoExporting > 0 {
            shortInfoMsg(msg: "影片處理中 請稍候再試", vc: self, sec: 1)
            return
        }
        if (txt_postText.textColor == UIColor.black.withAlphaComponent(0.4) || txt_postText.text == "" || sv_image.subviews.count == 0) {
            shortInfoMsg(msg: "內容不足，請檢查圖片及文字", vc: self, sec: 2)
            return
        } else {
            let alert = GetLoadingView(msg: "文章送出中 請稍候...")
            present(alert, animated: true, completion: nil)
        }
        if sv_image.subviews.count > 0 {
            uploadImgs()
        } else {
            self.callUpFilesService(imgPaths:[] ,poType: 0)
        }
    }
    
    @IBAction func back(_ sender: Any)
    {
        //結束文字編輯
        txt_postText.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseCamera(_ sender: UIButton) {
        if imageCount < 3 {
            imgPicker.sourceType = .camera
            imgPicker.allowsEditing = true
            self.present(imgPicker, animated: true)
        } else {
            shortInfoMsg(msg: "圖片已到達上限", vc: self, sec: 2)
        }
    }
        
    @IBAction func choosePhoto(_ sender: UIButton) {
        if imageCount < 3 {
            isVideo = false
            TLimgPicker.configure = TLConfig
            TLimgPicker.configure.allowedVideo = false
            TLimgPicker.configure.maxSelectedAssets = 3 - imageCount
            TLimgPicker.selectedAssets.removeAll()
            self.present(TLimgPicker, animated: true, completion: nil)
            TLimgPicker.collectionView.reloadData()
        } else {
            shortInfoMsg(msg: "圖片已到達上限", vc: self, sec: 2)
        }
    }
        
    @IBAction func chooseVideo(_ sender: UIButton) {
        if imageCount < 3
        {
            isVideo = true
            TLvideoPicker.configure = TLConfig
            TLvideoPicker.configure.mediaType = .video
            TLvideoPicker.configure.maxSelectedAssets = 3 - imageCount
            TLvideoPicker.configure.maxVideoDuration = 60
            TLvideoPicker.selectedAssets.removeAll()
            self.present(TLvideoPicker, animated: true, completion: nil)
            TLvideoPicker.collectionView.reloadData()
        }
        else
        {
            shortInfoMsg(msg: "圖片已到達上限", vc: self, sec: 2)
        }
    }
    
    //MARK: - @Objc
    @objc func keyboardWillShow(notification: NSNotification)
    {
        guard let userInfo = (notification as Notification).userInfo, let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyBoardHeight = value.cgRectValue.height
        if sv_main.frame.size.height == originMainHeight {
            sv_main.frame.size.height = sv_main.frame.size.height - keyBoardHeight
        }
    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
        keyBoardHeight = 0
        if sv_main.frame.size.height != originMainHeight {
            sv_main.frame.size.height = originMainHeight
        }
    }
}

extension TLPHAsset{
    func exportVideoFileMedium(options: PHVideoRequestOptions? = nil,
                               outputURL: URL? = nil,
                               outputFileType: AVFileType = .mov,
                               progressBlock:((Double) -> Void)? = nil,
                               completionBlock:@escaping ((URL,String) -> Void)){
        guard let phAsset = self.phAsset,
            phAsset.mediaType == .video,
            let writeURL = outputURL ?? videoFilenameEx(phAsset: phAsset),
            let mimetype = MIMETypeEx(writeURL)
            else {
                return
            }
        var requestOptions = PHVideoRequestOptions()
        if let options = options {
            requestOptions = options
        }else {
            requestOptions.isNetworkAccessAllowed = true
        }
        requestOptions.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.async {
                progressBlock?(progress)
            }
        }
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: requestOptions) { (avasset, avaudioMix, infoDict) in
            guard let avasset = avasset else {
                return
            }
            let exportSession = AVAssetExportSession.init(asset: avasset, presetName: AVAssetExportPresetMediumQuality)
            exportSession?.outputURL = writeURL
            exportSession?.outputFileType = outputFileType
            exportSession?.exportAsynchronously(completionHandler: {
                completionBlock(writeURL, mimetype)
            })
        }
    }
    
    func MIMETypeEx(_ url: URL?) -> String? {
        guard let ext = url?.pathExtension else { return nil }
        if !ext.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag("public.filename-extension" as CFString, ext as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            UTIRef?.release()
            if let UTI = UTI {
                guard let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else { return nil }
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                return MIMEType as String
            }
        }
        return nil
    }
    
    func videoFilenameEx(phAsset: PHAsset) -> URL? {
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter{ $0.type == .video }).first else {
            return nil
        }
        var writeURL: URL?
        let fileName = resource.originalFilename
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        return writeURL
    }
}
