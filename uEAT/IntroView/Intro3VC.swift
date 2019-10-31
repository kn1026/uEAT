//
//  Intro3VC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/31/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class Intro3VC: UIViewController {

    @IBOutlet weak var veganBtn: UIButton!
    @IBOutlet weak var nonVeganBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func NonVegenBtnPressed(_ sender: Any) {
        
        
        nonVeganBtn.backgroundColor = .clear
        nonVeganBtn.layer.cornerRadius = 10
        nonVeganBtn.layer.borderWidth = 2
        nonVeganBtn.layer.borderColor = UIColor.black.cgColor
        
        
        
        veganBtn.layer.borderColor = UIColor.clear.cgColor
        
        
    }
    @IBAction func VeganBtnPressed(_ sender: Any) {
        
        
        veganBtn.backgroundColor = .clear
        veganBtn.layer.cornerRadius = 10
        veganBtn.layer.borderWidth = 2
        veganBtn.layer.borderColor = UIColor.black.cgColor
        
        nonVeganBtn.layer.borderColor = UIColor.clear.cgColor
        
        
    }
}
