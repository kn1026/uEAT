//
//  EmailVerificationVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EmailVerificationVC: UIViewController {

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
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
        Auth.auth().currentUser?.reload(completion: { (err) in
            if err == nil{
                
                userUID = (Auth.auth().currentUser?.uid)!
                
                
                if Auth.auth().currentUser?.isEmailVerified != true {
                    
                    self.showErrorAlert("Oops!", msg: "The email hasn't been verified yet, please check your inbox or resend the email")
                    
                } else {
                    
                   self.performSegue(withIdentifier: "moveToPersonalVC", sender: nil)
                    
                    
                }
                

            } else {
                
                
                self.showErrorAlert("Ops!", msg: "\(err!.localizedDescription)")
                
            }
        })
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
}
