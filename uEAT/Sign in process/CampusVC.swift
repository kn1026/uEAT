//
//  CampusVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class CampusVC: UIViewController {

    @IBOutlet weak var CampusTxtField: UITextField!
    var campusList = [CampusModel]()
    var campus: String?
    var uniName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        CampusTxtField.becomeFirstResponder()
        createDayPicker()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.endEditing(true)
        
    }
    
    
    func createDayPicker() {
        
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self
        
        //Customizations
        
        
        CampusTxtField.inputView = dayPicker
        
    }

    
    
    @IBAction func back1btnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
        
        if uniName != "", uniName != nil {
            
            
            campus = uniName
            self.performSegue(withIdentifier: "moveToEmailVC", sender: nil)
            
        } else {
            
            
            showErrorAlert("Ops !", msg: "Please choose your campus")
            
            
        }
        
        
        
        
        
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "moveToEmailVC"{
            if let destination = segue.destination as? EmailVC{
                destination.uniName = uniName
                destination.campus = campus
                destination.campusList = campusList
            }
        }
        
        
    }
    
    
    
}

extension CampusVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        
        return campusList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return campusList[row].School_Name
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        
        
        CampusTxtField.text = self.campusList[row].School_Name
        uniName = CampusTxtField.text
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        
        var label: UILabel!
        
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.text = self.campusList[row].School_Name
        uniName = CampusTxtField.text
        label.textAlignment = .center
        return label
        
        
        
        
        
    }
    
    
   


}
