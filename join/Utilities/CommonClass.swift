//
//  CommonClass.swift
//  join
//
//  Created by 連亮涵 on 2020/5/26.
//  Copyright © 2020 gmpsykr. All rights reserved.
//
import UIKit

//    var location_rq: String = ""
//    var location_rq_name: String = ""
class UserInfo {
    var shortid: String = ""
    var username : String = ""
    var gender : String = ""
    var birthday : String = ""
    var age : Int = 0
    var location_name: String = ""
    var constellation_id: String = ""
    var constellation_name : String = ""
    var bloodtype : String = ""
    var job_name : String = ""
    var relationship_name : String = ""
    var max_age : Int = 0
    var min_age : Int = 0
    var personality_name : String = ""
    var interest_name : String = ""
    var interest_name_array: [String] = []
    var user_info: String = ""
    var img_url1: String = ""
    var img_url2: String = ""
    var img_url3: String = ""
    var img_url4: String = ""
    var img_url5: String = ""
    var img_url6: String = ""
    var img_array:[String] = []
    var isvip : String = ""
    var party_cnt : String = ""
    var like_cnt : String = ""
    var follower_cnt : String = ""
    var follow_cnt : String = ""
    var isMyself: Int = 0
    var isfollowed: String = ""
    var avgStarRating: String = ""
    var reviewCount: String = ""
}

class Post {
    var datatype: String = ""
    var username: String = ""
    var pid: String = ""
    var text: String = ""
    var img_url: String = ""
    var user_img: String = ""
    var uid: String = ""
    var age: Int = 0
    var ptid : String = ""
    var title : String = ""
    var posttime : String = ""
    var gp : String = ""
    var comt_cnt : String = ""
    var address: String = ""
    var starttime: String = ""
    var isGd: Bool = false
    var isMyself = ""
    var budget_label = ""
}

class UserList {
    var uid : String = ""
    var username : String = ""
    var img_url : String = ""
}

class Search {
    //party
    var ptid: String = ""
    var uid: String = ""
    var img_url: String = ""
    var title: String = ""
    var starttime: String = ""
    var address: String = ""
    var isExpired: String = ""
    var timestamp: String = ""
    
    //post
    //var uid: String = ""
    //var img_url: String = ""
    var user_img: String = ""
    var pid: String = ""
    var gp: String = ""
    var comt_cnt: String = ""
    var text: String = ""
}

class Comt {
    var username: String = ""
    var user_img: String = ""
    var text: String = ""
    var uid: String = ""
    var createtime: String = ""
}

class Comts {
    var username: String = ""
    var user_img: String = ""
    var text: String = ""
    var createtime: String = ""
    var cmtid: String = ""
    var uid: String = ""
    var comtArr: [Comt] = []
}

class Friend {
    var uid: String = ""
    var img_url: String = ""
    var serial_no: String = ""
    var username: String = ""
    var age: Int = 0
    var location: String = ""
    var constellation: String = ""
    var location_name: String = ""
    var constellation_name: String = ""
    var interest_name: String = ""
    var issuperlike: String = ""
    var imgArray: [String] = []
    var interest_array: [String] = []
}

class QueryLikeMe {
    var uid : String = ""
    var username : String = ""
    var age : Int = 0
    var constellation : String = ""
    var location_name : String = ""
    var constellation_name : String = ""
    var gender_name: String = ""
    var img_urllist: String = ""
}

class Party {
    var username: String = ""
    var user_img: String = ""
    var title: String = ""
    var img_url: String = ""
    var starttime: String = ""
    var cutofftime: String = ""
    var address: String = ""
    var attendance: String = ""
    var budgettype: String = ""
    var budget: String = ""
    var party_info : String = ""
    var isJoin: String = ""
    var isHost: String = ""
    var isAllow: String = ""
    var isCutOff: String = ""
    var isExpired: String = ""
    var avgStarRating: String = ""
    var hitCount : String = ""
}

class AttendanceList {
    var uid: String = ""
    var username: String = ""
    var img_url: String = ""
    var age: String = ""
    var timespan:String = ""
    var location_Name: String = ""
    var isHost = ""
    var starRating = ""
    var isMyself = ""
}

class Combine {
    var id: String = ""
    var txt: String = ""
}

class Product {
    var txt: String = ""
    var productID: String = ""
    var item_id: String = ""
    var amount: String = ""
    var item_memo: String = ""
    var localizedDescription: String = ""
}

class MatchInfo {
    var uid: String = ""
    var selectuid: String = ""
    var img_url: String = ""
    var selectimg_url: String = ""
    var selectusername: String = ""
    var issuperlike: String = ""
    var selectshortid: String = ""
}

class Chat {
    var username: String = ""
    var chtid: String = ""
    var friend_uid: String = ""
    var ischatopen: String = ""
    var modifiedtime: String = ""
    var img_url: String = ""
    var shortid: String = ""
    var suspension: String = ""
    var isStop: String = ""
    var lasted_msg_time: String = ""
    var lasted_msg: String = ""
    var isnewmsg: String = ""
    var timestamp: String = ""
    var hasFirstMsg = false
}

class Msg {
    var id: String = ""
    var isRead: [String] = []
    var msg: String = ""
    var timestamp: String = ""
    var type: String = ""
    var isDateChanged: Bool = false
}

class Notify {
    var serial_no = ""
    var uid = ""
    var img_url = ""
    var createtime = ""
    var text = ""
    var is_read = ""
    var callapi = ""
    //memo
    var pid = ""
    var ptid = ""
    var cmtid = ""
    var senduid = ""
    var username = ""
    var memo_img_url = ""
    var isPublic = ""
}

class Block {
    var friend_uid: String = ""
    var username: String = ""
    var img_url: String = ""
}

class Review {
    var reviewUid: String = ""
    var user_img: String = ""
    var username: String = ""
    var starRating: String = ""
    var TEXT: String = ""
    var modifiedtime: String = ""
}

class JsonMemo {
    
    var uid = ""
    var ptid = ""
    var pid = ""
    var cmtid = ""
    
    var chtid = ""
    var senduid = ""
    var username = ""
    var userIcon = ""
    var shortid = ""
    
    var otherReason = ""
    var isPublic = ""
    var myUid = ""
}

// no used
struct LoginInfo {
    var token: String = ""
    var username: String = ""
    var gender: String = ""
    var birthdate: String = ""
    var age: Int = 0
    var location: String = ""
    var constellation: String = ""
    var bloodtype: String = ""
    var job: String = ""
    var relationship: String = ""
    var min_age: Int = 0
    var max_age: Int = 0
    var personality: String = ""
    var interest: String = ""
    var suspension: String = ""
    var img_url: String = ""
    var ios_transaction_id: String = ""
    var ios_product_id: String = ""
    var ios_item_id: String = ""
    var notifyCount: String = ""
    var shortuid: String = ""
}

struct PostHPData {
    var pid: String
    var text: String
    var img_url: String
    var user_img: String
    var uid: String
    var gp : String
    var comt_cnt : String
    var isMyself: String
}

struct PartyHPData {
    var ptid : String
    var uid: String
    var img_url: String
    var user_img: String
    var title: String
    var address: String
    var starttime: String
    var isMyself: String
    var budget_label: String
}
