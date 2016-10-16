//
//  Posts.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    var senderId: String!
    var username: String!
    var timestamp: NSNumber!
    var imageUrl: String!
    var isPrivate: Bool!
    var timeout: NSNumber!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.ref = snapshot.ref
        let snap = snapshot.value! as! [String: AnyObject]
        self.senderId = snap["senderId"] as! String
        self.username = snap["username"] as! String
        self.timestamp = snap["timestamp"] as! NSNumber
        self.imageUrl = snap["imageUrl"] as! String
        self.timeout = snap["timeout"] as! NSNumber
        self.isPrivate = snap["isPrivate"] as! Bool
    }
    
    init(key: String = "", senderId: String, username: String, timastamp: NSNumber, imageUrl: String, isPrivate: Bool, timeout: NSNumber) {
        self.senderId = senderId
        self.username = username
        self.timestamp = timastamp
        self.imageUrl = imageUrl
        self.isPrivate = isPrivate
        self.timeout = timeout
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return ["senderId": senderId as AnyObject,
                "username": username as AnyObject,
                "timestamp": timestamp as AnyObject,
                "imageUrl": imageUrl as AnyObject,
                "isPrivate": isPrivate as AnyObject,
                "timeout": timeout as AnyObject]
    }
}
