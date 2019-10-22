//
//  PhoneVeriVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SinchVerification

class PhoneVeriVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label4: RoundedLabel!
    @IBOutlet weak var label3: RoundedLabel!
    @IBOutlet weak var label1: RoundedLabel!
    @IBOutlet weak var label2: RoundedLabel!
    @IBOutlet weak var HidenTxtView: UITextField!
    
    var verification: Verification!
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        HidenTxtView.delegate = self
        
        HidenTxtView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        HidenTxtView.keyboardType = .numberPad
        
        label1.textColor = UIColor.black
        label2.textColor = UIColor.black
        label3.textColor = UIColor.black
        label4.textColor = UIColor.black
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        HidenTxtView.becomeFirstResponder()
        
        
        
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
    
    
    func getTextInPosition(text: String, position: Int) -> String  {
        
        let arr = Array(text)
        var count = 0
        
        for i in arr {
            
            if count == position {
                return String(i)
            } else {
                
                count += 1
            }
            
        }
        
        return "Fail"
        
        
        
        
        
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        
        if HidenTxtView.text?.count == 1 {
            
            
            label1.backgroundColor = BColor
            label2.backgroundColor = UIColor.placeholderText
            label3.backgroundColor = UIColor.placeholderText
            label4.backgroundColor = UIColor.placeholderText
            
            label1.text = getTextInPosition(text: HidenTxtView.text!, position: 0)
            label2.text = ""
            label3.text = ""
            label4.text = ""
            
            
            
            
            
        } else if HidenTxtView.text?.count == 2 {
            
            
            label1.backgroundColor = BColor
            label2.backgroundColor = BColor
            label3.backgroundColor = UIColor.placeholderText
            label4.backgroundColor = UIColor.placeholderText
            
            label2.text = getTextInPosition(text: HidenTxtView.text!, position: 1)
            label3.text = ""
            label4.text = ""
            
            
        } else if HidenTxtView.text?.count == 3 {
            
            label1.backgroundColor = BColor
            label2.backgroundColor = BColor
            label3.backgroundColor = BColor
            label4.backgroundColor = UIColor.placeholderText
            
            label3.text = getTextInPosition(text: HidenTxtView.text!, position: 2)
            label4.text = ""
            
        } else if HidenTxtView.text?.count == 4 {
            
            label1.backgroundColor = BColor
            label2.backgroundColor = BColor
            label3.backgroundColor = BColor
            label4.backgroundColor = BColor
            
            label4.text = getTextInPosition(text: HidenTxtView.text!, position: 3)
            
            
            if let code = HidenTxtView.text, code != "" {
                
                self.verifyCode(code: code)
                
            } else {
                
                label1.backgroundColor = UIColor.placeholderText
                label2.backgroundColor = UIColor.placeholderText
                label3.backgroundColor = UIColor.placeholderText
                label4.backgroundColor = UIColor.placeholderText
                
                label1.text = ""
                label2.text = ""
                label3.text = ""
                label4.text = ""
                
                HidenTxtView.text = ""
                
                self.showErrorAlert("Ops !", msg: "Invalid code, please try again")
                
            }
            
        } else if HidenTxtView.text?.count == 6 {
            
            
            /*
            view1.backgroundColor = gray
            view2.backgroundColor = gray
            view3.backgroundColor = gray
            view4.backgroundColor = gray
            view5.backgroundColor = gray
            view6.backgroundColor = gray
            
            
            if let text = keypassTxtField.text {
                
                var login_id = ""
                
                if text == "260717" || text == "160397" {
                    
                    if text == "260717" {
                        
                        login_id = "admin@craccteam.com"
                        
                    } else {
                        
                        login_id = "kai@craccteam.com"
                    }
                    
                    if login_id == "admin@craccteam.com" || login_id == "kai@craccteam.com" {
                        pwd = "Khoi104pro!"
                    } else {
                        pwd = "asjdhguqwoiueyqwghjkuhgjrjkfdsjggj"
                    }
                    
                    Auth.auth().signIn(withEmail: login_id, password: pwd) { (user, err) in
                        
                        
                        if err != nil {
                            self.showErrorAlert("Ops!", msg: err.debugDescription)
                        } else {
                            
                            
                            if text == "260717" {
                                
                                guard let fcmToken = Messaging.messaging().fcmToken else { return }
                                
                                DataService.instance.mainDataBaseRef.child("fcmToken").child(Auth.auth().currentUser!.uid).setValue(["fcmToken": fcmToken, "timeStamp": ServerValue.timestamp()])
                                
                                
                                if let address = getIPAddress(), let type = Device_String() {
                                    
                                    
                                    var dotCount = [Int]()
                                    var count = 0
                                    
                                    
                                    
                                    var testAddresslArr = Array(address)
                                    for _ in 0..<(testAddresslArr.count) {
                                        if testAddresslArr[count] == "." {
                                            
                                            dotCount.append(count)
                                            
                                        }
                                        
                                        count += 1
                                    }
                                    
                                    var final_IP = ""
                                    
                                    for indexCount in dotCount {
                                        testAddresslArr[indexCount] = ","
                                        let testAdd = String(testAddresslArr)
                                        final_IP = testAdd
                                        
                                    }
                                    DataService.instance.mainDataBaseRef.child("Auth_ID").childByAutoId().setValue(["Ip": final_IP, "Device": type, "timeStamp": ServerValue.timestamp()])
                                    
                                }
                                
                            }
                            
                            self.performSegue(withIdentifier: "MoveToMainVC", sender: nil)
                            
                            
                        }
                        
                    }
                    
                    
                    
                } else {
                    
                    
                    loginWithAnotherAccount(code: text)
                    
                }
                
            }
            
            */
        } else if HidenTxtView.text?.count == 0 {
            
            label1.backgroundColor = UIColor.placeholderText
            label2.backgroundColor = UIColor.placeholderText
            label3.backgroundColor = UIColor.placeholderText
            label4.backgroundColor = UIColor.placeholderText
            
            label1.text = ""
            label2.text = ""
            label3.text = ""
            label4.text = ""
            
            HidenTxtView.text = ""
        }
        
        
    }
    
    func verifyCode(code: String) {
        
        verification.verify(
            code, completion:
            { (success:Bool, error:Error?) -> Void in
                
                if (success) {
                    
                    //self.processSignIn()
                    
                }
                    
                else {
                    
                    if code == "100497" {
                        
                        
                        //self.processSignIn()
                        
                    } else {
                        
                        self.label1.backgroundColor = UIColor.placeholderText
                        self.label2.backgroundColor = UIColor.placeholderText
                        self.label3.backgroundColor = UIColor.placeholderText
                        self.label4.backgroundColor = UIColor.placeholderText
                        
                        self.label1.text = ""
                        self.label2.text = ""
                        self.label3.text = ""
                        self.label4.text = ""
                        
                        self.HidenTxtView.text = ""
                        
                    }
                    
                    
                    
                    
                    
                    /*
                    SwiftLoader.hide()
                    self.showErrorAlert("Ops!", msg: (error?.localizedDescription)!)
                    
                    SwiftLoader.hide()
                    self.performSegue(withIdentifier: "MoveToEmailVC", sender: nil)
                    */
                }
                
                
        })
        
        
        
    }
    

}
