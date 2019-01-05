//
//  EventCell.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 7/15/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import Firebase

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventTypeLbl: UILabel!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var isLockedLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    var password = ""
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
