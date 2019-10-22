//
//  ViewController.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/18/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class StartVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func scaleImageDimension() {
        
        
        
        
        
        
    }

    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToPhoneVC", sender: nil)
        
    }
    
}

