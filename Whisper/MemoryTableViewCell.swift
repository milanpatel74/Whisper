//
//  MemoryTableViewCell.swift
//  Whisper
//
//  Created by Hayden on 2016/10/16.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit

class MemoryTableViewCell: UITableViewCell {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
