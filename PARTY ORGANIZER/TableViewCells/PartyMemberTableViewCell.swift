//
//  PartyMemberTableViewCell.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 10/01/2021.
//

import UIKit

class PartyMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var partyMemberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
