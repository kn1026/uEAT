//
//  HomePageVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class HomePageVC: UITabBarController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        //check_condition()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        
        check_condition()
        
        
    }
    
    func generate_menu() {
        
       // let data = ["Name": "Bameee", "Menu_id": "qwertyuiosdfghjk", "Open_hours": ServerValue.timestamp(), "Closed Hours": ServerValue.timestamp(), ""]
        
        
        
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
                                dataStorage.async.removeAll(completion: { (result) in
                                           if case .value = result {
                                               print("Cache cleaned")
                                           }
                                       })
                                 try? storage.removeAll()
                                 
                                
                                 DispatchQueue.main.async { // Make sure you're on the main thread here
                                         self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                 }
                             
                                 return
                             
                         
                             } else {
                                 if snap?.isEmpty == true {
                                     
                                     self.showErrorAlert("Opss !", msg:"User has been removed")
                                     try? storage.removeAll()
                                    dataStorage.async.removeAll(completion: { (result) in
                                               if case .value = result {
                                                   print("Cache cleaned")
                                               }
                                           })
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
                                        dataStorage.async.removeAll(completion: { (result) in
                                                   if case .value = result {
                                                       print("Cache cleaned")
                                                   }
                                               })
                                        try! Auth.auth().signOut()
                                        
                                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                                self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                        }
                                        
                                        return
                                        
                                    }
                                        
                                        if snaps?.isEmpty == true {
                                            
                                            
                                            
                                            try? storage.removeAll()
                                            dataStorage.async.removeAll(completion: { (result) in
                                                       if case .value = result {
                                                           print("Cache cleaned")
                                                       }
                                                   })
                                            try! Auth.auth().signOut()
                                            
                                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                                    self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                                            }
                                            
                                        } else {
                                            
                                            
                                            
                            
                                            
                                        }
                                             
                                        
                                    }
                                    
                                     
                                 }
                             }
                             
                         }
                           
                         return
                         
                     case .error( _):
                         
                         try! Auth.auth().signOut()
                         dataStorage.async.removeAll(completion: { (result) in
                                    if case .value = result {
                                        print("Cache cleaned")
                                    }
                                })
                         try? storage.removeAll()
                         
                         DispatchQueue.main.async { // Make sure you're on the main thread here
                             self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                         }
                         
                         
                     }
                 }
                 
             } else {
                 
                 
                 try! Auth.auth().signOut()
                    
                    dataStorage.async.removeAll(completion: { (result) in
                       if case .value = result {
                           print("Cache cleaned")
                       }
                   })
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
