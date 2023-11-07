//
//  SwipeProfileView.swift
//  join
//
//  Created by ChrisLien on 2020/8/18.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SwipeProfileView: UIView, UIScrollViewDelegate {
    
    let v_profile: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    let img_moreInfo: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "info-circle-solid-20pt × 20pt")
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let v_leftTouch: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let v_rightTouch: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let sv_photos: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.bounces = false
        sv.isUserInteractionEnabled = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    let pg_control = UIPageControl()
    let lbl_name_gender_age = UILabel()
    let lbl_location = ProfileLabel(textAlignment: .center)
    let lbl_constellation = ProfileLabel(textAlignment: .center)
    let lbl_interest = ProfileLabel(textColor: .white)
    
    var imgs: [String] = []
    var uid = ""
    var profile: UserInfo = UserInfo()
    
    func init_profile(imgs: [String],
                      username: String,
                      age: String,
                      uid: String,
                      location: String,
                      constellation : String,
                      interests: String,
                      width: CGFloat,
                      height: CGFloat)
    {
        self.uid = uid
        self.frame.size = CGSize(width: width, height: height)
        self.imgs = imgs
        
        sv_photos.layer.cornerRadius = frame.height/36
        sv_photos.contentSize = CGSize(width: CGFloat(Int(width)*imgs.count), height: height)
        var imgCount = 0
        for img in self.imgs {
            let imgView = UIImageView()
            imgView.frame = CGRect(x: width * CGFloat(imgCount),y:0,width: width,height: height)
            imgView.contentMode = .scaleAspectFill
            imgView.layer.masksToBounds = true
            imgView.isUserInteractionEnabled = true
            DownloadImage(view: imgView, img: img, id: "uid:" + uid, placeholder: nil)
            sv_photos.addSubview(imgView)
            imgCount += 1
        }
       
        pg_control.numberOfPages = imgs.count
        pg_control.sizeToFit()
       
        var gender = ""
        if globalData.gender == "1" { gender = "♀" }
        else if globalData.gender == "2" { gender = "♂" }
        let attrbutedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.white])
        attrbutedText.append(NSMutableAttributedString(string: "   " + gender, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.white]))
        attrbutedText.append(NSMutableAttributedString(string: "  " + age, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]))
        lbl_name_gender_age.attributedText = attrbutedText
        lbl_location.addIconToLabel(img: BasicIcons.place_48pt!, labelText: location, bounds_x: -1, bounds_y: -2, boundsWidth: 15, boundsHeight: 15)
        switch constellation {
        case "牡羊座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_001!, labelText: constellation)
        case "金牛座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_002!, labelText: constellation)
        case "雙子座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_003!, labelText: constellation)
        case "巨蟹座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_004!, labelText: constellation)
        case "獅子座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_005!, labelText: constellation)
        case "處女座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_006!, labelText: constellation)
        case "天秤座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_007!, labelText: constellation)
        case "天蠍座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_008!, labelText: constellation)
        case "射手座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_009!, labelText: constellation)
        case "摩羯座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_010!, labelText: constellation)
        case "水瓶座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_011!, labelText: constellation)
        case "雙魚座":
            lbl_constellation.addStartoLabel(img: Icons.constellation_012!, labelText: constellation)
        default:
            lbl_constellation.text = ""
        }
        lbl_interest.text = interests.replacingOccurrences(of: ",", with: " / ")
        //
        [sv_photos,v_leftTouch,v_rightTouch,pg_control,v_profile].forEach{ self.addSubview($0) }
        [img_moreInfo,lbl_name_gender_age,lbl_location,lbl_constellation,lbl_interest].forEach{ v_profile.addSubview($0) }
        setupAnchors(width: width, height: height)
        setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        let tapLastPage = UITapGestureRecognizer.init(target: self, action: #selector(lastPage))
        v_leftTouch.addGestureRecognizer(tapLastPage)
        
        let tapNextPage = UITapGestureRecognizer.init(target: self, action: #selector(nextPage))
        v_rightTouch.addGestureRecognizer(tapNextPage)
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(goProfile))
        img_moreInfo.addGestureRecognizer(touch)
    }
    
    func setupAnchors(width: CGFloat, height: CGFloat) {
        pg_control.frame = CGRect(x: 15, y: 15, width: 100, height: 30)
        sv_photos.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        v_leftTouch.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil,size: CGSize(width: width/2, height: 0))
        v_rightTouch.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor,size: CGSize(width: width/2, height: 0))
        v_profile.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,size: CGSize(width: 0, height: 98))
        img_moreInfo.anchor(top: v_profile.topAnchor, leading: nil, bottom: nil, trailing: v_profile.trailingAnchor,padding: .init(top: 10, left: 0, bottom: 0, right: 20),size: CGSize(width: 20, height: 20))
        lbl_name_gender_age.anchor(top: v_profile.topAnchor, leading: v_profile.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 7, left: 15, bottom: 0, right: 0), size: CGSize(width: width - 15, height: 30))
        lbl_location.anchor(top: lbl_name_gender_age.bottomAnchor, leading: v_profile.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 12, bottom: 0, right: 0), size: CGSize(width: 70, height: 18))
        lbl_constellation.anchor(top: lbl_name_gender_age.bottomAnchor, leading: lbl_location.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 80, bottom: 0, right: 0), size: CGSize(width: 90, height: 18))
        lbl_interest.anchor(top: lbl_constellation.bottomAnchor, leading: v_profile.leadingAnchor, bottom: nil, trailing: v_profile.trailingAnchor, padding: .init(top: 10, left: 15, bottom: 0, right: 0), size: CGSize(width: 0, height: 18))
    }
    
    @objc func nextPage() {
        if pg_control.currentPage == imgs.count - 1 {
            print("end")
        } else {
            let offset = CGPoint(x: (frame.width) * CGFloat(pg_control.currentPage + 1), y: 0)
            pg_control.currentPage = pg_control.currentPage + 1
            sv_photos.setContentOffset(offset, animated: true)
            print("next")
        }
    }
    
    @objc func lastPage() {
        if pg_control.currentPage == 0 {
            print("end")
        } else {
            let offset = CGPoint(x: (frame.width) * CGFloat(pg_control.currentPage - 1), y: 0)
            pg_control.currentPage = pg_control.currentPage - 1
            sv_photos.setContentOffset(offset, animated: true)
            print("last")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pg_control.currentPage = page
        let offset = CGPoint(x: CGFloat(page)*scrollView.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func goProfile() {
        let vc = findViewController()?.storyboard?.instantiateViewController(withIdentifier: "UserProfileNavi") as! UserProfileNavi
        vc.uid = self.uid
        vc.isRen = true
        findViewController()?.present(vc,animated: true)
    }
}
