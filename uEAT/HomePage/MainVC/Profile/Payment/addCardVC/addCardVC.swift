//
//  addCardVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import Firebase

class addCardVC: UIViewController, STPPaymentCardTextFieldDelegate {

    
    @IBOutlet weak var paymentField: UIView!
    var ids = ""
    var cardField = STPPaymentCardTextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        cardField.delegate = self
        // Do any additional setup after loading the view.
        paymentField.addSubview(cardField)
        title = "Card Field"
        cardField.textColor = UIColor.black
        cardField.postalCodeEntryEnabled = true
        cardField.borderWidth = 1.0
        
        edgesForExtendedLayout = []
        cardField.becomeFirstResponder()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let padding: CGFloat = 15
        cardField.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.bounds.width - (padding * 2),
                                 height: 50)
    }
    
 
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        

        
    }

    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if cardField.cardParams.cvc != "", cardField.cardParams.number != "" {
            
            swiftLoader()
            
            let card: STPCardParams = STPCardParams()
            
            
            card.number = cardField.cardParams.number
            card.expMonth = cardField.cardParams.expMonth as! UInt
            card.expYear = cardField.cardParams.expYear as! UInt
            card.cvc = cardField.cardParams.cvc
            
            
           
            
            
            if STPCardValidator.validationState(forCard: card) == .valid {
                // the card is valid.
                
                let url = MainAPIClient.shared.baseURLString
                let urls = URL(string: url!)?.appendingPathComponent("retrieve_token")
                
                 Alamofire.request(urls!, method: .post, parameters: [
                 
                    "number": card.number!,
                    "exp_month": card.expMonth,
                    "exp_year": card.expYear,
                    "cvc": card.cvc!
                 
                 ])
                 
                 .validate(statusCode: 200..<500)
                 .responseJSON { responseJSON in
                 
                switch responseJSON.result {
                 
                    case .success(let json):
                 
                        SwiftLoader.hide()
                        if let dict = json as? [String: AnyObject] {
                        
                            
                            
                           for i in dict {
                            
                            if i.key == "id" {
                                
                                self.ids = (i.value as? String)!
                                
                            }
                         
                            if i.key == "card" {
                                
                                if let result = i.value as? [String: AnyObject] {
                                    
                                    if let fingerprint = result["fingerprint"] as? String {
                                        
                                    DataService.instance.mainRealTimeDataBaseRef.child("fingerPrint").child(Auth.auth().currentUser!.uid).child(fingerprint).observeSingleEvent(of: .value, with: { (snapData) in
                                            
                                            if snapData.exists() {
                                                
                                                SwiftLoader.hide()
                                                self.showErrorAlert("Oopps !!!", msg: "This card has been added with your account")
                                                
                                            } else {
                                                
                                                if let uid = Auth.auth().currentUser?.uid, uid != "" {
                                                
                                                         // Fetch object from the cache
                                                         storage.async.object(forKey: uid) { result in
                                                             switch result {
                                                                 
                                                             case .value(let user):

                                                                let stripeIDed = user.stripe_cus
                                                                
                                                                let urlss = URL(string: url!)?.appendingPathComponent("card")
                                                                
                                                                Alamofire.request(urlss!, method: .post, parameters: [
                                                                    
                                                                    "cus_id": stripeIDed,
                                                                    "source": self.ids
                                                                    
                                                                    ])
                                                                    
                                                                    
                                                                    
                                                                    .validate(statusCode: 200..<500)
                                                                    .responseJSON { responseJSON in
                                                                        
                                                                        switch responseJSON.result {
                                                
                                                                        case .success(let json):
                                                                            
                                                                            if let dict = json as? [String: AnyObject] {
                                                                                
                                                                                
                                                                                for i in dict {
                                                                                
                                                                                if i.key == "id" {
                                                                                    
                                                                                                        DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snap) in
                                                                                    
                                                                                        if snap.exists() {
                                                                                        
                                                                                            DataService.instance.mainRealTimeDataBaseRef.child("fingerPrint").child(Auth.auth().currentUser!.uid).child(fingerprint).setValue(["Timestamp": ServerValue.timestamp()])
                                                                                            SwiftLoader.hide()
                                                                                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshPayment")), object: nil)
                                                                                            self.dismiss(animated: true, completion: nil)
                                                                                            
                                                                                        } else {
                                                                                            
                                                                                            
                                                                                            DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).child(i.value as! String).setValue(["Timestamp": ServerValue.timestamp()])
                                                                                            
                                                                                            DataService.instance.mainRealTimeDataBaseRef.child("fingerPrint").child(Auth.auth().currentUser!.uid).child(fingerprint).setValue(["Timestamp": ServerValue.timestamp()])
                                                                                            SwiftLoader.hide()
                                                                                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshPayment")), object: nil)
                                                                                            self.dismiss(animated: true, completion: nil)
                                                                                            
                                                                                        }
                                                                                        
                                                                                    })
                                                                                    
                                                                                }
                                                                                
                                                                               }
                                                                            }
                                                                            
                                                                            
                                                                        
                                                                            
                                                                            
                                                                        case .failure(let errors):
                                                                            
                                                                            SwiftLoader.hide()
                                                                            print(errors.localizedDescription)
                                                                            self.showErrorAlert("Oopps !!!", msg: "Invalid card, please re-type or use another card")
                                                                            
                                                                            
                                                                        }
                                                                        
                                                                        
                                                                        
                                                                }
                                                                 
                                                             case .error( _):
                                                                 
                                                                 
                                                                 SwiftLoader.hide()
                                                                 self.showErrorAlert("Oopps !!!", msg: "Can't add card right now, please sign out and sign in to do it")
                                                                 
                                                             }
                                                         }
                                                         
                                                     }
                                                
                                                
                                            }
                                            
                                            
                                        })
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                            
                        }
                 
                case .failure( _):
                 
                        SwiftLoader.hide()
                        
                        self.showErrorAlert("Oopps !!!", msg: "Invalid card, please re-type or use another card")
                 
                 
                 }
                 
                 
                 
                 }
                 
                 
                
                
            }
            
            
        }
    }
    
}
