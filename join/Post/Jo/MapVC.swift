//
//  MapVC.swift
//  join
//
//  Created by 連亮涵 on 2020/7/2.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let tap = UITapGestureRecognizer(target: self, action: #selector(resultEndEdit))
        self.view.addGestureRecognizer(tap)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(dismissMapVC), name: NSNotification.Name(rawValue: "dismissMapVC"), object: nil)
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "AdressSearchTable") as! AdressSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        //
        let searchBar = resultSearchController!.searchBar
        resultSearchController!.searchBar.showsCancelButton = false
        searchBar.frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: 44)
        searchBar.placeholder = "請輸入地址"
        self.view.addSubview(searchBar)
        //
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    @objc func resultEndEdit(){
        resultSearchController?.searchBar.resignFirstResponder()
        self.resultSearchController?.isActive = false
    }
    
    @objc func dismissMapVC(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeAdress"), object: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
