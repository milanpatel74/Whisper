//: Playground - noun: a place where people can play

import UIKit


var str = "Hello, playground"
NSNumber(value: NSDate().timeIntervalSince1970)
NSDate().timeIntervalSince1970



// 获取当前时间的 timestamp
let timestamp = String(Date().timeIntervalSince1970)

NSNumber(value: Int(Date().timeIntervalSince1970))

var dict = [String: Bool]()
dict["1"] = true
dict["2"] = true
dict["2"]


//let string = String(string: timestamp)
let date = Date(timeIntervalSince1970: Double(timestamp)!)
var dateFormatter = DateFormatter()
dateFormatter.dateFormat = "HH:mm a 'on' MMMM dd, yyyy"
var dateString = dateFormatter.string(from: date)


let a: NSNumber = 33333
let b = String(describing: a)