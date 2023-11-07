//
//  Fri_SearchLocationVC.swift
//  join
//
//  Created by 連亮涵 on 2020/8/3.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import RangeSeekSlider

class SearchConditionVC: UIViewController,PassLocationDelegate {

    @IBOutlet weak var lbl_wantedAge: UILabel!
    @IBOutlet weak var lbl_wantedLocation: UILabel!
    @IBOutlet weak var v_rangeSlide: RangeSeekSlider!
    @IBOutlet weak var tbv_locations: UITableView!
    
    let lbl_age: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 13)
        lbl.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
        lbl.text = globalData.min_age + "~" + globalData.max_age
        lbl.textAlignment = .right
        return lbl
    }()
    
    let lbl_count: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 9)
        lbl.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
        lbl.textAlignment = .right
        return lbl
    }()
    
    var minValue: String = ""
    var maxValue: String = ""
    var selectedCount = 0
    
    var domesticData:[Combine] = []
    var abroadData:[Combine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        minValue = globalData.min_age
        maxValue = globalData.max_age
        
        tbv_locations.delegate = self
        tbv_locations.dataSource = self
        tbv_locations.tableHeaderView?.isUserInteractionEnabled = true
        tbv_locations.isScrollEnabled = false
        v_rangeSlide.delegate = self
        v_rangeSlide.selectedMinValue = Int(minValue).map{ CGFloat($0) }!
        v_rangeSlide.selectedMaxValue = Int(maxValue).map{ CGFloat($0) }!
        configureSeekSlider()
        
        [lbl_age,lbl_count].forEach { view.addSubview($0) }
        lbl_wantedAge.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 15, left: 15, bottom: 0, right: 0), size: CGSize(width: 0, height: 30))
       
        v_rangeSlide.anchor(top: lbl_wantedAge.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 44))
        
        lbl_age.anchor(top: nil, leading: nil, bottom: v_rangeSlide.topAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 5, right: 10), size: CGSize(width: 100, height: 20))
        
        lbl_wantedLocation.anchor(top: v_rangeSlide.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 16, left: 15, bottom: 0, right: 0), size: CGSize(width: 0, height: 30))
        
        tbv_locations.anchor(top: lbl_wantedLocation.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        lbl_count.anchor(top: nil, leading: nil, bottom: tbv_locations.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 5, right: 10), size: CGSize(width: 100, height: 20))
        //
        for i in globalData.location_rq_combine_array {
            if globalData.domestic_id_array.contains(i.id) {
                domesticData.append(i)
            } else if globalData.abroad_id_array.contains(i.id) {
                abroadData.append(i)
            }
        }
        selectedCount = domesticData.count + abroadData.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideMainBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "domestic" {
            
            let displayVC = segue.destination as! SelectLocationVC
            displayVC.navibarTitle = "台灣"
            var rowArray:[Int] = []
            for i in domesticData {
                rowArray.append(Int(i.id)! - 1)
            }
            displayVC.rowArray = rowArray
            displayVC.canSelectRow = 6 - abroadData.count
            displayVC.delegate = self
        } else if segue.identifier == "abroad" {
            
            let displayVC = segue.destination as! SelectLocationVC
            displayVC.navibarTitle = "國外"
            var rowArray:[Int] = []
            for i in abroadData {
                rowArray.append(Int(i.id)! - 24)
            }
            displayVC.rowArray = rowArray
            displayVC.canSelectRow = 6 - domesticData.count
            displayVC.delegate = self
        }
    }
    
    func doSomethingWith(data: [Combine], from: String) {
        if from == "domestic" {
            domesticData.removeAll()
            for i in data {
                self.domesticData.append(i)
            }
        } else if from == "abroad" {
            abroadData.removeAll()
            for i in data {
                 self.abroadData.append(i)
            }
        }
        selectedCount = domesticData.count + abroadData.count
        tbv_locations.reloadData()
    }
    
    func configureSeekSlider() {
        v_rangeSlide.handleDiameter = 25
        v_rangeSlide.lineHeight = 2
        v_rangeSlide.hideLabels = true
        v_rangeSlide.enableStep = true
        v_rangeSlide.step = 1
        v_rangeSlide.handleBorderWidth = 1
        v_rangeSlide.handleBorderColor = UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.2)
    }
    
    func checkforUnspecified() {
        if selectedCount == 0 {
            
            let unspecified: Combine = {
                let combine = Combine()
                combine.id = "023"
                    combine.txt = "不拘"
                return combine
            }()
            
            domesticData.append(unspecified)
        }
    }
    
    @objc func goDomestic(_ sender: UITapGestureRecognizer?) {
        if abroadData.count == 5 {
            shortInfoMsg(msg: "已滿", vc: self,sec: 2)
        } else {
            DispatchQueue.main.async {
                 self.performSegue(withIdentifier: "domestic", sender:nil)
            }
        }
    }
    
    @objc func goAbroad(_ sender: UITapGestureRecognizer?) {
        if domesticData.count == 5 {
            shortInfoMsg(msg: "已滿", vc: self,sec: 2)
        } else {
            DispatchQueue.main.async {
                 self.performSegue(withIdentifier: "abroad", sender:nil)
            }
        }
        
    }
    
    @IBAction func send(_ sender: Any) {
    
        var tmp:[String] = []
        checkforUnspecified()
        domesticData.forEach { tmp.append($0.id) }
        abroadData.forEach { tmp.append($0.id) }
        let location_rq = tmp.joined(separator:",")
     
        var data: String = "token=\(globalData.token)&max_age=\(maxValue)&min_age=\(minValue)&location_rq=\(location_rq)"
        
        if globalData.max_age == maxValue {
            let endIndex = data.range(of: "&max_age=\(maxValue)")
            data.removeSubrange(endIndex!)
        }
        
        if globalData.min_age == minValue {
            let endIndex = data.range(of: "&min_age=\(minValue)")
            data.removeSubrange(endIndex!)
        }
        
        if location_rq == "" {
            let endIndex = data.range(of: "&location_rq=\(location_rq)")
            data.removeSubrange(endIndex!)
        }
        
        let request = createHttpRequest(Url: globalData.UpdateUserUrl, HttpType: "POST", Data: data)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                        shortInfoMsg(msg: "更改完成", vc: self,sec: 2) {
                            NotificationCenter.default.post(name: Notifications.queryUser, object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getRenList"), object: nil)
                            self.showMainBar()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if responseJSON["code"] as! Int == 97
                    {
                        shortInfoMsg(msg: "更改失敗", vc: self,sec: 2)
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
        task.resume()
    }
    
    @IBAction func back(_ sender: Any) {
        if  maxValue != globalData.max_age || minValue != globalData.min_age || !domesticData.isEmpty || !abroadData.isEmpty {
            Alert.changedSearchConditionAlert(vc: self)
        } else {
            showMainBar()
            navigationController?.popViewController(animated: true)
        }
    }
}

extension SearchConditionVC: RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        self.minValue = "\(minValue)"
        self.maxValue = "\(maxValue)"
        let min = Int(minValue)
        let max = Int(maxValue)
        lbl_age.text = "\(min)" + "~" + "\(max)"
    }
}

extension SearchConditionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44
        } else {
            return 44 + 31
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return domesticData.count
        case 1:
            return abroadData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch  section {
        case 0:
            let view = UIView()
            let lbl = UILabel()
            let img_next = UIImageView()
            //
            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
            view.backgroundColor = .white
            //
            lbl.frame = CGRect(x: 20, y: 10, width: 50, height: 22)
            lbl.text = "台灣"
            lbl.font = .systemFont(ofSize: 17)
            //
            img_next.frame = CGRect(x: view.frame.width - 40, y: 15, width: 30, height: 30)
            img_next.image = UIImage(named: "baseline_keyboard_arrow_right_black_48pt")
            img_next.tintColor = .black
            view.addSubview(img_next)
            //
            let touch = UITapGestureRecognizer(target: self, action: #selector(goDomestic(_:)))
            view.addGestureRecognizer(touch)
            view.isUserInteractionEnabled = true
            view.addSubview(lbl)
            return view
        case 1:
            let v_header = UIView()
            let view = UIView()
            let lbl = UILabel()
            let img_next = UIImageView()
            //
            v_header.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20 + 44)
            v_header.backgroundColor = #colorLiteral(red: 0.9724468589, green: 0.9726095796, blue: 0.9724239707, alpha: 1)
            //
            view.frame = CGRect(x: 0, y: 31, width: self.view.frame.width, height: 44)
            view.backgroundColor = .white
            v_header.addSubview(view)
            //
            lbl.frame = CGRect(x: 20, y: 10, width: 50, height: 22)
            lbl.text = "國外"
            lbl.font = .systemFont(ofSize: 17)
            //
            img_next.frame = CGRect(x: view.frame.width - 40, y: 15, width: 30, height: 30)
            img_next.image = UIImage(named: "baseline_keyboard_arrow_right_black_48pt")
            img_next.tintColor = .black
            view.addSubview(img_next)
            //
            let touch = UITapGestureRecognizer(target: self, action: #selector(goAbroad(_:)))
            v_header.addGestureRecognizer(touch)
            view.addSubview(lbl)
            return v_header
        default:
            let view = UIView()
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "select", for: indexPath)
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = domesticData[indexPath.row].txt
        } else if indexPath.section == 1 {
            cell.textLabel?.text = abroadData[indexPath.row].txt
        }
        return cell
    }
}

protocol PassDataDelegate: NSObjectProtocol {
    func passLocationString(data:String)
}
