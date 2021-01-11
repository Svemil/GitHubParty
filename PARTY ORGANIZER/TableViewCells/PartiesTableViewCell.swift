//
//  PartiesTableViewCell.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 08/01/2021.
//

import UIKit

class PartiesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var namePartyLabel: UILabel!
    @IBOutlet weak var startDatePartyLabel: UILabel!
    @IBOutlet weak var descriptionOfPartyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
