//
//  ChatVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit


class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        loadChatOrder()
        
    }
    
    func loadChatOrder() {
        
        print("Load recent chat")
        
    }
    

}
