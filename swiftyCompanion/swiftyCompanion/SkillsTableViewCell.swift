//
//  SkillsTableViewCell.swift
//  swiftyCompanion
//
//  Created by Chloe MOULINET on 2/2/17.
//  Copyright © 2017 Chloe MOULINET. All rights reserved.
//

import UIKit

class SkillsTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var datas : (String, Float)? {
        didSet {
            if let d = datas {
                label?.text = d.0
                progressBar?.progress = d.1
            }
        }
    }


}
