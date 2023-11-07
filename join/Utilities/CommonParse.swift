//
//  CommonParse.swift
//  join
//
//  Created by 連亮涵 on 2020/7/29.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Photos
import SDWebImage
import Firebase
import MapKit

func parseLoginInfo(_ info:[String:Any]) {
    globalData.token         = getJsonValueString(info, key: "token")
    globalData.shortid       = getJsonValueString(info, key: "shortuid")
    globalData.username      = getJsonValueString(info, key: "username")
    globalData.user_img      = getJsonValueString(info, key: "img_url")
    globalData.gender        = getJsonValueString(info, key: "gender")
    globalData.birthday      = getJsonValueString(info, key: "birthdate")
    globalData.age           = String(info["age"] as? Int ?? 0)
    globalData.location      = getJsonValueString(info, key: "location")
    globalData.constellation = getJsonValueString(info, key: "constellation")
    globalData.bloodtype     = getJsonValueString(info, key: "bloodtype")
    globalData.job           = getJsonValueString(info, key: "job")
    globalData.relationship  = getJsonValueString(info, key: "relationship")
    globalData.min_age       = String(info["min_age"] as? Int ?? 18)
    globalData.max_age       = String(info["max_age"] as? Int ?? 18)
    globalData.personality   = getJsonValueString(info, key: "personality")
    globalData.interest      = getJsonValueString(info, key: "interest")
    globalData.suspension    = getJsonValueString(info, key: "suspension")
    globalData.transaction_id = getJsonValueString(info, key: "ios_transaction_id")
    globalData.last_productId = getJsonValueString(info, key: "ios_product_id")
    globalData.item_id       = getJsonValueString(info, key: "ios_item_id")
    UserDefaults.standard.set(globalData.token, forKey: "Token")
}

func parseUserInfo(info:[String:Any]) {
    globalData.username           = getJsonValueString(info, key: "username")
    globalData.gender             = getJsonValueString(info, key: "gender")
    globalData.age                = String(info["age"] as? Int ?? 0)
    globalData.max_age            = getJsonValueString(info, key: "max_age")
    globalData.min_age            = getJsonValueString(info, key: "min_age")
    globalData.birthday           = getJsonValueString(info, key: "birthdate")
    globalData.user_img           = getJsonValueString(info, key: "img_url1")
    globalData.img_url2           = getJsonValueString(info, key: "img_url2")
    globalData.img_url3           = getJsonValueString(info, key: "img_url3")
    globalData.img_url4           = getJsonValueString(info, key: "img_url4")
    globalData.img_url5           = getJsonValueString(info, key: "img_url5")
    globalData.img_url6           = getJsonValueString(info, key: "img_url6")
    globalData.location           = getJsonValueString(info, key: "location")
    globalData.location_name      = getJsonValueString(info, key: "location_name")
    globalData.constellation      = getJsonValueString(info, key: "constellation")
    globalData.bloodtype          = getJsonValueString(info, key: "bloodtype")
    globalData.job                = getJsonValueString(info, key: "job")
    globalData.relationship       = getJsonValueString(info, key: "relationship")
    globalData.personality        = getJsonValueString(info, key: "personality")
    globalData.interest           = getJsonValueString(info, key: "interest")
    globalData.isShowMsgNotify      = getJsonValueString(info, key: "isShowMsgNotify")
    globalData.isVip              = getJsonValueString(info, key: "isvip")
    globalData.isUnlock_back      = getJsonValueString(info, key: "unlock_back")
    globalData.isUnlock_superlike = getJsonValueString(info, key: "unlock_superlike")
}

func parseProfile(profile: UserInfo, file:[String:Any]) {
    profile.username           = getJsonValueString(file, key: "username")
    profile.gender             = getJsonValueString(file, key: "gender")
    profile.age                = file["age"] as! Int
    profile.birthday           = getJsonValueString(file, key: "birthdate")
    profile.location_name      = getJsonValueString(file, key: "location_name")
    profile.constellation_id   = getJsonValueString(file, key: "constellation")
    profile.constellation_name = getJsonValueString(file, key: "constellation_name")
    profile.bloodtype          = getJsonValueString(file, key: "bloodtype")
    profile.job_name           = getJsonValueString(file, key: "job_name")
    profile.relationship_name  = getJsonValueString(file, key: "relationship_name")
    profile.personality_name   = getJsonValueString(file, key: "personality_name")
    profile.interest_name      = getJsonValueString(file, key: "interest_name")
    profile.user_info          = fixText(getJsonValueString(file, key: "user_info"))
    profile.img_url1           = getJsonValueString(file, key: "img_url1")
    profile.img_url2           = getJsonValueString(file, key: "img_url2")
    profile.img_url3           = getJsonValueString(file, key: "img_url3")
    profile.img_url4           = getJsonValueString(file, key: "img_url4")
    profile.img_url5           = getJsonValueString(file, key: "img_url5")
    profile.img_url6           = getJsonValueString(file, key: "img_url6")
    profile.isvip              = getJsonValueString(file, key: "isvip")
    profile.isfollowed         = getJsonValueString(file, key: "isfollowed")
    profile.party_cnt          = file["party_cnt"] as? String ?? "0"
    profile.like_cnt           = file["like_cnt"] as? String ?? "0"
    profile.follower_cnt       = file["follower_cnt"] as? String ?? "0"
    profile.follow_cnt         = file["follow_cnt"] as? String ?? "0"
    profile.isMyself           = file["isMyself"] as? Int ?? 0
    profile.avgStarRating      = file["avgStarRating"] as? String ?? "0"
    profile.reviewCount        = file["reviewCount"] as? String ?? "0"
}

func parsePosts(post: Post, po: [String:Any]) {
    post.username      = getJsonValueString(po, key: "username")
    post.datatype      = getJsonValueString(po, key: "datatype")
    post.img_url       = getJsonValueString(po, key: "img_url")
    post.user_img      = getJsonValueString(po, key: "user_img")
    post.pid           = getJsonValueString(po, key: "pid")
    post.text          = fixText(getJsonValueString(po, key: "text"))
    post.uid           = getJsonValueString(po, key: "uid")
    post.posttime      = getJsonValueString(po, key: "posttime")
    post.ptid          = getJsonValueString(po, key: "ptid")
    post.title         = fixText(getJsonValueString(po, key: "title"))
    post.comt_cnt      = getJsonValueString(po, key: "comt_cnt")
    post.address       = getJsonValueString(po, key: "address")
    post.isMyself      = getJsonValueString(po, key: "isMyself")
    post.starttime     = getJsonValueString(po, key: "starttime")
    post.gp            = getJsonValueString(po, key: "gp")
    post.budget_label  = getJsonValueString(po, key: "budget_label")
    if po["isGp"] != nil {
    if po["isGp"] as! String == "1" {post.isGd = true}}
}

func parseSearchs(search:Search, sear:[String:Any]) {
    search.ptid      = getJsonValueString(sear, key: "ptid")
    search.uid       = getJsonValueString(sear, key: "uid")
    search.img_url   = getJsonValueString(sear, key: "img_url")
    search.title     = fixText(getJsonValueString(sear, key: "title"))
    search.starttime = getJsonValueString(sear, key: "starttime")
    search.address   = getJsonValueString(sear, key: "address")
    search.isExpired = getJsonValueString(sear, key: "isExpired")
    
    search.user_img  = getJsonValueString(sear, key: "user_img")
    search.pid       = getJsonValueString(sear, key: "pid")
    search.gp        = getJsonValueString(sear, key: "gp")
    search.comt_cnt  = getJsonValueString(sear, key: "comt_cnt")
    search.text      = fixText(getJsonValueString(sear, key: "text"))
}

func parseComt(comt:Comt,co:[String:Any]) {
    comt.username   = getJsonValueString(co, key: "username")
    comt.user_img   = getJsonValueString(co, key: "user_img")
    comt.text       = fixText(getJsonValueString(co, key: "text"))
    comt.createtime = getJsonValueString(co, key: "createtime")
    comt.uid        = getJsonValueString(co, key: "uid")
}

func parseComts(comts:Comts,cos:[String:Any]) {
    //解析貼文資料
    comts.username   = getJsonValueString(cos, key: "username")
    comts.user_img   = getJsonValueString(cos, key: "user_img")
    comts.text       = getJsonValueString(cos, key: "text")
    comts.createtime = getJsonValueString(cos, key: "createtime")
    comts.cmtid      = getJsonValueString(cos, key: "cmtid")
    comts.uid        = getJsonValueString(cos, key: "uid")
    
    for co in cos["comt"] as! [[String: Any]] {
        let tmpComt = Comt()
        parseComt(comt:tmpComt,co:co)
        comts.comtArr.append(tmpComt)
    }
}

func parseUserList(userList: UserList, list:[String:Any] )
{
    userList.img_url  = list["img_url"] as? String ?? ""
    userList.uid      = list["uid"] as? String ?? ""
    userList.username = list["username"] as? String ?? ""
}

func parseFriend(friend : Friend, fri:[String:Any] ){
    friend.uid                = getJsonValueString(fri, key: "uid")
    friend.img_url            = getJsonValueString(fri, key: "img_url")
    friend.serial_no          = getJsonValueString(fri, key: "serial_no")
    friend.username           = getJsonValueString(fri, key: "username")
    friend.age                = fri["age"] as! Int
    friend.location           = getJsonValueString(fri, key: "location")
    friend.constellation      = getJsonValueString(fri, key: "constellation")
    friend.location_name      = getJsonValueString(fri, key: "location_name")
    friend.constellation_name = getJsonValueString(fri, key: "constellation_name")
    friend.interest_name      = getJsonValueString(fri, key: "interest_name")
    friend.issuperlike        = getJsonValueString(fri, key: "issuperlike")
}

func parseQueryLikeMe(querylikeme: QueryLikeMe , like:[String:Any] ){
    querylikeme.uid  = like["uid"] as! String
    querylikeme.img_urllist  = like["img_urllist"] as? String ?? ""
    querylikeme.username = like["username"] as! String
    querylikeme.age = like["age"] as! Int
    querylikeme.gender_name = like["gender_name"] as! String
    querylikeme.constellation = like["constellation"] as! String
    querylikeme.location_name = like["location_name"] as! String
    querylikeme.constellation_name = like["constellation_name"] as! String
}

func parsePostJo(party: Party, jo:[String:Any])
{
    party.username = getJsonValueString(jo, key: "username")
    party.user_img = getJsonValueString(jo, key: "user_img")
    party.title = fixText(getJsonValueString(jo, key: "title"))
    party.img_url = getJsonValueString(jo, key: "img_url")
    party.starttime = getJsonValueString(jo, key: "starttime")
    party.cutofftime = getJsonValueString(jo, key: "cutofftime")
    party.address = getJsonValueString(jo, key: "address")
    party.attendance = getJsonValueString(jo, key: "attendance")
    party.budgettype = getJsonValueString(jo, key: "budgettype")
    party.budget = getJsonValueString(jo, key: "budget")
    party.party_info = fixText(getJsonValueString(jo, key: "party_info"))
    party.isJoin =  getJsonValueString(jo, key: "isJoin")
    party.isHost =  getJsonValueString(jo, key: "isHost")
    party.isAllow = getJsonValueString(jo, key: "allow_join")
    party.isCutOff = getJsonValueString(jo, key: "isCutOff")
    party.isExpired = getJsonValueString(jo, key: "isExpired")
    party.avgStarRating = jo["avgStarRating"] as? String ?? "0"
    party.hitCount = getJsonValueString(jo, key: "hitCount")
}

func parseChat(chat: Chat, cha:[String:Any])
{
    chat.username = cha["username"] as! String
    chat.chtid = cha["chtid"] as! String
    chat.friend_uid = cha["friend_uid"] as! String
    chat.ischatopen = cha["ischatopen"] as! String
    chat.modifiedtime = cha["modifiedtime"] as! String
    chat.img_url = cha["img_url"] as? String ?? ""
    chat.shortid = cha["shortid"] as! String
    chat.suspension = cha["suspension"] as! String
    chat.isStop = cha["isStop"] as! String
}

func parseAddress(selectedItem:MKPlacemark) -> String
{
    let comma = ", "
    let street = selectedItem.addressDictionary!["Street"] as? String ?? ""
    let addressLine = String(
        format:"%@%@%@%@%@",
        selectedItem.name ?? "" ,
        comma,
        //State
        selectedItem.subAdministrativeArea ?? "",
        //city
        selectedItem.locality ?? "",
        // street
        street
    )
    return addressLine
}

func parseAttendList(attendanceList: AttendanceList, attList:[String:Any])
{
    attendanceList.uid = attList["uid"] as! String
    attendanceList.username = attList["username"] as! String
    attendanceList.img_url = attList["img_url"] as? String ?? ""
    attendanceList.age = attList["age"] as! String
    attendanceList.timespan = attList["timespan"] as! String
    attendanceList.location_Name = attList["location_name"] as? String ?? ""
    attendanceList.isHost = getJsonValueString(attList, key: "isHost")
    attendanceList.starRating = attList["starRating"] as? String ?? "0"
    attendanceList.isMyself = getJsonValueString(attList, key: "isMyself")
}

func parseMatchInfo(matchInfo: MatchInfo, match:[String: Any])
{
    matchInfo.uid            = match["uid"] as! String
    matchInfo.selectuid      = match["selectuid"] as! String
    matchInfo.selectimg_url  = match["selectimg_url"] as? String ?? ""
    matchInfo.img_url        = match["img_url"] as? String ?? ""
    matchInfo.selectuid      = match["selectuid"] as! String
    matchInfo.issuperlike    = match["issuperlike"] as! String
    matchInfo.selectusername = match["selectusername"] as! String
    matchInfo.selectshortid  = match["shortuid"] as! String
}

func parseMsg(message: Msg, msg: [String: Any])
{
    message.id        = msg["id"] as? String ?? ""
    message.msg       = msg["msg"] as? String ?? ""
    message.timestamp = String(msg["time"] as? Int64 ?? 0)
    message.type      = msg["type"] as? String ?? ""
    message.isRead    = msg["isread"] as? [String] ?? []
}

func parseNotify(notify: Notify, note:[String: Any]) {
    notify.serial_no  = getJsonValueString(note, key: "serial_no")
    notify.uid        = getJsonValueString(note, key: "uid")
    notify.callapi    = getJsonValueString(note, key: "callapi")
    notify.text       = fixText(getJsonValueString(note, key: "text"))
    notify.is_read    = getJsonValueString(note, key: "is_read")
    notify.createtime = getJsonValueString(note, key: "createtime")
    notify.img_url    = getJsonValueString(note, key: "img_url")
}

func parseBlck(block:Block, list:[String: Any]) {
    block.img_url    = getJsonValueString(list, key: "img_url")
    block.friend_uid = getJsonValueString(list, key: "friend_uid")
    block.username   = getJsonValueString(list, key: "username")
}

func parseReview(review:Review, rev:[String: Any]) {
    review.reviewUid    = getJsonValueString(rev, key: "reviewUid")
    review.user_img     = getJsonValueString(rev, key: "user_img")
    review.username     = getJsonValueString(rev, key: "username")
    review.starRating   = getJsonValueString(rev, key: "starRating")
    review.TEXT         = fixText(getJsonValueString(rev, key: "TEXT"))
    review.modifiedtime = getJsonValueString(rev, key: "modifiedtime")
}

func parseJsonMemo(jsonMemo: JsonMemo, memo:[String: Any]) {
    jsonMemo.uid         = getJsonValueString(memo, key: "uid")
    jsonMemo.ptid        = getJsonValueString(memo, key: "ptid")
    jsonMemo.pid         = getJsonValueString(memo, key: "pid")
    jsonMemo.cmtid       = getJsonValueString(memo, key: "cmtid")
    
    jsonMemo.chtid       = getJsonValueString(memo, key: "chtid")
    jsonMemo.senduid     = getJsonValueString(memo, key: "senduid")
    jsonMemo.username    = getJsonValueString(memo, key: "username")
    jsonMemo.username = jsonMemo.username.htmlDecoded
    
    jsonMemo.userIcon    = getJsonValueString(memo, key: "img_url")
    jsonMemo.shortid     = getJsonValueString(memo, key: "short_uid")
    
    jsonMemo.otherReason = getJsonValueString(memo, key: "otherReason")
    jsonMemo.isPublic    = getJsonValueString(memo, key: "isPublic")
    jsonMemo.myUid       = getJsonValueString(memo, key: "notifiedUid")
}

func parsePostHPData(po: [String:Any]) -> PostHPData {
    let tmpPostHPData = PostHPData(
        pid: getJsonValueString(po, key: "pid"),
        text: fixText(getJsonValueString(po, key: "text")),
        img_url: getJsonValueString(po, key: "img_url"),
        user_img: getJsonValueString(po, key: "user_img"),
        uid: getJsonValueString(po, key: "uid"),
        gp: getJsonValueString(po, key: "gp"),
        comt_cnt: getJsonValueString(po, key: "comt_cnt"),
        isMyself: getJsonValueString(po, key: "isMyself"))
    return tmpPostHPData
}

func parsePartyHPData(party: [String:Any]) -> PartyHPData {
    let tmpPartyHPData = PartyHPData(
        ptid: getJsonValueString(party, key: "ptid"),
        uid: fixText(getJsonValueString(party, key: "uid")),
        img_url: getJsonValueString(party, key: "img_url"),
        user_img: getJsonValueString(party, key: "user_img"),
        title: getJsonValueString(party, key: "title"),
        address: getJsonValueString(party, key: "address"),
        starttime: getJsonValueString(party, key: "starttime"),
        isMyself: getJsonValueString(party, key: "isMyself"),
        budget_label: getJsonValueString(party, key: "budget_label"))
    return tmpPartyHPData
}
