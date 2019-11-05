//
//  ProfileVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var feature = ["Notifications", "My Order", "Payment", "Security", "Voucher", "Profile Info", "Help & Support"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.reloadData()
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feature[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.lightGray
                cell.addSubview(line)
                
            }
            
            cell.configureCell(item)
            
            return cell
            
        } else {
            
            return ProfileCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "Notifications" {
            
            self.performSegue(withIdentifier: "MoveToNotificationVC", sender: nil)
            
        } else if item == "Payment" {
            
            
            self.performSegue(withIdentifier: "moveToPaymentVC", sender: nil)
            
            
        }
    }
    
    

}
