//
//  UpdateFindTypeTbV.swift
//  join
//
//  Created by 連亮涵 on 2020/7/29.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit

class UpdateListTbV: UITableViewController {
    
    let bloodtype_txtArray : [String] = ["不透露","A型","B型","O型","AB型"]
    let bloodtype_idArray : [String] = ["000","001","002","003","004"]
    var bloodtype_combineArray:[Combine] = [Combine]()
    var bloodtype_isChecked = Array(repeating: false, count: 5)
    
    let personality_txtArray : [String] = ["不透露","活潑","樂觀","健談","大方","文靜","內向","保守","容易緊張","親切","成熟穩重","細心","有信用","重情重義","勤勞","才華洋溢","有智慧","大膽"]
    let personality_idArray : [String] = ["001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018"]
    var personality_combineArray = [Combine]()
    var personality_isChecked = Array(repeating: false, count: 18)
    
    var from = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if from == "personality" {
            tableView.allowsMultipleSelection = true
        }
        bloodtype_combineArray = combineArray(idArr: bloodtype_idArray, txtArr: bloodtype_txtArray)
        personality_combineArray = combineArray(idArr: personality_idArray, txtArr: personality_txtArray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch from
        {
        case "bloodtype":
            self.title = "我的血型"
        case "personality":
            self.title = "我的個性"
        default:
            break
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if tableView.indexPathsForSelectedRows?.count ?? 0 > 0 {
            switch from
            {
                case "bloodtype":
                    globalData.tmpBloodtype  = bloodtype_combineArray[tableView.indexPathForSelectedRow!.row]
                case "personality":

                    var idArray: [String] = []
                    var txtArray: [String] = []

                    for i in 0...(tableView.indexPathsForSelectedRows!.count - 1) {
                        idArray.append(personality_combineArray[tableView.indexPathsForSelectedRows![i].row].id)
                        txtArray.append(personality_combineArray[tableView.indexPathsForSelectedRows![i].row].txt)
                    }
                    
                    globalData.tmpPersonality.id = idArray.joined(separator: ",")
                    globalData.tmpPersonality.txt = txtArray.joined(separator: ",")
                default:
                    break
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch from
        {
        case "bloodtype":
            return bloodtype_combineArray.count
        case "personality":
            return personality_combineArray.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "4K", for: indexPath)
        cell.selectionStyle = .none
        switch from
        {
        case "bloodtype":
            cell.textLabel?.text = bloodtype_combineArray[indexPath.row].txt
            if bloodtype_isChecked[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case "personality":
            cell.textLabel?.text = personality_combineArray[indexPath.row].txt
            if personality_isChecked[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        default: break
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if from == "personality" {
            if tableView.indexPathsForSelectedRows!.count <= 6 {
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
                self.personality_isChecked[indexPath.row] = true
                
                if personality_isChecked[indexPath.row] {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            for row in 0..<tableView.numberOfRows(inSection: indexPath.section)
            {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section))
                {
                    cell.accessoryType = .none
                    if from == "bloodtype"
                    {self.bloodtype_isChecked = Array(repeating: false, count: 5)}
                    else if from == "personality"
                    {self.personality_isChecked = Array(repeating: false, count: 18)}
                }
            }
            cell?.accessoryType = .checkmark
            if from == "bloodtype"
            {self.bloodtype_isChecked[indexPath.row] = true}
            else if from == "personality"
            {self.personality_isChecked[indexPath.row] = true}
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if from == "personality" {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            self.personality_isChecked[indexPath.row] = false
            
            if !personality_isChecked[indexPath.row] {
                cell?.accessoryType = .none
            } else {
                cell?.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (from)
        {
        case "personality":
            return "*最多選擇6項"
        default:
            return ""
        }
    }
}
