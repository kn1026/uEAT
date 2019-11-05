//
//  PersonalInfoVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/24/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseAuth
import Cache
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices



class PersonalInfoVC: UIViewController, UITextFieldDelegate, ZSWTappableLabelTapDelegate {
    
    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    @IBOutlet weak var FoodTxt: UITextField!
    @IBOutlet weak var GenderTxt: UITextField!
    @IBOutlet weak var FullNameTxt: UITextField!
    
    @IBOutlet weak var birthdayTxt: UITextField!
    var Gender = ["Male", "Female"]
    
    
    var phoneNumber: String?
    var email: String?
    var campus: String?
    var uniName: String?
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
        case Privacy = "Privacy"
        case TermsOfUse = "TOU"
        case CodeOfProduct = "COP"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Web-Privacy-Policy.pdf")!
            case .TermsOfUse:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Website-Terms-of-Use.pdf")!
            case .CodeOfProduct:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/User-Code-of-Conduct.pdf")!
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        FullNameTxt.attributedPlaceholder = NSAttributedString(string: "Full name",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        FullNameTxt.delegate = self
        
        birthdayTxt.attributedPlaceholder = NSAttributedString(string: "Birthday mm/dd/yy",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        birthdayTxt.delegate = self
        
        
        GenderTxt.attributedPlaceholder = NSAttributedString(string: "Gender",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        GenderTxt.delegate = self
        
        FoodTxt.attributedPlaceholder = NSAttributedString(string: "Pizza, pasta, beef, ...",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        FoodTxt.delegate = self
        
        termOfUseLbl.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                PersonalInfoVC.URLAttributeName: type.URL
            ]
        })
        
        let string = NSLocalizedString("By clicking Sign Up, you agree to our <link type='TOU'>Terms of use</link>, <link type='Privacy'>Privacy Policy</link> and <link type='COP'>User Code of Conduct</link>.", comment: "")
        
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
        FullNameTxt.becomeFirstResponder()
        
    }
    
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[PersonalInfoVC.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            show(SFSafariViewController(url: URL), sender: self)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func GenderPressed(_ sender: Any) {
        
        createDayPicker()
        
    }

    @IBAction func PressedBirthday(_ sender: Any) {
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        birthdayTxt.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(PersonalInfoVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayTxt.text = dateFormatter.string(from: sender.date)

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
        
        
        GenderTxt.inputView = dayPicker
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    func signUpStripeAccount(email: String, completed: @escaping DownloadComplete) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("customers")
        
        
        Alamofire.request(urls!, method: .post, parameters: [
            
            
            "email": self.email!
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    if let dict = json as? [String: AnyObject] {
                        
                        for i in dict {
                            
                            if i.key == "id" {
                                
                                if let id = i.value as? String {
                                    
                                    if id.contains("cus") {
                                        
                                        
                                        stripeID = id
                                        
                                        completed()
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: error.localizedDescription)
                    
                }
                
        }
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        if GenderTxt.text != "", birthdayTxt.text != "", FullNameTxt.text != "" {
            
            
            swiftLoader()
            
            signUpStripeAccount(email: email!) {
                

                let userUID = Auth.auth().currentUser?.uid

                let user = Register_User (
                    name: self.FullNameTxt.text!,
                    gender: self.GenderTxt.text!,
                    campus: self.uniName!,
                    phone: self.phoneNumber!,
                    email: self.email!,
                    birthday: self.birthdayTxt.text!,
                    userUID: userUID!,
                    stripeID: stripeID
                )

                let db = DataService.instance.mainFireStoreRef.collection("Users")
                
                db.addDocument(data: user.dictionary) { err in
                    
                    if let err = err {
                        
                        self.showErrorAlert("Opss !", msg: err.localizedDescription)
                        
                    } else {
                        

                        guard let fcmToken = Messaging.messaging().fcmToken else { return }
                            
                        DataService.instance.checkEmailUserRef.child(testEmailed).setValue(["Timestamp": ServerValue.timestamp()])
                        DataService.instance.checkPhoneUserRef.child(self.phoneNumber!).setValue(["Timestamp": ServerValue.timestamp(), "Email": self.email!])
                        DataService.instance.mainRealTimeDataBaseRef.child("User").child(userUID!).setValue(["Timestamp": ServerValue.timestamp(), "UID": userUID as Any])   
                        DataService.instance.mainRealTimeDataBaseRef.child("fcmtoken").child(userUID!).child(fcmToken).setValue(1)
                            
                            
                        let userDict = User(uid: userUID!, Phone: self.phoneNumber!, FullName: self.FullNameTxt.text!, Campus: self.campus!, Birthday: self.birthdayTxt.text!, gender: self.GenderTxt.text!, stripe_cus: stripeID, email: self.email!)
                        
                        let key = "\(userDict.uid)"

                        // Add objects to the cache
                        try? storage.setObject(userDict, forKey: key)
                        
                        if let favorite = self.FoodTxt.text, favorite != "" {
                            
                            DataService.instance.mainRealTimeDataBaseRef.child("Favorite_food").child(userUID!).setValue(["Timestamp": ServerValue.timestamp(), "Food": favorite])
                            
                        }
                            
                        SwiftLoader.hide()
                        
                        
                        self.performSegue(withIdentifier: "moveToIntroVC", sender: nil)
                        
                    }
                }
                
            }
            
            
        } else {
            
            
            showErrorAlert("Opss!", msg: "Please fill in all required fields to sign up (Name, gender, birthday)")
            
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

extension PersonalInfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        
        
        GenderTxt.text = Gender[row]
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


extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
