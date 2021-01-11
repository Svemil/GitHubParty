//
//  MembersTableViewCell.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 08/01/2021.
//

import UIKit

class MembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        memberImageView.layer.cornerRadius = memberImageView.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
