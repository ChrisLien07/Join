//
//  GlobalData.swift
//  join
//
//  Created by 連亮涵 on 2020/5/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class GlobalData: NSObject {
    
    //true:正式 false:測試
    let WebSiteUrl: String = (false) ? "https://api.bc9in.com/" : "http://18.177.237.80/"
    var testPay: Int = (false) ? 0 : 1
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    let UserLoginUrl: String = "userlogin"
    let CheckPhoneUrl: String = "checkphone"
    let GetFolderNameUrl: String = "getfoldername"
    let SignUpUserUrl: String = "signupuser"
    let SearchPartyUrl: String = "searchParty"
    let QueryHpListUrl: String = "queryHpList_Ios"
    //測試。首頁有想認識。let QueryHpListUrl: String = "queryHpList"
    let OpenHpItemUrl: String = "openHpItem"
    let GetPostListUrl: String = "getpostlist"
    let GetPartyListUrl: String = "getpartylist"
    let GetPartyComtUrl: String = "getPartyComt"
    let NewPComtfUrl: String = "newpcomtf"
    let NewPComtsUrl: String = "newpcomts"
    let GetGpListUrl: String = "getGpList"
    let SetGpUrl: String = "setGp"
    let NewPostUrl: String = "newpost"
    let CheckNewPostUrl: String = "checknewpost"
    let AccusePostUrl: String = "accusepost"
    let AccusePartyUrl: String = "accuseparty"
    let NewPtComtFUrl: String = "newptcomtf"
    let NewPtComtSUrl: String = "newptcomts"
    let GetPartyUrl: String = "getparty"
    let QueryVipPaymentUrl_lv2: String = "queryvippayment_lv2"
    let ApplyPartyUrl: String = "applyparty"
    let CancelPartyUrl: String = "cancelparty"
    let CheckNewPartyUrl: String = "checknewparty"
    let NewPartyUrl: String = "newparty"
    let GetAttendanceListUrl: String = "getAttendanceList"
    let DeletePartyUrl:String = "deleteparty"
    let UpdatePartyUrl:String = "updateparty"
    let GetUnreviewedListUrl: String = "getUnreviewedList"
    let AuditParticipantUrl: String = "auditParticipant"
    let CancelParticipantUrl: String = "cancelParticipant"
    let RegretPartyUrl: String = "regretparty"
    let QueryUser_MyPageUrl:String = "queryuser_mypage"
    let UpdateImgUrl: String = "updateimg"
    let GetPhoneUrl: String = "getphone"
    let UpdateUserUrl: String = "updateuser"
    let AccuseUserUrl: String = "accuseuser"
    let FollowUserUrl:String = "followuser"
    let UnfollowUserUrl: String = "unfollowuser"
    let DeletePostUrl: String = "deletepost"
    let GetFollowerListUrl: String = "getfollowerlist"
    let GetFollowListUrl: String = "getfollowlist"
    let QueryLikeMeUrl: String = "querylikeme"
    let GetPhotoUrl: String = "getphoto"
    let GetDvipOrderNoUrl: String = "getDvipOrderNo"
    let iosPayUrl: String = "iosPay"
    let LikeFunUrl: String = "likefun"
    let SuperLikeUrl: String = "superlike"
    let BlockUserUrl: String = "blockuser"
    let BlockPostUrl: String = "blockpost"
    let CheckBackUsedUrl: String = "checkbackused"
    let QueryFriendListUrl: String = "queryfriendlist"
    let SendMsgUrl:String = "sendmsg"
    let IosPayReductionUrl: String = "iosPayReduction"
    let OpenChatUrl: String = "openchat"
    let GetNotifyListUrl:String = "getnotifylist"
    let ReadNotifyUrl: String = "readnotify"
    let AllowJoinPartyUrl = "allowJoinParty"
    let ForbidJoinPartyUrl = "forbidJoinParty"
    let ReadAllNotifyUrl = "readallnotify"
    let GetBlockListUrl = "getblocklist"
    let UnblockUserUrl = "unblockuser"
    let GetNotifyCountUrl = "getNotifyCount"
    let UpdatepostUrl = "updatepost"
    let GetReviewUrl = "getReview"
    let ReviewUserUrl = "reviewUser"
    let OpenDMChatUrl = "openDMChat"
    let LogSaveUrl = "logSave"
    let CheckUserAttendanceUrl = "checkUserAttendance"
    let SendImgUrl = "sendimg"
    let GetAnnouncementListUrl = "getAnnouncementList"
    let Checkisviplv2Url = "checkisviplv2"
    let SearchPostUrl = "searchPost"
    let GetChatroomCreateTimeUrl = "getChatroomCreateTime"
    //續訂內容
    var transaction_id = ""
    var item_id = ""
    var last_productId = ""
    
    //登入用
    var loginReady: Bool = false
    var fcmReady:Bool = false
    //個人資料
    var token: String = ""
    var firebaseUid: String = ""
    var fcmToken: String = ""
    var age: String = ""
    var shortid: String = ""
    var uid: String = ""
    var username: String = ""
    var gender: String = ""
    var birthday: String = ""
    //個人圖片1~6
    var user_img: String = ""
    var img_url2: String = ""
    var img_url3: String = ""
    var img_url4: String = ""
    var img_url5: String = ""
    var img_url6: String = ""
    var location: String = ""
    var location_name: String = ""
    var constellation: String = ""
    var bloodtype: String = ""
    var job: String = ""
    var relationship: String = ""
    var max_age: String = ""
    var min_age: String = ""
    var personality: String = ""
    var interest: String = ""
    var suspension: String = ""
    var phonenum: String = ""
    var isShowMsgNotify: String = ""
    var isVip: String = ""  //是“Y”   否“N”
    var location_rq_combine_array: [Combine] = [Combine]()
    var location_rq_array: [String] = []
    var email: String = ""
    var folderName: String = ""
    //isxx
    var isUnlock_back: String = ""
    var isUnlock_superlike: String = ""
    //tmp
    var serverPhonenum: String = ""
    var img_url: String = ""
    var tmpCity = ""
    var tmpAdress:String = ""
    var tmpLocation: Combine = Combine()
    var tmpConstellation: Combine = Combine()
    var tmpInterest: Combine = Combine()
    var tmpJob: Combine = Combine()
    var tmpBloodtype: Combine = Combine()
    var tmpPersonality: Combine = Combine()
    var tmpRelationship: Combine = Combine()
    var tmpBirthday: String = ""
    var tmpName: String = ""
    var tmpUserInfo: String = ""
    //推播相關
    var isRunninginBackground = true
    var callapi = ""
    var jasonMemo = JsonMemo()
    //
    var commentCost : Int = 50
    let postCost: Int = 50
    //長寬
    var coverHeight: CGFloat = 0
    var imgHeight : CGFloat = 0
    //
    let domestic_txt_array = ["基隆市","台北市","新北市","桃園市","新竹市","新竹縣","苗栗縣","台中市","彰化縣","南投縣","雲林縣","嘉義市","嘉義縣","台南市","高雄市","屏東縣","台東縣","花蓮縣","宜蘭縣","澎湖縣","金門縣","連江縣"]
    let domestic_id_array = ["001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022"]
    let abroad_txt_array = ["大陸","港澳","星馬","美加","紐奧","其他"]
    let abroad_id_array = ["024","025","026","027","028","029"]
    let attendance_array = ["請選擇","雙人約會","3人","4人","5人","6人","7人","8人","9人","10人"]
    let attendance_id_array = ["","001","002","003","004","005","006","007","008","009"]
    let budget_type_array = ["請選擇","免費","各付各的","平均分攤","我付","你請"]
    let budget_type_id_array = ["","001","002","003","004","005"]
    let budget_array = ["請選擇","NT 0","NT 300以下","NT 300-500","NT 500-1000","NT 1000-2000","NT 2000-5000","NT 5000以上"]
    let budget_id_array = ["","001","002","003","004","005","006","007"]
    
    let unwantedWordArray = ["加賴","line","LINE","Line","wechat","WeChat","Wechat","weChat","TG","Tg","tg","紙飛機"]
    //
    let serviceUrl_privacyUrl = "https://www.bc9in.com/web/privacy.html"
    //
    let interest_pic_array : [UIImage] = [ UIImage(named: "interest_01")!, UIImage(named: "interest_02")!, UIImage(named: "interest_03")!, UIImage(named: "interest_04")!, UIImage(named: "interest_05")!, UIImage(named: "interest_06")!, UIImage(named: "interest_07")!,UIImage(named: "interest_08")!, UIImage(named: "interest_09")!, UIImage(named: "interest_10")!, UIImage(named: "interest_11")!, UIImage(named: "interest_12")!]
    
    let constellation_pic_array : [UIImage] = [ UIImage(named: "star_head_01")!, UIImage(named: "star_head_02")!, UIImage(named: "star_head_03")!, UIImage(named: "star_head_04")!, UIImage(named: "star_head_05")!, UIImage(named: "star_head_06")!, UIImage(named: "star_head_07")!,UIImage(named: "star_head_08")!, UIImage(named: "star_head_09")!, UIImage(named: "star_head_10")!, UIImage(named: "star_head_11")!, UIImage(named: "star_head_12")!]
    
    let manVipPicArray : [UIImage] = [UIImage(named: "VipPic1.jpg")!, UIImage(named: "VipPic2.jpg")!, UIImage(named: "VipPic3.jpg")!, UIImage(named: "VipPic4.jpg")!, UIImage(named: "VipPic5.jpg")!, UIImage(named: "VipPic6.jpg")!, UIImage(named: "VipPic7.jpg")!,UIImage(named: "VipPic8.jpg")!]
    
    let womanVipPicArray : [UIImage] = [UIImage(named: "VipPic1.jpg")!, UIImage(named: "VipPic3.jpg")!, UIImage(named: "VipPic4.jpg")!, UIImage(named: "VipPic5.jpg")!, UIImage(named: "VipPic6.jpg")!, UIImage(named: "VipPic7.jpg")!]
    
    let loadingColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    static var instance: GlobalData = GlobalData()
    class func getInstance() -> GlobalData
    {
        return instance
    }
    
}
let globalData = GlobalData.getInstance()


