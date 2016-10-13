//
//  ChatViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController


class ChatViewController: JSQMessagesViewController {

    var chatRoomId: String!
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var userIsTypingRef: FIRDatabaseReference!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Observe the typing user and show the indicator if the other user is typing.
        observeTypingUser()
        
        self.title = "MESSAGES"
        let factory = JSQMessagesBubbleImageFactory()!
        incomingBubbleImageView = factory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let messageQuery = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").queryLimited(toLast: 30)
        messageQuery.observe(.childAdded, with: { (snapshot) in
            let snap = snapshot.value! as! [String: AnyObject]
            let senderId = snap["senderId"] as! String
            let text = snap["text"] as! String
            let displayName = snap["username"] as! String
            self.addMessage(text: text, senderId: senderId, displayName: displayName)
            self.finishSendingMessage()
            
        }) { (error) in
            //let alertView = SCLAlertView()
            print("\(error.localizedDescription)")
            //alertView.showError("Message Error", subTitle: error.localizedDescription)
        }
    }
    
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = (textView.text != "")
    }
    
    private func observeTypingUser() {
        let typingRef = databaseRef.child("ChatRooms").child(chatRoomId).child("typingIndicator")
        userIsTypingRef = typingRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        
        let useristypingQuery = typingRef.queryOrderedByValue().queryEqual(toValue: true)
        useristypingQuery.observe(.value, with: { (snapshot) in
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
        }) { (error) in
            // let alertView = SCLAlertView()
            // alertView.showError("Typing Indicator", subTitle: error.localizedDescription)
        }
    }
    
    
    private func addMessage(text: String, senderId: String, displayName: String) {
        let message = JSQMessage(senderId: senderId, displayName: displayName, text: text)
        messages.append(message!)
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageRef = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
        let message = Message(text: text, senderId: senderId, username: senderDisplayName)
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                self.isTyping = false
            } else {
                let alertView = SCLAlertView()
                alertView.showError("Send Message Error", subTitle: error!.localizedDescription)
                self.isTyping = false
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
        }
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
