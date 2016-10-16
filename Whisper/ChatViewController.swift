//
//  ChatViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/13.
//  Copyright © 2016年 unimelb. All rights reserved.
//

// 待修复的BUG：并不能判断Media消息来自于哪边，都默认当作发出的消息

import UIKit
import Firebase
import JSQMessagesViewController
import MobileCoreServices
import AVKit


class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Firebase references.
    var storageRef: FIRStorageReference! { return FIRStorage.storage().reference() }
    var databaseRef: FIRDatabaseReference! { return FIRDatabase.database().reference() }
    var userIsTypingRef: FIRDatabaseReference!
    
    var chatRoomId: String!
    
    // Store all messages of a chat in an array.
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!

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
        
        // Observe the typing user and show the indicator if the other user is typing.
        observeTypingUser()
        
        self.title = "MESSAGES"
        
        let factory = JSQMessagesBubbleImageFactory()!
        incomingBubbleImageView = factory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Change the background wallpaper of this chatroom.
        collectionView.backgroundView = UIImageView.init(image: UIImage(named: "wallpaper-2"))
        
        // fetch all messages from the firebase realtime database.
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 当聊天页面被打开时，抓取数据。
        fetchMessges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 当聊天页面关闭的时候，删掉所有的Observer，以免消息在没有看的情况下被删除。
        databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").removeAllObservers()
    }
    
    // 获取信息（当获取信息的时候，将对方的信息置为已读）
    func fetchMessges() {
        
        //messages.removeAll(keepingCapacity: false)
        let messageQuery = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").queryLimited(toLast: 30)
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            //print("----------------------------------------------------------------------")
            //print("Message:")
            //print(snapshot.key)
            //print(snapshot)
            //print("----------------------------------------------------------------------")
            
            let snap = snapshot.value! as! [String: AnyObject]
            let senderId = snap["senderId"] as! String
            let text = snap["text"] as! String
            let displayName = snap["username"] as! String
            let mediaType = snap["mediaType"] as! String
            let mediaUrl = snap["mediaUrl"] as! String
            //self.addMessage(text: text, senderId: senderId, displayName: displayName)
            
            
            
            switch mediaType {
            case "TEXT":
                let message = JSQMessage(senderId: senderId, displayName: displayName, text: text)
                self.messages.append(message!)
            case "PHOTO":
                //NSData(contentsOf: URL(string: mediaUrl)!)!
                do {
                    let imgData = try Data(contentsOf: URL(string: mediaUrl)!)
                    let picture = UIImage(data: imgData)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))
                } catch {
                    print(error)
                }
            case "VIDEO":
                if let url = URL(string: mediaUrl) {
                    let video = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))
                }
            default:
                break
            } // switch ends.
            
            self.finishReceivingMessage()
            
            // 如果读的是对方的信息，阅后即焚
            if senderId != self.senderId {
                let messageKey = snapshot.key
                let deleteRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").child(messageKey)
                deleteRef.removeValue()
            }
            
        }) { (error) in
            //let alertView = SCLAlertView()
            print("\(error.localizedDescription)")
            //alertView.showError("Message Error", subTitle: error.localizedDescription)
        }
    }
    
    // Observe if the current user is typing.
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
            print("Typing Indicator: \(error.localizedDescription)")
            // let alertView = SCLAlertView()
            // alertView.showError("Typing Indicator", subTitle: error.localizedDescription)
        }
    }
    
    // When the user presses the send button, send a text message.
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // Create a database reference for each message.
        let messageRef = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
        let message = Message(text: text, senderId: senderId, username: senderDisplayName, mediaType: "TEXT", mediaUrl: "")
        // Put the message into realtime database.
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
                let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                // Update the last message.
                lastMessageRef.setValue(text, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        // Send a notification
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDiscussion"), object: nil)
                    } else {
                        let alertView = SCLAlertView()
                        alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                    }
                })
                // Update the last message time.
                let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        // Nothing
                    } else {
                        let alertView = SCLAlertView()
                        alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                    }
                })
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                self.isTyping = false
            } else {
                let alertView = SCLAlertView()
                alertView.showError("Send Message Error", subTitle: error!.localizedDescription)
                self.isTyping = false
            }
        } // Put message ends.
    }
    
    // If the use taps the accessory button, then get the media data and send it.
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alertController = UIAlertController(title: "Medias", message: "Choose your media type", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 添加图片按钮
        let imageAction = UIAlertAction(title: "Image", style: .default) { (action) in
            print("Image")
            self.getMedia(mediaType: kUTTypeImage)
        }
        
        // 添加视频按钮
        let videoAction = UIAlertAction(title: "Video", style: .default) { (action) in
            print("Video")
            self.getMedia(mediaType: kUTTypeMovie)
        }
        
        // 添加取消按钮
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(imageAction)
        alertController.addAction(videoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // If the media is a picture type
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //let photo = JSQPhotoMediaItem(image: picture)
            self.saveMediaMessage(withImage: picture, withVideo: nil)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        }
        // If the media is a video type
        else if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //let video = JSQVideoMediaItem(fileURL: videoUrl, isReadyToPlay: true)
            self.saveMediaMessage(withImage: nil, withVideo: videoUrl)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video))
        }
        self.dismiss(animated: true) { 
            // JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()
        }

    }
    
    // This function put the media message into database.
    private func saveMediaMessage(withImage image: UIImage?, withVideo: URL?) {
        // 如果发送的是照片信息
        if let image = image {
            
            let imagePath = "messageWithMedia\(chatRoomId! + NSUUID().uuidString)/photo.jpg"
            let imageRef = storageRef.child(imagePath)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            // 将图片数据存放进storage并且返回URL，把URL存Realtime database.
            imageRef.put(imageData, metadata: metadata, completion: { (newMetaData, error) in
                if error == nil {
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "PHOTO", mediaUrl: "\(newMetaData!.downloadURL()!)")
                    let messageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()
                    // 将media message存入数据库
                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            // 更新last message
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue("\(newMetaData!.downloadURL()!)", withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Send a notification
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDiscussion"), object: nil)
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
                            // 更新last time
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Nothing
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
                            
                            // 消息发送完毕，播放声音
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            self.isTyping = false
                        } else {
                            let alertView = SCLAlertView()
                            alertView.showError("Send Message Error", subTitle: error!.localizedDescription)
                            self.isTyping = false
                        }
                    })
                    
                } else {
                    let alertView = SCLAlertView()
                    alertView.showError("Upload Image Error", subTitle: error!.localizedDescription)
                }
            })
        }
        // 如果发送的是视频信息
        else {
            let videoPath = "messageWithMedia\(chatRoomId! + NSUUID().uuidString)/video.mp4"
            let videoRef = storageRef.child(videoPath)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            let videoData = NSData(contentsOf: withVideo!)!
            // 将视频数据存放进storage并且返回URL，把URL存Realtime database.
            videoRef.put(videoData as Data, metadata: metadata, completion: { (newMetaData, error) in
                if error == nil {
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "VIDEO", mediaUrl: "\(newMetaData!.downloadURL()!)")
                    let messageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()
                    // 将media message存入数据库
                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            // 更新last message
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue("\(newMetaData!.downloadURL()!)", withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Send a notification
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDiscussion"), object: nil)
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
                            // 更新last time
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    // Nothing
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Last Message Error", subTitle: error!.localizedDescription)
                                }
                            })
                            // 消息发送完毕，播放声音
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            self.isTyping = false
                        } else {
                            let alertView = SCLAlertView()
                            alertView.showError("Send Message Error", subTitle: error!.localizedDescription)
                            self.isTyping = false
                        }
                    })
                    
                } else {
                    let alertView = SCLAlertView()
                    alertView.showError("Upload Image Error", subTitle: error!.localizedDescription)
                }
            })
        }
        
    }
    
    
    private func getMedia(mediaType: CFString) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if mediaType == kUTTypeImage {
            imagePicker.mediaTypes = [mediaType as String]
            
        } else if mediaType == kUTTypeMovie {
            imagePicker.mediaTypes = [mediaType as String]
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // 确定视图中信息的数量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // 确定聊天窗口中头像信息
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        if messages[indexPath.item].senderId == senderId {
            // 显示己方头像
        } else {
            // 显示对方头像
        }
        return nil
    }
    
    // 确定聊天窗口中的气泡类型
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // 确定信息的数据来源
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    // 根据IndexPath对气泡进行设置
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        // 如果是文字信息
        if !message.isMediaMessage {
            if message.senderId == senderId {
                cell.textView.textColor = UIColor.white
            } else {
                cell.textView.textColor = UIColor.black
            }
        }
        return cell
    }
    
    // If the user tap a media message bubble, the program should show the image or play the video.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let media = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: media.fileURL)
                let avPlayerViewController = AVPlayerViewController()
                avPlayerViewController.player = player
                self.present(avPlayerViewController, animated: true, completion: nil)
            }
            if let photo = message.media as? JSQPhotoMediaItem {
                let imageMessageView = photo.mediaView() as! UIImageView
                imageMessageView.setupForImageViewer()
                imageMessageView.setupForImageViewer(UIColor.black)
            }
        }
    }
    
    

}
