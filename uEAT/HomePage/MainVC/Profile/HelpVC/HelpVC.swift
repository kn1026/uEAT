//
//  HelpVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 7/17/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class HelpVC: UIViewController {

    @IBOutlet weak var issueBtn: UIButton!
    var issue_id = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.checkIssue(id: Auth.auth().currentUser!.uid)
        
    }
    
    func checkIssue(id: String) {
        

        
        DataService.instance.mainFireStoreRef.collection("Issues").whereField("Id", isEqualTo: id).whereField("Status", isEqualTo: true).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            
            if snap?.isEmpty == true {
                
                self.issueBtn.setTitle("Start a new issue", for: .normal)
                
            } else {
                
                
                for item in snap!.documents {
                    
                    
                    if let Issue_id = item.data()["Issue_id"] as? String {
                        
                        self.issue_id = Issue_id
                        self.issueBtn.setTitle("Solving current issue", for: .normal)
                        
                        
                    }
                    
                    
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
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func ChatSupportBtnPressed(_ sender: Any) {
        
        if issueBtn.titleLabel?.text == "Start a new issue" {
            
            self.showInputDialog(title: "Please tell us your issue!",
                            subtitle: "After you finish this, we will connect your issue to our supporters !",
                            actionTitle: "Submit",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Issue",
                            inputKeyboardType: .default)
            { (input:String?) in
                if let text = input, text != "" {
                    
                    self.swiftLoader()
                    
                    var ref: DocumentReference? = nil
                    let dict = ["Id": Auth.auth().currentUser?.uid as Any, "Issue": text as Any, "Type": "User" as Any, "Status": true, "timestamp": FieldValue.serverTimestamp()] as [String : Any]
                    ref = DataService.instance.mainFireStoreRef.collection("Issues").addDocument(data: dict) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            DataService.instance.mainRealTimeDataBaseRef.child("newIssueNoti").child("Admin").removeValue()
                            let values: Dictionary<String, AnyObject>  = [text: 1 as AnyObject]
                            DataService.instance.mainRealTimeDataBaseRef.child("newIssueNoti").child("Admin").setValue(values)
                            
                            
                            self.issue_id = ref!.documentID
                            DataService.instance.mainFireStoreRef.collection("Issues").document(ref!.documentID).updateData(["Issue_id": ref!.documentID])
                            let messageRef = DataService.instance.mainRealTimeDataBaseRef.child("Issue_Chat").child(ref!.documentID).child("message")
                            
                            let newMessage = messageRef.childByAutoId()
                            let messageData = ["Text": text, "senderId": Auth.auth().currentUser!.uid, "senderName": "User", "MediaType": "Text", "timestamp": ServerValue.timestamp()] as [String : Any]
                            
                            let chatInformation: Dictionary<String, Any> = ["timeStamp": FieldValue.serverTimestamp(), "LastMessage": text]
                            
                            newMessage.setValue(messageData)
                            DataService.instance.mainFireStoreRef.collection("Chat_issues").document(ref!.documentID).updateData(chatInformation)
                            
                            DataService.instance.mainRealTimeDataBaseRef.child("Issue_Chat_Info").child(ref!.documentID).updateChildValues(["Last_message": text])
                            
                            
                            SwiftLoader.hide()
                            
                            
                            self.performSegue(withIdentifier: "moveToChatIssueVC", sender: self)
                        }
                    }
                    
       
                    
                } else {
                    
                    
                    self.showErrorAlert("No issue found !", msg: "Please provide your issue to continue.")
                    
                }
            }
            
        } else if issueBtn.titleLabel?.text == "Solving current issue" {
            
            
            self.performSegue(withIdentifier: "moveToChatIssueVC", sender: self)
            
            
        } else {
            
            print("3")
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToChatIssueVC") {
            

            let navigationView = segue.destination as! UINavigationController
            let ChatController = navigationView.topViewController as? HelpMessageVC
            
            let uid =  Auth.auth().currentUser?.uid

            ChatController?.chatUID = uid!
            ChatController?.chatOrderID = issue_id
            ChatController?.chatKey = issue_id
            ChatController?.userUID = "Admin"

                  
        }
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


extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}
