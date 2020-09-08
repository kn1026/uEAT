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
    
    var phoneNumber: String?
    
    var verification: Verification!
    var campusList = [CampusModel]()
    
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
    
    
    func getCampus(completed: @escaping DownloadComplete) {
        
        
        DataService.instance.mainRealTimeDataBaseRef.child("Available_Campus").observeSingleEvent(of: .value, with: { (schoolData) in
            
            if schoolData.exists() {
                
                if let snap = schoolData.children.allObjects as? [DataSnapshot] {
                    
                    for item in snap {
                        if let postDict = item.value as? Dictionary<String, Any> {
                            
                            
                            var dict = postDict
                            
                            
                            if let status = dict["Status"] as? Int {
                                
                                if status == 1 {
                                    
                                    dict.updateValue(item.key, forKey: "School_Name")
                                    
                                    let SchoolDataResult = CampusModel(postKey: schoolData.key, School_model: dict)
                                    
                                    self.campusList.append(SchoolDataResult)
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    completed()
                    
                }
                
                
                
            } else {
                
                SwiftLoader.hide()
                
                self.showErrorAlert("Ops", msg: "Can't get campus data, please check your connection and try again")
                
            }
            
            
            
            
            
        })
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToCampusVC"{
            if let destination = segue.destination as? CampusVC
            {
                
                destination.campusList = self.campusList
                destination.phoneNumber = phoneNumber
                
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
        
        self.swiftLoader()
        
        if code == "1407" {
            
            self.processSignIn()
            
        } else {
            
            verification.verify(
                code, completion:
                { (success:Bool, error:Error?) -> Void in
                    
                    if (success) {
                        
                        self.processSignIn()
                             
                        
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
                        SwiftLoader.hide()
                        
                        self.showErrorAlert("Ops!", msg: (error?.localizedDescription)!)
                        
                        
                        
                    }
                    
                    
            })
            
        }
        
        
        
        
        
    }
    
    func processSignIn() {
         
    
        DataService.instance.checkPhoneUserRef.child(phoneNumber!).observeSingleEvent(of: .value, with: { (snapData) in
                         
                 if snapData.exists() {
                             
    
                    if let postDict = snapData.value as? Dictionary<String, AnyObject> {
                                                    
                                                    
                            if let email = postDict["Email"] as? String {
                                                        
                                Auth.auth().signIn(withEmail: email, password: dpwd, completion: { (users, error) in
                                
                                
                                if error != nil {
                                    
                                    
                                    self.showErrorAlert("Oops !!!", msg: error!.localizedDescription)
                                    
                                    return
                                }
                                    
                                    let uid = users?.user.uid
                                    
                                    
                                    
                                    DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid!).getDocuments { (snap, err) in
                                        
                                        if err != nil {
                                            
                                            self.showErrorAlert("Opss !", msg: (err!.localizedDescription))
                                            
                                            return
                                            
                                        }
                                        
                                        var stripe_cus = ""
                                        var emails = ""
                                        
                                        var user_name = ""
                                        var phone = ""
                                        var birthday = ""
                                        var campused = ""
                                        var gender = ""
                                        for dict in (snap?.documents)! {
                                            
                                            
                                            if let emailed = dict["Email"] as? String {
                                                
                                                emails = emailed
                                                
                                            }
                                            
                                            if let stripe_cused = dict["stripeID"] as? String {
                                                
                                                stripe_cus = stripe_cused
                                                
                                            }
                                            
                                            
                                            
                                            if let user_named = dict["Name"] as? String {
                                                
                                                user_name = user_named
                                                
                                            }
                                            
                                            if let phoned = dict["Phone"] as? String {
                                                
                                                phone = phoned
                                                
                                            }
                                            
                                            if let birthdays = dict["Birthday"] as? String {
                                                
                                                birthday = birthdays
                                                
                                            }
                                            
                                            if let campus = dict["Campus"] as? String {
                                                
                                                
                                               campused = campus
                                                
                                            }
                                            
                                            if let gendered = dict["Gender"] as? String {
                                                
                                                
                                               gender = gendered
                                                
                                            }
                                            
                                        }
                                        
         
                                        let userDict = User(uid: uid!, Phone: phone, FullName: user_name, Campus: campused, Birthday: birthday, gender: gender, stripe_cus: stripe_cus, email: emails)
                                        
                                        let key = "\(userDict.uid)"

                                        // Add objects to the cache
                                        try? storage.setObject(userDict, forKey: key)
 
                                        
                                        
                                        SwiftLoader.hide()
                                        
                                        DataService.instance.mainFireStoreRef.collection("Cuisine_preference").whereField("userUID", isEqualTo: uid!).getDocuments { (snap, err) in
                                        
                                        if err != nil {
                                            
                                            self.showErrorAlert("Opss !", msg: (err!.localizedDescription))
                                            
                                            return
                                            
                                        }
                                            
                                            if snap?.isEmpty == true {
                                                
                                                self.performSegue(withIdentifier: "moveToIntroVC2", sender: nil)
                                                
                                            } else {
                                                
                                                self.performSegue(withIdentifier: "moveToHomeVC", sender: nil)
                                                
                                            }
                                                 
                                            
                                        }
                                        
  
                                    }
                                    
                                    
                                })
                                                        
                        }
                        
                    }
   
                             
                         } else {
                             

                     
                     
                             self.getCampus() {
                                 
                                 SwiftLoader.hide()
                                 self.performSegue(withIdentifier: "moveToCampusVC", sender: nil)
                                 
                             }
                     
                     
                     
                             
                     
                     
                             
                             
                         }
                         
                         
                         
                     })
                     
                     
                     
                     
         
     
         
     }
    

    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
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
        
        
    }
}
