//
//  User.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/21/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    var username: String!
    var email: String?
    var country: String?
    var photoURL: String!
    var biography: String?
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        let snap = snapshot.value! as! [String:AnyObject]
        username = snap["username"] as! String
        email = snap["email"] as? String
        country = snap["country"] as? String
        biography = snap["biography"] as? String
        photoURL = snap["photoURL"] as! String
        uid = snap["uid"] as? String

    }
    
    init(username: String, userId: String, photoUrl: String){
        self.username = username
        self.uid = userId
        self.photoURL = photoUrl
    }
    
}
