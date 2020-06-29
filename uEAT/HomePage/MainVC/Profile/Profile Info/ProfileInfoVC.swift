//
//  ProfileInfoVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/25/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ProfileInfoVC: UIViewController {

    @IBOutlet weak var genderTxtField: modTxtField!
    @IBOutlet weak var BirthdayTxtField: modTxtField!
    @IBOutlet weak var nameTxtField: modTxtField!
    
    var Gender = ["Male", "Female", "Other"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 storage.async.object(forKey: uid) { result in
                     switch result {
                         
                     case .value(let user):
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            self.genderTxtField.attributedPlaceholder = NSAttributedString(string: user.gender,
                                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                            
                            self.BirthdayTxtField.attributedPlaceholder = NSAttributedString(string: user.Birthday,
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                            
                            self.nameTxtField.attributedPlaceholder = NSAttributedString(string: user.FullName,
                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                        
                        }
                                                
                     case .error(let err):
                        
                        print(err.localizedDescription)
                        
                    }
                    
            }
            
        }
        
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        
        swiftLoader()
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments { (snap, err) in
                      
                      
                          if err != nil {
                            
                            SwiftLoader.hide()
                            self.showErrorAlert("Opss !", msg: err.debugDescription)
        
                          } else {
                              if snap?.isEmpty != true {
                                  
                                  for dict in (snap?.documents)! {
                                      
                                    let id = dict.documentID
                                    
                                    if let name = self.nameTxtField.text, name != "" {
                                        
                                       
                                        if let uid = Auth.auth().currentUser?.uid, uid != "" {
                                        
                                                 // Fetch object from the cache
                                                 storage.async.object(forKey: uid) { result in
                                                    switch result {
                                                    
                                                    case .value(let user):
                                                       
                                                        let userDict = User(uid: user.uid, Phone: user.Phone, FullName: name, Campus: user.FullName, Birthday: user.Birthday, gender: user.gender, stripe_cus: user.stripe_cus, email: user.email)
                                                        
                                                        let key = "\(userDict.uid)"
                                                        
                                                        //
                                                        DataService.instance.mainFireStoreRef.collection("Users").document(id).updateData(["Name": name])

                                                        // Add objects to the cache
                                                        try? storage.removeObject(forKey: key)
                                                        try? storage.setObject(userDict, forKey: key)
                                                                               
                                                    case .error(let err):
                                                       
                                                        print(err.localizedDescription)
                                                    
                                            }
                                                    
                                            }
                                            
                                        }
                                        
                                    } else if let gender = self.genderTxtField.text, gender != "" {
                                        
                                        
                                        if let uid = Auth.auth().currentUser?.uid, uid != "" {
                                        
                                                 // Fetch object from the cache
                                                 storage.async.object(forKey: uid) { result in
                                                    switch result {
                                                    
                                                    case .value(let user):
                                                       
                                                        let userDict = User(uid: user.uid, Phone: user.Phone, FullName: user.FullName, Campus: user.FullName, Birthday: user.Birthday, gender: gender, stripe_cus: user.stripe_cus, email: user.email)
                                                        
                                                        let key = "\(userDict.uid)"
                                                        
                                                        //
                                                        
                                                        //
                                                        DataService.instance.mainFireStoreRef.collection("Users").document(id).updateData(["Gender": gender])

                                                        // Add objects to the cache
                                                        try? storage.removeObject(forKey: key)
                                                        try? storage.setObject(userDict, forKey: key)
                                                                               
                                                    case .error(let err):
                                                       
                                                        print(err.localizedDescription)
                                                    
                                            }
                                                    
                                            }
                                            
                                        }
                                        
                                        
                                    } else if let birthday = self.BirthdayTxtField.text, birthday != "" {
                                        
                                        
                                        if let uid = Auth.auth().currentUser?.uid, uid != "" {
                                        
                                                 // Fetch object from the cache
                                                 storage.async.object(forKey: uid) { result in
                                                    switch result {
                                                    
                                                    case .value(let user):
                                                       
                                                        let userDict = User(uid: user.uid, Phone: user.Phone, FullName: user.FullName, Campus: user.FullName, Birthday: birthday, gender: user.gender, stripe_cus: user.stripe_cus, email: user.email)
                                                        
                                                        let key = "\(userDict.uid)"
                                                        
                                                        //
                                                        //
                                                        DataService.instance.mainFireStoreRef.collection("Users").document(id).updateData(["Birthday": birthday])

                                                        // Add objects to the cache
                                                        try? storage.removeObject(forKey: key)
                                                        try? storage.setObject(userDict, forKey: key)
                                                                               
                                                    case .error(let err):
                                                       
                                                        print(err.localizedDescription)
                                                    
                                            }
                                                    
                                            }
                                            
                                        }
                                        
                                    } else {
                                        
                                        print("nil")
                                        
                                    }
                                }
                                
                                SwiftLoader.hide()
                                
                            }
                            
                            
                            
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
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func birthdayPressed(_ sender: Any) {
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        BirthdayTxtField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(PersonalInfoVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @IBAction func genderPressed(_ sender: Any) {
        
        createDayPicker()
        
    }
    
   
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        BirthdayTxtField.text = dateFormatter.string(from: sender.date)

    }
    
    func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return nil
        
    }
    
    
    func createDayPicker() {
        
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self

        //Customizations
        
        
        genderTxtField.inputView = dayPicker
        
        
    }
    
}
extension ProfileInfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        
        return 1
            
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return Gender.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        
        return Gender[row]
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        genderTxtField.text = Gender[row]
        //GenderSelected = GenderTxt.text
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel!
        
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.text = Gender[row]
        
        label.textAlignment = .center
        return label

        
    }
}
