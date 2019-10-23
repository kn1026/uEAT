//
//  EmailVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EmailVC: UIViewController {

    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var DomainLbl: UILabel!
    
    
    var campus: String?
    var uniName: String?
    var campusList = [CampusModel]()
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for i in campusList {
            
            if campus == i.School_Name {
                DomainLbl.text = i.Domain
                emailLbl.becomeFirstResponder()
                break
            }
        }
        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.endEditing(true)
    }
    

    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
        if emailLbl.text != "" {
            
            if let email = emailLbl.text {
                
                var finalEmail = ""
                
                if DomainLbl.text == "Any email" {
                    
                    finalEmail = email
                    
                    
                } else {
                    
                    finalEmail = email + DomainLbl.text!
                    
                    
                }
                
                self.email = finalEmail
                 
                swiftLoader()
                 
                 
                
                 var  dotCount = [Int]()
                 var count = 0
                 var testEmails = ""
                 
                 
                 var testEmailArr = Array(finalEmail)
                 for _ in 0..<(testEmailArr.count) {
                     if testEmailArr[count] == "." {
                         
                         dotCount.append(count)
                         
                     }
                     count += 1
                 }
                 
                 
                 
                 for indexCount in dotCount {
                     testEmailArr[indexCount] = ","
                     let testEmail = String(testEmailArr)
                     testEmails = testEmail
                     testEmailed = testEmail
                     
                 }
                
                
                
                
                Auth.auth().createUser(withEmail: finalEmail, password: dpwd, completion: { (user, error) in
                    
                    
                    
                    if error != nil {

                        DataService.instance.checkEmailUserRef.child(testEmails).observeSingleEvent(of: .value, with: { (snapData) in
                            
                            
                            if snapData.exists() {
                                
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Oopss !!!", msg: "This email has been used")
                                return
                                
                            } else {
                                
                                Auth.auth().signIn(withEmail: finalEmail, password: dpwd, completion: { (users, error) in
                                    
                                    
                                    if error != nil {
                                        
                                        SwiftLoader.hide()
                                        self.showErrorAlert("Ops!", msg: (error?.localizedDescription)!)
                                        return
                                    }
                                    if users?.user.isEmailVerified == true {
                                        
                                        users?.user.delete(completion: { (err) in
                                            
                                            if err != nil {
                                                
                                                 SwiftLoader.hide()
                                                self.showErrorAlert("Ops!", msg: (err?.localizedDescription)!)
                                                return
                                                
                                            }
                                            
                                            Auth.auth().createUser(withEmail: finalEmail, password: dpwd, completion: { (usered, error) in
                                                
                                                if error != nil {
                                                    
                                                    
                                                     SwiftLoader.hide()
                                                    self.showErrorAlert("Ops!", msg: (err?.localizedDescription)!)
                                                    
                                                    return
                                                }
                                                
                                                usered?.user.sendEmailVerification(completion: { (err) in
                                                    if err != nil {
                                                        
                                                        
                                                         SwiftLoader.hide()
                                                        self.showErrorAlert("Ops!", msg: "Couldn't verify this email")
                                                        return
                                                        
                                                    }
                                                    SwiftLoader.hide()
                                                    self.performSegue(withIdentifier: "moveToEmailVerificationVC", sender: nil)
                                                })
                                                
                                            })
                                            
                                        })
                                        
                                        
                                        
                                    } else {
                                        
                                        
                                        
                                        
                                        users?.user.sendEmailVerification(completion: { (err) in
                                            if err != nil {
                                                
                                                SwiftLoader.hide()
                                                self.showErrorAlert("Oopss !!!", msg: "Couldn't verify this email")
                                                return
                                                
                                            }
                                            SwiftLoader.hide()
                                            self.performSegue(withIdentifier: "moveToEmailVerificationVC", sender: nil)
                                            
                                            
                                        })
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                    
                                })
                                
                            }
                            
                        })
                        
                    } else {
                        
                        
                        user?.user.sendEmailVerification(completion: { (err) in
                            if err != nil {
                                
                                self.showErrorAlert("Ops!", msg: "Couldn't verify this email")
                                return
                                
                            }

                            SwiftLoader.hide()
                            self.performSegue(withIdentifier: "moveToEmailVerificationVC", sender: nil)
                            
                        })
                        
                        
                    }
                    
                    
                    
                    
                })
                
                
            }
           
            
        } else {
            
            
            
            self.showErrorAlert("Ops!", msg: "Please enter your email id to continue")
            
        }
        
        
    }
    
    
    // func show error alert
    
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
    
    
}
