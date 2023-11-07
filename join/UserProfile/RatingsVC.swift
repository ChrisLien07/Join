//
//  RatingsVC.swift
//  join
//
//  Created by ChrisLien on 2020/11/20.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Cosmos

class RatingsVC: UIViewController {

    @IBOutlet weak var v_top: UIView!
    @IBOutlet weak var tbv_ratings: UITableView!
    
    let v_avergaveStar: CosmosView = {
        let v = CosmosView()
        v.settings.updateOnTouch = false
        v.settings.filledImage = ratingStar.fill_27pt
        v.settings.emptyImage = ratingStar.empty_27pt
        v.settings.fillMode = .precise
        v.settings.starSize = 30
        
        v.settings.textColor = Colors.friendRed
        v.settings.textMargin = 20
        v.settings.textFont = .systemFont(ofSize: 20)
        return v
    }()
    
    var reviews: [Review] = []
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv_ratings.delegate = self
        tbv_ratings.dataSource = self
        v_top.addSubview(v_avergaveStar)
        v_avergaveStar.anchor(top: v_top.topAnchor, leading: v_top.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 15, left: 15, bottom: 15, right: 0), size: CGSize(width: view.frame.width, height: 30))
        v_avergaveStar.text = "0.0"
        getReviews()
    }
    
    func getReviews() {
        NetworkManager.shared.callGetReviewService(uid: uid) { (code, list, avgStarRating) in
            if code == 0 {
                self.v_avergaveStar.rating = Double(avgStarRating)!
                self.v_avergaveStar.text = avgStarRating
                self.reviews = list!
                self.tbv_ratings.reloadData()
            } else if code == 2 {
                Alert.ShowConnectErrMsg(vc: self)
            } else if code == 127 {
                
            } else {
                ShowErrMsg(code: code,msg: avgStarRating,vc: self)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RatingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "RatingCell", for: indexPath) as! RatingCell
        let review = reviews[indexPath.row]
        cell.selectionStyle = .none
        cell.init_review(reviewUid: review.reviewUid, user_img: review.user_img, username: review.username, starRating: review.starRating, text: review.TEXT, modifiedtime: review.modifiedtime)
        return cell
    }
}
