//
//  GameInfoCells.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 16/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class PlainInfoCell:UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class SegueCell:UITableViewCell {
    
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var cellText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class LinkCell:UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var cellText: UILabel!
    var website:URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

