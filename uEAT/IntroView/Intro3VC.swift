//
//  Intro3VC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/31/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase


class Intro3VC: UIViewController {

    @IBOutlet weak var veganBtn: UIButton!
    @IBOutlet weak var nonVeganBtn: UIButton!
    
    
    var itemList = [String]()
    var pref = ""
    
    
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
        
        pref = "Non-vegan"
        
        
    }
    @IBAction func VeganBtnPressed(_ sender: Any) {
        
        
        veganBtn.backgroundColor = .clear
        veganBtn.layer.cornerRadius = 10
        veganBtn.layer.borderWidth = 2
        veganBtn.layer.borderColor = UIColor.black.cgColor
        nonVeganBtn.layer.borderColor = UIColor.clear.cgColor
        
        pref = "Vegan"
        
        
    }
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        if pref != "" {
            
       
            let data = ["Cuisine_list": itemList, "Preference": pref, "timeStamp": ServerValue.timestamp(), "userUID": Auth.auth().currentUser?.uid as Any] as [String : Any]
            updateCuisine(Cuisine_data: data)
            
        } else {
            
            self.showErrorAlert("Opss !", msg: "Please choose your preference as Vegan or Non-vegan")
            
            
        }
        
    }
    
    func updateCuisine(Cuisine_data: Dictionary<String, Any>) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Cuisine_preference")
        
        db.addDocument(data: Cuisine_data) { err in
            
            if let err = err {
                
                self.showErrorAlert("Opss !", msg: err.localizedDescription)
                
            } else {
                
                
                self.performSegue(withIdentifier: "moveToHomeVC2", sender: nil)
                
                
            }
        }
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
