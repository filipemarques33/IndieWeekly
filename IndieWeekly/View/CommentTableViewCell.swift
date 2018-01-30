//
//  CommentTableViewCell.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 23/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

protocol CommentCellDelegate:NSObjectProtocol {
    func moreButtonPressed(onCell cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var creatorName: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    
    @IBAction func moreBtn(_ sender:UIButton) {
        if let delegate = self.delegate {
            delegate.moreButtonPressed(onCell: self)
        }
    }
    
    var comment:Comment!
    
    weak var delegate:CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
