//
//  Messages.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import Foundation
import Firebase

struct message {
    var text: String!
    var senderId: String!
    var username: String!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.ref = snapshot.ref
        let snap = snapshot.value! as! [String: AnyObject]
        self.text = snap["text"] as! String
        self.senderId = snap["senderId"] as! String
        self.username = snap["username"] as! String
    }
    
    init(text: String, key: String = "", senderId: String, username: String) {
        self.text = text
        self.senderId = senderId
        self.username = username
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return ["text": text as AnyObject,
                "senderId": senderId as AnyObject,
                "username": username as AnyObject]
    }
}
