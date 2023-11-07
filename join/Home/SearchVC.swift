//
//  SearchViewController.swift
//  join
//
//  Created by 連亮涵 on 2020/6/1.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITextFieldDelegate {
   
    @IBOutlet weak var tbv_Search: UITableView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var pv_location: UIPickerView!
    @IBOutlet weak var v_toolbar: UIView!
    
    let location_array = ["基隆市","台北市","新北市","桃園市","新竹市","新竹縣","苗栗縣","台中市","彰化縣","南投縣","雲林縣","嘉義市","嘉義縣","台南市","高雄市","屏東縣","台東縣","花蓮縣","宜蘭縣","澎湖縣","金門縣","連江縣"]
    var searchArray: [Search] = []
    var city = "地區"
    var searchController = UISearchController()
    var isShowSearchResult = false
    var isParty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoard()
        setupNavigationBar()
        setDelegates()
        configureTextfield()
        if  isParty { setupFiltBtn() }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideMainBar()
        tbv_Search.isHidden = true
    }

    fileprivate func setDelegates() {
        txt_Search.delegate = self
        tbv_Search.delegate = self
        tbv_Search.dataSource = self
        pv_location.delegate = self
        pv_location.dataSource = self
    }
    
    fileprivate func setupFiltBtn() {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(filtLocation(_:)), for: .touchUpInside)
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 30, height: 30))
        imageView.image = BasicIcons.place_48pt
        imageView.tintColor = Colors.themePurple
        let label = UILabel(frame: CGRect(x: 35, y: 0, width: 50, height: 30))
        label.text = "\(city)"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        button.frame = buttonView.frame
        buttonView.addSubview(button)
        buttonView.addSubview(imageView)
        buttonView.addSubview(label)
        let rightButton = UIBarButtonItem.init(customView: buttonView)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    fileprivate func configureTextfield() {
        txt_Search.returnKeyType = .search
        txt_Search.backgroundColor = #colorLiteral(red: 0.462745098, green: 0.462745098, blue: 0.5019607843, alpha: 0.1179901541)
        txt_Search.layer.cornerRadius = 34/2
        txt_Search.setPaddingPoints(17)
        if isParty {
            txt_Search.placeholder = "搜尋活動"
        } else {
            txt_Search.placeholder = "搜尋貼文"
        }
    }
    
    func setupNavigationBar() {
        let image = UIImage()
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = image
    }
    
    func setupBoard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endSearch))
        self.view.addGestureRecognizer(tap)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result = false
        if let text = textField.text, let range = Range(range, in: text) {
            let newText = text.replacingCharacters(in: range, with: string)
            if newText.count <= 20 {
                result = true
            } else {
                result = false
            }
         }
         return result
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if isParty {
            searchParty()
        } else {
            searchPost()
        }
        return true
    }
    
    func searchParty() {
        var city = self.city
        if self.city == "地區" { city = "" }
        searchArray.removeAll()
        NetworkManager.shared.callSearchPartyService(text: txt_Search.text!, city: city) { [self] (code, data) in
            switch code {
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 0:
                searchArray = data!
                isShowSearchResult = true
                tbv_Search.isHidden = false
                tbv_Search.reloadData()
            case 127:
                isShowSearchResult = false
                tbv_Search.isHidden = false
                tbv_Search.reloadData()
            default:
                break
            }
        }
    }
    
    func searchPost() {
        
        searchArray.removeAll()
        
        NetworkManager.shared.callSearchPostService(text: txt_Search.text!) { [self] (code, data) in
            switch code {
            case 2:
                Alert.ShowConnectErrMsg(vc: self)
            case 0:
                searchArray = data!
                isShowSearchResult = true
                tbv_Search.isHidden = false
                tbv_Search.reloadData()
            case 127:
                isShowSearchResult = false
                tbv_Search.isHidden = false
                tbv_Search.reloadData()
            default:
                break
            }
        }
    }
    
    @objc func endSearch() {
        self.txt_Search.resignFirstResponder()
    }
    
    @objc func filtLocation(_ sender: Any) {
        pv_location.isHidden = !pv_location.isHidden
        v_toolbar.isHidden = !v_toolbar.isHidden
    }
    
    @IBAction func finishFilt(_ sender: Any) {
        self.txt_Search.resignFirstResponder()
        pv_location.isHidden = true
        v_toolbar.isHidden = true
        searchParty()
    }
    
    @IBAction func back(_ sender: Any) {
        txt_Search.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return location_array.count
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return location_array[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        city = location_array[row]
        setupFiltBtn()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowSearchResult {
            return searchArray.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowSearchResult {
            if  isParty {
                let cell = tableView.dequeueReusableCell (withIdentifier: "partyResult", for: indexPath) as! SearchTableCell
                let sear = searchArray[indexPath.row]
                cell.initSearch(ptid: sear.ptid, uid: sear.uid, img_url: sear.img_url, title: sear.title, starttime: sear.starttime, address: sear.address, height: view.frame.width/2, width: view.frame.width - 30)
                
                if indexPath.row == 0 {
                    cell.v_result.frame = CGRect(x:15,y:15,width: view.frame.width - 30,height: view.frame.width * 9 / 18)
                }
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postResult", for: indexPath) as! MyPostCell
                let post = searchArray[indexPath.row]
                cell.selectionStyle = .none
                cell.initPost(pid: post.pid, uid: post.uid, img_url: post.img_url, txt: post.text, gp: post.gp, comt_cnt: post.comt_cnt, height: view.frame.height/9, width:view.frame.width - 30)
                
                if indexPath.row == 0 {
                    cell.v_main.frame = CGRect(x:15,y:15,width: view.frame.width - 30,height: view.frame.height/9)
                }
            
                cell.img_post.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            
                return cell
            }
            
        } else {

            if isParty {
                let cell = tableView.dequeueReusableCell (withIdentifier: "noPartyResult", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell (withIdentifier: "noPostResult", for: indexPath)
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if !isParty, isShowSearchResult {
                return view.frame.height/9 + 30
            } else {
                return view.frame.width/2 + 25
            }
        } else {
            if isParty {
                return view.frame.width/2 + 16
            } else {
                return view.frame.height/9 + 15
            }
        }
    }
}
