//
//  PhoneVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SinchVerification


class PhoneVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var BackHeight: NSLayoutConstraint!
    @IBOutlet weak var BackWidth: NSLayoutConstraint!
    
    var verification: Verification!
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        phoneTxtField.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        phoneTxtField.delegate = self
        
        phoneTxtField.keyboardType = .numberPad
        
        scaleImageDimension()
        
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
        
        phoneTxtField.becomeFirstResponder()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.endEditing(true)
    }
    
    
    func scaleImageDimension() {
        
        BackWidth.constant = self.view.frame.width * (BackWidth.constant / CGFloat(ratio_width))
        BackHeight.constant = self.view.frame.height * (BackHeight.constant / CGFloat(ratio_height))
        

    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        textField.text = formattedNumber(number: newString)
        return false
        
    }
    
    private func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        
        return result
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        
        if let phone = phoneTxtField.text, phone != "" {
              
              let converted = convertPhoneNumber(Phone: phone)
        
              if converted.count != 10 {
                  
                  self.showErrorAlert("Ops !", msg: "Your phone number is invalid")
                  
              } else {
                
                self.swiftLoader()
                var finalPhone = ""
                
                if converted == "0879565629" {
                    
                    finalPhone = "+84879565629"
                    
                } else {
                    
                    
                    finalPhone = "+1\(converted)"
                    
                }
                
                
                
                  
                  
                  self.verification = SMSVerification(applicationKey, phoneNumber: finalPhone)
                  
                  
                  self.verification.initiate { (result: InitiationResult, error:Error?) -> Void in
                      
                      if error != nil {
                          
                          SwiftLoader.hide()
                          self.showErrorAlert("Ops !", msg: (error?.localizedDescription)!)
                          
                          
                          return
                      }
                      
                      SwiftLoader.hide()
                    
                      self.phoneNumber = finalPhone
                      self.performSegue(withIdentifier: "moveToPhoneVeriVC", sender: nil)
                      
                      
                  }
                  
              }
              
          } else {
              
            
            SwiftLoader.hide()
            self.showErrorAlert("Ops!!!", msg: "Please enter your phone number")
              
          }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToPhoneVeriVC"{
            if let destination = segue.destination as? PhoneVeriVC
            {
                
             
                destination.verification = verification
                destination.phoneNumber = phoneNumber
                
            }
        }
        
        
    }
    
    func convertPhoneNumber(Phone: String) -> String {
        
        let arr = Array(Phone)
        var new = [String]()
        
        for i in arr {
            
            if i != "(", i != ")", i != " ", i != "-" {
                
                
                new.append(String((i)))
                
            
            }
            
        }
        
        let stringRepresentation = new.joined(separator:"")
        
        
        return stringRepresentation
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
}


private var kAssociationKeyMaxLength: Int = 0

extension UITextField {

    @IBInspectable var maxLength: Int {
        
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
        
    }

    @objc func checkMaxLength(textField: UITextField) {
        
        
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }

        let selection = selectedTextRange

        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)

        selectedTextRange = selection
        
    }
}
