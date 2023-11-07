//
//  CommonEnum.swift
//  join
//
//  Created by ChrisLien on 2020/11/2.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

enum Colors {
    static let themePurple           = UIColor(red: 113/255, green: 30/255, blue: 213/255, alpha: 1)
    static let postBlue              = UIColor(red: 69/255, green: 99/255, blue: 223/255, alpha: 1)
    static let partyYellow           = UIColor(red: 255/255, green: 175/255, blue: 38/255, alpha: 1)
    static let friendRed             = UIColor(red: 230/255, green: 73/255, blue: 73/255, alpha: 1)
    static let rgb217Gray            = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
    static let rgb41Black            = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
    static let rgb188Gray            = UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1)
    static let rgb149Gray            = UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)
    static let rgb91Gray             = UIColor(red: 91/255, green: 91/255, blue: 91/255, alpha: 1)
    static let rgb112Gray            = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
    static let rgb248Gray            = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
}

enum Icons {
    static let constellation_001 = UIImage(named: "constellation_001")
    static let constellation_002 = UIImage(named: "constellation_002")
    static let constellation_003 = UIImage(named: "constellation_003")
    static let constellation_004 = UIImage(named: "constellation_004")
    static let constellation_005 = UIImage(named: "constellation_005")
    static let constellation_006 = UIImage(named: "constellation_006")
    static let constellation_007 = UIImage(named: "constellation_007")
    static let constellation_008 = UIImage(named: "constellation_008")
    static let constellation_009 = UIImage(named: "constellation_009")
    static let constellation_010 = UIImage(named: "constellation_010")
    static let constellation_011 = UIImage(named: "constellation_011")
    static let constellation_012 = UIImage(named: "constellation_012")
}

enum BasicIcons {
    static let place_48pt = UIImage(named: "baseline_place_black_48pt")
    static let thumb      = UIImage(named: "baseline_thumb_up_black_24pt")
    static let chat_black = UIImage(named: "baseline_chat_bubble_black_24pt")
    static let add_36pt   = UIImage(named: "baseline_add_black_36pt")
    
}

enum ratingStar {
    static let fill_18pt  = UIImage(named: "ratingStar-solid-18pt × 18pt")
    static let empty_18pt = UIImage(named: "ratingStar-regular-18pt × 18pt")
    static let fill_27pt = UIImage(named: "ratingStar-solid-27pt × 26pt")
    static let empty_27pt = UIImage(named: "ratingStar-regular-27pt × 26pt")
    static let fillBlue_16pt = UIImage(named: "ratingStar-blue-solid-16pt x 16pt")
    static let emptyBlue_16pt = UIImage(named: "ratingStar-blue-regular-16pt x 16pt")
}

enum Notifications {
    static let autoLogin = NSNotification.Name(rawValue: "autoLogin")

    static let queryUser = NSNotification.Name(rawValue: "queryUser_app")
    
    static let like = NSNotification.Name(rawValue: "like")
    static let dislike = NSNotification.Name(rawValue: "disLike")
    static let superlike = NSNotification.Name(rawValue: "superLike")

}

enum userNotifications {
    static let queryuser = NSNotification.Name(rawValue: "userNotificationQueryuser")
    static let getpost = NSNotification.Name(rawValue: "userNotificationGetPost")
    static let getparty = NSNotification.Name(rawValue: "userNotificationGetParty")
    static let getUnreviewedList = NSNotification.Name(rawValue: "userNotificationGetUnreviewedList")
    static let getAttendanceList = NSNotification.Name(rawValue: "userNotificationGetAttendanceList")
    static let openChat = NSNotification.Name(rawValue: "userNotificationOpenCHat")
    
}

enum JoinError: String, Error {
    case notPurchased = "notPurchased"
    case purchased = "purchased"
    case otherError = "otherError"
    
}
