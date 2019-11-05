//
//  HomePageVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class HomePageVC: UITabBarController {

    //@IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        check_condition()
        
    }

    // check condition for login
    
    func check_condition() {
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 storage.async.object(forKey: uid) { result in
                     switch result {
                         
                     case .value(let user):

                         DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: user.uid).getDocuments { (snap, err) in
                         
                         
                             if err != nil {
                             
                                 self.showErrorAlert("Opss !", msg: err.debugDescription)
                                 
                                 try! Auth.auth().signOut()
                                 try? storage.removeAll()
                                 
                                 DispatchQueue.main.async { // Make sure you're on the main thread here
                                         self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                 }
                             
                                 return
                             
                         
                             } else {
                                 if snap?.isEmpty == true {
                                     
                                     self.showErrorAlert("Opss !", msg:"User has been removed")
                                     try? storage.removeAll()
                                     try! Auth.auth().signOut()
                                         
                                         DispatchQueue.main.async { // Make sure you're on the main thread here
                                                 self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                         }
                                     
                                         return
                                     
                                 } else {
                                     
                                    
                                    
                                    DataService.instance.mainFireStoreRef.collection("Cuisine_preference").whereField("userUID", isEqualTo: uid).getDocuments { (snaps, err) in
                                    
                                    if err != nil {
                                        
                                        self.showErrorAlert("Opss !", msg: (err!.localizedDescription))
                                        
                                        try? storage.removeAll()
                                        try! Auth.auth().signOut()
                                        
                                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                                self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                        }
                                        
                                        return
                                        
                                    }
                                        
                                        if snaps?.isEmpty == true {
                                            
                                            
                                            
                                            try? storage.removeAll()
                                            try! Auth.auth().signOut()
                                            
                                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                                    self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                            }
                                            
                                        } else {
                                            
                                            
                                            //self.showErrorAlert("Opss !!!", msg: "Done")
                                            
                                        }
                                             
                                        
                                    }
                                    
                                     
                                 }
                             }
                             
                         }
                           
                         return
                         
                     case .error( _):
                         
                         try! Auth.auth().signOut()
                         try? storage.removeAll()
                         
                         DispatchQueue.main.async { // Make sure you're on the main thread here
                             self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                         }
                         
                         
                     }
                 }
                 
             } else {
                 
                 
                 try! Auth.auth().signOut()
                 try? storage.removeAll()
                 
            
                DispatchQueue.main.async { // Make sure you're on the main thread here
                   self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
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
