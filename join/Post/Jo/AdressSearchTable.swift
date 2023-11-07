//
//  AdressSearchTable.swift
//  join
//
//  Created by 連亮涵 on 2020/7/2.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import MapKit

class AdressSearchTable: UITableViewController, UISearchResultsUpdating {
    
    var matchingItems:[MKMapItem] = []
    var mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        globalData.tmpAdress = parseAddress(selectedItem: selectedItem)
        globalData.tmpCity = selectedItem.subAdministrativeArea ?? ""
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissMapVC"), object: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
