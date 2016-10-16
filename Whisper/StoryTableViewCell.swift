//
//  StoryTableViewCell.swift
//  Whisper
//
//  Created by Hayden on 2016/10/17.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    @IBOutlet var storyImage: CustomizableImageView!
    
    @IBOutlet var username: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeoutLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
