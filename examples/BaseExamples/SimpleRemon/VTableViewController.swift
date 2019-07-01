//
//  VTableViewController.swift
//  verySimpleRemon
//
//  Created by hyounsiklee on 2018. 4. 27..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

import UIKit

class VTableViewController: UITableViewController {
    var items:Array<String> = ["SimpleCall", "SimpleVoiceCast", "SimpleVideoCast", "SimpleCastViewer", "CustomConfig"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = self.items[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc:UIViewController?
        if indexPath.row == 0 {
           vc = self.storyboard?.instantiateViewController(withIdentifier: "SimpleCallViewController")
        } else if indexPath.row == 1 {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SimpleVoiceCast")
        } else if indexPath.row == 2 {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SimpleVideoCast")
        } else if indexPath.row == 3 {
           vc = self.storyboard?.instantiateViewController(withIdentifier: "SampleSerchTableViewController")
        } else if indexPath.row == 4 {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfigViewController")
        }

        if vc != nil {
            self.show(vc!, sender: self)
        }
    }

}
