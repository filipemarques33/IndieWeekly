//
//  EditCommentTableViewCell.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 23/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class EditCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var commentContent: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commentContent.centerVertically()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension EditCommentTableViewCell:PostCommentDataSource {
    func getCommentView() -> UITextView? {
        return commentContent
    }
}
