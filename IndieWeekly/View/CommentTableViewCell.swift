//
//  CommentTableViewCell.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 23/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var creatorName: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
