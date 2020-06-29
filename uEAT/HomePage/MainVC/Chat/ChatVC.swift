//
//  ChatVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var chatArr = [ChatModel]()
    
    
    var chatUID = ""
    var chatOrderID = ""
    var chatKey = ""
    var displayName = ""
    
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        loadChatOrder()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        
        if chatArr.isEmpty != true {
            
            tableView.restore()
            return 1
            
        } else {
            
            tableView.setEmptyMessage("Loading message !!!")
            return 1
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = chatArr[indexPath.row]
                   
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatCell {

            if indexPath.row != 0 {
                let color = self.view.backgroundColor
                let lineFrame = CGRect(x:0, y:-20, width: self.view.frame.width, height: 40)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = color
                cell.addSubview(line)
                
            }
            
            cell.configureCell(item)

            return cell
                       
        } else {
                       
            return ChatCell()
                       
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = chatArr[indexPath.row]
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 storage.async.object(forKey: uid) { result in
                     switch result {
                         
                     case .value(let user):
                        
                        self.displayName = user.FullName
                        self.chatUID = item.userUID
                        self.chatOrderID = item.order_id
                        self.chatKey = item.chat_key!
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                self.performSegue(withIdentifier: "moveToChatVC", sender: nil)
                        }
                        
                     case .error(let err):
                        
                        self.displayName = "Customer"
                        print(err.localizedDescription)
                        self.chatUID = item.userUID
                        self.chatOrderID = item.order_id
                        self.chatKey = item.chat_key!
                        
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                self.performSegue(withIdentifier: "moveToChatVC", sender: nil)
                        }
                        
                    }
                    
            }
        
        }
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToChatVC") {
            
            
            
            
            let navigationView = segue.destination as! UINavigationController
            let ChatController = navigationView.topViewController as? ChatDetailVC
            

            ChatController?.chatUID = chatUID
            ChatController?.chatOrderID = chatOrderID
            ChatController?.chatKey = chatKey

                  
        }
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        loadChatOrder()
        
    }
    
    func loadChatOrder() {
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            DataService.instance.mainFireStoreRef.collection("Chat_orders").order(by: "timeStamp", descending: true).whereField("userUID", isEqualTo: uid).whereField("Status", isEqualTo: "Open").getDocuments { (snap, err) in
            
            if err != nil {
                
                
                //print(err?.localizedDescription)
                self.showErrorAlert("Opss !", msg: "Can't load your recent messages")
                return
                
                }
                
                self.chatArr.removeAll()
                
                for item in snap!.documents {
                    
                    let i = item.data()
                    let ChatItem = ChatModel(postKey: item.documentID, Chat_model: i)
                    self.chatArr.append(ChatItem)
                    
                    
                    
                }
                
                if self.pullControl.isRefreshing == true {
                    
                    self.pullControl.endRefreshing()
                    
                }
                
                self.tableView.reloadData()
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

    

}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day

        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }

        return "\(secondsAgo / week) weeks ago"
    }
}


extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
