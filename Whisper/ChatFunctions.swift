//
//  ChatFunctions.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import Foundation
import Firebase

struct ChatFunctions {
    
    var chatRoom_id = String()
    
    private var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    mutating func startChat(user1: User, user2: User) {
        let userId1 = user1.uid
        let userId2 = user2.uid
        var chatRoomId = ""
        let comparison = userId1!.compare(userId2!).rawValue
        let members = [user1.username!, user2.username!]
        if comparison < 0 {
            chatRoomId = userId1!.appending(userId2!)
        } else {
            chatRoomId = userId2!.appending(userId1!)
        }
        
        self.chatRoom_id = chatRoomId
        self.createChatRoomId(user1: user1, user2: user2, members: members, chatRoomId: chatRoomId)
    }
    
    private func createChatRoomId(user1: User, user2: User, members: [String], chatRoomId: String) {
        
        let chatRoomRef = databaseRef.child("ChatRooms").queryOrdered(byChild: "chatRoomId").queryEqual(toValue: chatRoomId)
        chatRoomRef.observeSingleEvent(of: .value, with: { (snapshot) in
        //chatRoomRef.observe(.value, with: { (snapshot) in
            var createChatRoom = true
            
            // Just for test.
            // print("\n\n\n")
            // print(snapshot)
            // print("\n\n\n")
            if snapshot.exists() {
                for chatRoom in (snapshot.value! as AnyObject).allValues {
                    let chatRoomANO = chatRoom as! [String: AnyObject]
                    if chatRoomANO["chatRoomId"] as! String == chatRoomId {
                        createChatRoom = false
                    }
                }
            }
            if createChatRoom {
                self.createNewChatRoomId(username: user1.username, other_Username: user2.username, userId: user1.uid, other_UserId: user2.uid, members: members, chatRoomId: chatRoomId, lastMessage: "", userPhotoUrl: user1.photoURL, other_UserPhotoUrl: user2.photoURL)
            }
            // Just for test.
            // print("\n\n\n\n\n\(createChatRoom)\n\n\n\n\n")
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
        
    }
    
    private func createNewChatRoomId(username: String, other_Username: String, userId: String, other_UserId: String, members: [String], chatRoomId: String, lastMessage: String, userPhotoUrl: String, other_UserPhotoUrl: String) {
        
        let newChatRoom = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl)
        
        let chatRoomRef = databaseRef.child("ChatRooms").child(chatRoomId)
        chatRoomRef.setValue(newChatRoom.toAnyObject())
        
    }
    
}
