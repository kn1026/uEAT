//
//  PhoneVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class PhoneVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var BackHeight: NSLayoutConstraint!
    @IBOutlet weak var BackWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        phoneTxtField.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        phoneTxtField.delegate = self
        
        phoneTxtField.keyboardType = .numberPad
        
        scaleImageDimension()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        phoneTxtField.becomeFirstResponder()
        
        
        
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
    
}
