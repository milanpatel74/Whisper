//
//  ChatRoom.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import Foundation
import Firebase

struct ChatRoom {
    var username: String!
    var other_Username: String!
    var userId: String!
    var other_UserId: String!
    var members: [String]!
    var chatRoomId: String!
    var lastMessage: String!
    var userPhotoUrl: String!
    var other_UserPhotoUrl: String!
    var key: String = ""
    var date: NSNumber!
    var ref: FIRDatabaseReference!
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.ref = snapshot.ref
        let snap = snapshot.value! as! [String: AnyObject]
        self.username = snap["username"] as! String
        self.other_Username = snap["other_Username"] as! String
        self.userId = snap["userId"] as! String
        self.other_UserId = snap["other_UserId"] as! String
        self.members = snap["members"] as! [String]
        self.chatRoomId = snap["chatRoomId"] as! String
        self.lastMessage = snap["lastMessage"] as! String
        self.userPhotoUrl = snap["userPhotoUrl"] as! String
        self.other_UserPhotoUrl = snap["other_UserPhotoUrl"] as! String
        self.date = snap["date"] as! NSNumber
    }
    
    init(username: String, other_Username: String, userId: String, other_UserId: String, members: [String], chatRoomId: String, lastMessage: String, userPhotoUrl: String, other_UserPhotoUrl: String, key: String = "", date: NSNumber!) {
        self.username = username
        self.other_Username = other_Username
        self.userId = userId
        self.other_UserId = other_UserId
        self.members = members
        self.chatRoomId = chatRoomId
        self.lastMessage = lastMessage
        self.userPhotoUrl = userPhotoUrl
        self.other_UserPhotoUrl = other_UserPhotoUrl
        self.date = date
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return ["username": username as AnyObject,
                "other_Username": other_Username as AnyObject,
                "userId": userId as AnyObject,
                "other_UserId": other_UserId as AnyObject,
                "members": members as AnyObject,
                "chatRoomId": chatRoomId as AnyObject,
                "lastMessage": lastMessage as AnyObject,
                "userPhotoUrl": userPhotoUrl as AnyObject,
                "other_UserPhotoUrl": other_UserPhotoUrl as AnyObject,
                "date": date as AnyObject]
    }
    
    
}
