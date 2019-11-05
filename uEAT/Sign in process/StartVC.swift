//
//  ViewController.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/18/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//  moveToHomeVC

import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var presentedHeight: NSLayoutConstraint!
    @IBOutlet weak var presentedWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var loginWidth: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        scaleImageDimension()
        
        
    }
    
    
    func scaleImageDimension() {
        
        presentedWidth.constant = self.view.frame.width * (presentedWidth.constant / CGFloat(ratio_width))
        presentedHeight.constant = self.view.frame.height * (presentedHeight.constant / CGFloat(ratio_height))
        
        loginWidth.constant = self.view.frame.width * (loginWidth.constant / CGFloat(ratio_width))
        logoHeight.constant = self.view.frame.height * (logoHeight.constant / CGFloat(ratio_height))
        
        
    }

    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToPhoneVC", sender: nil)
        
    }
    
}

