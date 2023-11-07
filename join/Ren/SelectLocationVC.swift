//
//  SelectLocationVC.swift
//  join
//
//  Created by ChrisLien on 2021/1/4.
//  Copyright © 2021 gmpsykr. All rights reserved.
//

import UIKit

class SelectLocationVC: UIViewController {

    @IBOutlet weak var naviBar: UINavigationItem!
    @IBOutlet weak var tbv_location: UITableView!
    
    var domestic_combine_array = [Combine]()
    var abroad_combine_array = [Combine]()
    var rowArray:[Int] = []
    
    var canSelectRow = 0
    var navibarTitle = ""
    
    var isChecked = Array(repeating: false, count: 23)
    
    weak var delegate : PassLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv_location.delegate = self
        tbv_location.dataSource = self
        tbv_location.allowsMultipleSelection = true
        presentationController?.delegate = self
        naviBar.title = navibarTitle
        
        domestic_combine_array = combineArray(idArr: globalData.domestic_id_array, txtArr: globalData.domestic_txt_array)
        abroad_combine_array = combineArray(idArr: globalData.abroad_id_array, txtArr: globalData.abroad_txt_array)
    
        for i in rowArray {
            let rowToSelect = IndexPath(row: i, section: 0)
            tbv_location.selectRow(at: rowToSelect, animated: true, scrollPosition: .none)
            tbv_location.delegate?.tableView?(tbv_location, didSelectRowAt: rowToSelect)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        var tmpCombineArray : [Combine] = []
        
        if let delegate = delegate, navibarTitle == "台灣"{
            tbv_location.indexPathsForSelectedRows?.forEach {
                tmpCombineArray.append(domestic_combine_array[$0.row])
            }
            
            delegate.doSomethingWith(data: tmpCombineArray, from: "domestic")
        } else if let delegate = delegate, navibarTitle == "國外" {
            tbv_location.indexPathsForSelectedRows?.forEach {
                tmpCombineArray.append(abroad_combine_array[$0.row])
            }
            
            delegate.doSomethingWith(data: tmpCombineArray, from: "abroad")
        }
        self.dismiss(animated: true, completion: .none)
    }
}

extension SelectLocationVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var tbvCount = 0
        if navibarTitle == "台灣" {
            tbvCount = domestic_combine_array.count
        } else if navibarTitle == "國外" {
            tbvCount = abroad_combine_array.count
        }
        return tbvCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectL", for: indexPath)
        cell.selectionStyle = .none
        if navibarTitle == "台灣" {
            cell.textLabel?.text = domestic_combine_array[indexPath.row].txt
        } else if navibarTitle == "國外" {
            cell.textLabel?.text = abroad_combine_array[indexPath.row].txt
        }
        
        if isChecked[indexPath.row] { cell.accessoryType = .checkmark } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows!.count < canSelectRow {
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            isChecked[indexPath.row] = true
            
            if isChecked[indexPath.row] { cell?.accessoryType = .checkmark} else {
                cell?.accessoryType = .none
            }
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            tbv_location.delegate!.tableView?(tableView, didDeselectRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        self.isChecked[indexPath.row] = false
        
        if !isChecked[indexPath.row] {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    }
}

extension SelectLocationVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    //下拉關閉取消時，下拉手勢觸發
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
          let alert = UIAlertController(title: "確認取消編輯!?", message: nil, preferredStyle: .actionSheet)
          alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
              self.dismiss(animated: true)
          })
          alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
          self.present(alert, animated: true)
    }
}

protocol PassLocationDelegate : NSObjectProtocol{
    func doSomethingWith(data: [Combine], from: String)
}
