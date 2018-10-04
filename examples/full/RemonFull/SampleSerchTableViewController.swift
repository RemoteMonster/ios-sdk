//
//  SampleSerchTableViewController.swift
//  SampleV2
//
//  Created by hyounsiklee on 2018. 5. 21..
//  Copyright © 2018년 Remon. All rights reserved.
//

import UIKit
import RemoteMonster

class SampleSerchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var remonCast: RemonCast!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var reloadBtn: UIButton!
    
    var customConfig:RemonConfig?
    
    @IBAction func reloadAction(_ sender: Any) {
        if customConfig != nil && customConfig?.serviceId != nil { // && customConfig?.key != nil {
            remonCast.serviceId = customConfig?.serviceId
//            remonCast.serviceKey = customConfig?.key
        }
        
        remonCast.fetchCasts(isTest:true) { (results) in
            guard let rs = results
                else { return}
            self.items = rs
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
    }
    
    var items:Array<RemonSearchResult> = Array<RemonSearchResult>()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.chId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:SimpleCastViewer? = self.storyboard?.instantiateViewController(withIdentifier: "SimpleCastViewer") as? SimpleCastViewer
        let item = self.items[indexPath.row]
        vc?.customConfig = customConfig
        vc?.toChID = item.chId
        if vc != nil {
            self.show(vc!, sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadAction(self.reloadBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
