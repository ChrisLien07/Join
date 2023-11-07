//
//  FriendHomePageVC.swift
//  join
//
//  Created by ChrisLien on 2020/12/21.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Koloda
import pop
import SwiftyStoreKit

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0

class FriendHomePageVC: UIViewController, KolodaViewDelegate, KolodaViewDataSource, Fri_Delegate {
    
    let v_top = UIView()
    let v_koloda = CustomKolodaView()
    let btn_like = SocialButton()
    let btn_dislike = SocialButton()
    let btn_reverse = SocialButton()
    let btn_superlike = SocialButton()
    let btn_likenum = UIButton()
    
    lazy var v_noList = UIView ()
    lazy var img_noList = UIImageView()
    lazy var activityIndicater = MyActivityIndicatorView()

    var friendArray:[Friend] = []
    var matchInfo: MatchInfo = MatchInfo()
    var imgArray:[String] = []

    var uid = ""
    var dislikeUid = ""
    var isBackEnable = ""
    var like_or_dislike = ""
    var from = ""
    var isSuperLike = false
    var receipt = ""

    var kolodaWidth: CGFloat = 0
    var kolodaHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        //
        NotificationCenter.default.addObserver(self, selector: #selector(getRenList), name: NSNotification.Name(rawValue: "getRenList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(superLike), name: Notifications.superlike, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rightButtonTapped), name: Notifications.like, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftButtonTapped), name: Notifications.dislike, object: nil)
        //
        v_koloda.delegate = self
        v_koloda.dataSource = self
        v_koloda.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        v_koloda.countOfVisibleCards = kolodaCountOfVisibleCards
        v_koloda.animator = BackgroundKolodaAnimator(koloda: v_koloda)
        //
        setupAnchor()
        configureBtns()
        configure_btn_likenum()
        //
        view.addSubview(activityIndicater)
        activityIndicater.center = view.center
        //
        if globalData.isUnlock_back == "1" {
            btn_reverse.isHidden = false
        }
        if globalData.isUnlock_superlike == "1" {
            btn_superlike.isHidden = false
        }
        //
        kolodaWidth = view.frame.width - 30
        kolodaHeight = view.frame.height/1.8
        //
        callGetListService(refresh: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryLikeMe()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "match"){
            let displayVC = segue.destination as! MatchVC
            displayVC.matchInfo = self.matchInfo
            displayVC.delegate = self
        }
        else if (segue.identifier == "unlockSuperLike"){
            let displayVC = segue.destination as! UnlockVC
            displayVC.isSuperLike = true
        }
    }
    
    func doSomethingWith(username: String, img_url: String, uid: String, shortid: String, chtid: String) {
        self.presentedViewController?.dismiss(animated: true, completion: .none)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomVC") as! ChatroomVC
        vc.username = username
        vc.img_url = img_url
        vc.friend_uid = uid
        vc.chtid = chtid
        vc.friend_shortid = shortid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupAnchor() {
        [v_top,v_koloda, btn_like, btn_dislike, btn_reverse, btn_superlike].forEach { view.addSubview($0) }
        v_top.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: view.frame.width, height: 44))
        v_koloda.anchor(top: v_top.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 15, bottom: 0, right: 0), size: CGSize(width: view.frame.width - 30, height: view.frame.height / 1.8))
        btn_reverse.anchor(top: v_koloda.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: 37, bottom: 0, right: 0),size: CGSize(width: 50, height: 50))
        btn_dislike.anchor(top: v_koloda.bottomAnchor, leading: btn_reverse.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: (view.frame.width - 280)/3, bottom: 0, right: 0),size: CGSize(width: 60, height: 60))
        btn_like.anchor(top: v_koloda.bottomAnchor, leading: btn_dislike.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: (view.frame.width - 280)/3, bottom: 0, right: 0),size: CGSize(width: 60, height: 60))
        btn_superlike.anchor(top: v_koloda.bottomAnchor, leading: btn_like.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: (view.frame.width - 280)/3, bottom: 0, right: 0),size: CGSize(width: 50, height: 50))
    }
    
    func configure_btn_likenum() {
        v_top.addSubview(btn_likenum)
        btn_likenum.isHidden = true
        btn_likenum.addTarget(self, action: #selector(goList), for: .touchUpInside)
        btn_likenum.titleLabel?.font = .systemFont(ofSize: 16)
        btn_likenum.setTitleColor(Colors.themePurple, for: .normal)
        btn_likenum.setImage(UIImage(named: "heart-solid-23pt × 20pt"), for: .normal)
        btn_likenum.anchor(top: v_top.topAnchor, leading: v_top.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 15, left: 15, bottom: 0, right: 0), size: CGSize(width: 170, height: 30))
    }
    
    func configureBtns() {
        btn_reverse.setImage(UIImage(named: "redo-alt-solid-23pt × 23pt"), for: .normal)
        btn_reverse.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        btn_reverse.layer.cornerRadius = 25
        btn_dislike.setImage(UIImage(named: "times-solid-28pt × 28pt"), for: .normal)
        btn_dislike.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        btn_dislike.layer.cornerRadius = 30
        btn_like.setImage(UIImage(named: "heart-solid-30pt × 27pt"), for: .normal)
        btn_like.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        btn_like.layer.cornerRadius = 30
        btn_superlike.setImage(UIImage(named: "star-solid-25pt × 24pt"), for: .normal)
        btn_superlike.addTarget(self, action: #selector(superLike), for: .touchUpInside)
        btn_superlike.layer.cornerRadius = 25
    }
    
    //取得喜歡我人數
    func queryLikeMe() {
        NetworkManager.shared.callQueryLikeMEService { [self] (code, num, msg) in
            switch code {
            case 0:
                btn_likenum.isHidden = false
                btn_likenum.setTitle("  \(num!)位表示喜歡你", for: .normal)
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 127:
                btn_likenum.isHidden = true
            default:
                ShowErrMsg(code: code,msg: msg!,vc: self)
            }
        }
    }
    
    func callGetListService(refresh:Bool) //取得用戶卡片
    {
        let request = createHttpRequest(Url: globalData.GetPhotoUrl, HttpType: "POST", Data: "token=\(globalData.token)")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                DispatchQueue.main.async {
                    if refresh {
                        dismissAlert(selfVC: self)
                    }
                }
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        //匯入貼文資料
                        self.friendArray.removeAll()
                        for fri in responseJSON["list"] as! [[String: Any]]
                        {
                            let tmpFri = Friend()
                            parseFriend(friend: tmpFri, fri: fri)
                            tmpFri.imgArray = (fri["img_url"] as! String).components(separatedBy: ",")
                            self.friendArray.append(tmpFri)
                        }
                        //匯入貼文資料
                        self.v_koloda.resetCurrentCardIndex()
                        
                        if refresh {
                            dismissAlert(selfVC: self)
                        }
                        
                        if responseJSON["hasMatchData"] as! String == "N" {
                            Alert.basicAlert(vc: self, title: nil, message: "抱歉，暫時找不到符合年齡、地區條件的對象!")
                        }
                    }
                    else if responseJSON["code"] as! Int == 124
                    {
                        self.v_noList.frame = CGRect(x: self.v_koloda.frame.origin.x, y: self.v_koloda.frame.origin.y, width: self.v_koloda.frame.width, height: self.v_koloda.frame.height + 100)
                        self.v_noList.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
                        self.view.addSubview(self.v_noList)
                        
                        self.img_noList.frame = CGRect(x: 0, y: 0, width: self.v_koloda.frame.width, height: self.v_koloda.frame.height)
                        self.img_noList.image = UIImage(named: "noMatch.jpg")
                        self.v_noList.addSubview(self.img_noList)
                        
                        if refresh {
                            dismissAlert(selfVC: self)
                        }
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
   
    func callLikeFunService(like: String, unlike: String) //喜歡不喜歡
    {
        let request = createHttpRequest(Url: globalData.LikeFunUrl, HttpType: "POST", Data: "token=\(globalData.token)&like=\(like)&unlike=\(unlike)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        let match = responseJSON["list"] as! [[String: Any]]
                        if match.count != 0 {
                            let tmpInfo = MatchInfo()
                            parseMatchInfo(matchInfo: tmpInfo, match: match[0])
                            self.matchInfo = tmpInfo
                            self.performSegue(withIdentifier: "match", sender: nil)
                        }
                        
                        let unlock_back = responseJSON["unlock_back"] as! String
                        if unlock_back == "1" && globalData.isUnlock_back == "0" {
                            self.btn_reverse.isHidden = false
                            globalData.isUnlock_back = "1"
                            self.performSegue(withIdentifier: "unlockReverse", sender: nil)
                        }
                        
                        let unlock_superlike = responseJSON["unlock_superlike"] as! String
                        if unlock_superlike == "1" && globalData.isUnlock_superlike == "0" {
                            self.btn_superlike.isHidden = false
                            globalData.isUnlock_superlike = "1"
                            self.performSegue(withIdentifier: "unlockSuperLike", sender: nil)
                        }
                    }
                    else if responseJSON["code"] as! Int == 125
                    {
                        let alertController = UIAlertController(title: "喜歡無限制", message: "一般會員每日可選20位心儀的對象，升級鑽石VIP盡情滑喜歡不限次數。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "升級VIP", style: .default){(UIAlertAction) in
                            self.v_koloda.revertAction()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
                            vc.from = "喜歡"
                            self.present(vc,animated: true)
                        }
                        alertController.addAction(okAction)
                        let cancelAction = UIAlertAction(title:"取消",style: .cancel){(UIAlertAction) in
                            self.v_koloda.revertAction()
                        }
                        alertController.addAction(cancelAction)
                        //顯示提示框
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if responseJSON["code"] as! Int == 100125 {
                        self.checkSuscription()
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.findViewController()?.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func callSuperLikeService(superLike: String) {
        let request = createHttpRequest(Url: globalData.SuperLikeUrl, HttpType: "POST", Data: "token=\(globalData.token)&superlike=\(superLike)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async
                {
                    if responseJSON["code"] as! Int == 0
                    {
                        let match = responseJSON["list"] as! [[String: Any]]
                        if match.count != 0 {
                            let tmpInfo = MatchInfo()
                            parseMatchInfo(matchInfo: tmpInfo, match: match[0])
                            self.matchInfo = tmpInfo
                            self.performSegue(withIdentifier: "match", sender: nil)
                        }
                    }
                    else if responseJSON["code"] as! Int == 123
                    {
                        if globalData.isVip == "Y" {
                            shortInfoMsg(msg: "VIP超級喜歡次數已達上限", vc: self, sec: 2) {
                                self.v_koloda.revertAction()
                            }
                        } else if globalData.isVip == "N" {
                            let alertController = UIAlertController(title: "補充超級喜歡", message: "升級鑽石VIP，每日補充5個超級喜歡，讓你脫穎而出，引起對方的注意。", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "升級VIP", style: .default){(UIAlertAction) in
                                self.v_koloda.revertAction()
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
                                vc.from = "超級喜歡"
                                self.present(vc,animated: true)
                            }
                            alertController.addAction(okAction)
                            let cancelAction = UIAlertAction(title:"取消",style: .cancel){(UIAlertAction) in
                                self.v_koloda.revertAction()
                            }
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    else if responseJSON["code"] as! Int == 100123 {
                        self.checkSuscription()
                    }
                    else if responseJSON["code"] as! Int == 128
                    {
                        let msg = responseJSON["msg"] as! String
                        let reason = responseJSON["reason"] as! String
                        let vc = self.findViewController()?.storyboard?.instantiateViewController(withIdentifier: "PermanentBanVC") as! PermanentBanVC
                        vc.reason = msg + reason
                        self.findViewController()?.present(vc, animated: true, completion: nil)
                    }
                    else
                    {
                        ShowErrMsg(code: responseJSON["code"] as! Int,msg: responseJSON["msg"] as! String,vc: self)
                    }
                }
            }
        }
        task.resume()
    }
    
    func callCheckBackUsedService(uid: String)
    {
        let request = createHttpRequest(Url: globalData.CheckBackUsedUrl, HttpType: "POST", Data: "token=\(globalData.token)&uid=\(uid)&source=\("ios")")
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else
            {
                Alert.ShowConnectErrMsg(vc: self)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any]
            {
                DispatchQueue.main.async {
                    if responseJSON["code"] as! Int == 0
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.v_koloda.revertAction()
                        }
                        self.btn_reverse.isEnabled = false
                    }
                    else if responseJSON["code"] as! Int == 100126 {
                        self.checkSuscription()
                    }
                    else if responseJSON["code"] as! Int == 126
                    {
                        let alertController = UIAlertController(title: "恢復錯過的對象", message: "我其實是要往右滑...\n升級鑽石VIP無限返回，倒帶至上一個錯過的對象。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "確定", style: .default){(UIAlertAction) in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Bu") as! BuyVipVC
                            vc.from = "返回"
                            self.present(vc, animated: true)
                        }
                        alertController.addAction(okAction)
                        let cancelAction = UIAlertAction(title:"取消",style: .cancel)
                        alertController.addAction(cancelAction)
                        //顯示提示框
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkSuscription() {
        activityIndicater.active()
        NetworkManager.shared.checkIfPurchased { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let receipt):
                self.receipt = receipt
                self.getDvipOrderNo()
            case .failure(let error):
                self.activityIndicater.inactive()
                print(error)
            }
        }
    }
    
    func getDvipOrderNo() {
        NetworkManager.shared.callGetDvipOrderNoService { (code, orderNo, msg) in
            switch code {
            case 0:
                NetworkManager.shared.calliosPayService(orderNo: orderNo!, receipt: self.receipt) { (code, msg) in
                    self.activityIndicater.inactive()
                    print(code)
                }
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
                self.activityIndicater.inactive()
            default:
                ShowErrMsg(code: code, msg: msg!, vc: self)
                self.activityIndicater.inactive()
            }
        }
    }
    
    @objc func getRenList() {
        callGetListService(refresh: false)
    }
    
    @objc func goList() {
        NetworkManager.shared.callCheckisvip { (code, isvip) in
            switch code {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LikeMeListVC") as! LikeMeListVC
                vc.isVip = isvip!
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                Alert.ShowConnectErrMsg(vc: self)
            }
        }
    }
    
    // MARK: - @IBAction
    @objc func superLike() {
        self.isSuperLike = true
        self.like_or_dislike = "like"
        self.btn_reverse.isEnabled = true
        v_koloda.swipe(.right)
    }
    
    @objc func leftButtonTapped() {
        self.like_or_dislike = "dislike"
        self.btn_reverse.isEnabled = true
        v_koloda.swipe(.left)
    }
    
    @objc func rightButtonTapped() {
        self.isSuperLike = false
        self.like_or_dislike = "like"
        self.btn_reverse.isEnabled = true
        v_koloda.swipe(.right)
    }
    
    @objc func undoButtonTapped() {
        
        if self.like_or_dislike == "like" {
            shortInfoMsg(msg: "只能退回至上一個「不喜歡」的人", vc: self, sec: 2)
        } else if self.like_or_dislike == "dislike" {
            callCheckBackUsedService(uid: dislikeUid)
        }
    }
    // MARK: - KolodaView設定
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let alert = GetLoadingView(msg: "請稍候...")
        present(alert, animated: true, completion: nil)
        callGetListService(refresh: true)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .left || direction == .bottomLeft
        {
            self.like_or_dislike = "dislike"
            self.btn_reverse.isEnabled = true
            callLikeFunService(like: "", unlike: friendArray[index].uid)
            dislikeUid = friendArray[index].uid
        }
        else if direction == .right || direction == .bottomRight
        {
            if isSuperLike {
                callSuperLikeService(superLike: friendArray[index].uid)
            } else {
                self.isSuperLike = false
                self.like_or_dislike = "like"
                self.btn_reverse.isEnabled = true
                callLikeFunService(like: friendArray[index].uid, unlike: "")
            }
        }
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left , .right , .bottomLeft , .bottomRight]
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.5
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return friendArray.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let v_profile = SwipeProfileView()
        let img_array = friendArray[index].imgArray
        var imgs: [String] = []
        for img in img_array { if img != "" {imgs.append(img)}}
         
        v_profile.init_profile(imgs: imgs,username: friendArray[index].username, age: String(friendArray[index].age), uid: friendArray[index].uid, location: friendArray[index].location_name, constellation: friendArray[index].constellation_name, interests: friendArray[index].interest_name , width: kolodaWidth, height: kolodaHeight)
        return v_profile
    }
}
