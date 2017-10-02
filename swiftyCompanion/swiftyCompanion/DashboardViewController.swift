//
//  DashboardViewController.swift
//  swiftyCompanion
//
//  Created by Chloe MOULINET on 1/29/17.
//  Copyright © 2017 Chloe MOULINET. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var data: userData?
    
    @IBOutlet weak var projectsTableview: UITableView!
    @IBOutlet weak var skillsTableview: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var correction: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("viewDidLoad")
        loginLabel.text = (data?.fullName)! + " - " + (data?.login)!
        emailLabel.text = data?.email
        phoneLabel.text = data?.phone
        levelLabel.text = "Level " + (data?.level)! + " - " + String(describing: Int((data?.progression)! * 100)) + "%"
        correction.text = "Correction points : " + (data?.correctionPoint)!
        walletLabel.text = "Wallet : " + (data?.wallet)!
        locationLabel.text = "Location : " + (data?.location)!
        
        if let url = NSData(contentsOf: URL(string: (data?.imageUrl)!)!) {
            profilePicture.image = UIImage(data: url as Data)
        }
        
        progressBar.progress = (data?.progression)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.projectsTableview {
            count = data?.projectsArray.count
        }
        
        if tableView == self.skillsTableview {
            count =  data?.skillsArray.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.projectsTableview {
        
            cell = projectsTableview.dequeueReusableCell(withIdentifier: "projectCell")
            cell?.textLabel?.text = data?.projectsArray[indexPath.row].Name
            cell?.detailTextLabel?.text = data?.projectsArray[indexPath.row].Mark
            if data?.projectsArray[indexPath.row].Color == "red" {
                cell?.detailTextLabel?.textColor = UIColor(red: 0.66, green: 0.27, blue: 0.26, alpha: 1.0)
            } else if data?.projectsArray[indexPath.row].Color == "green" {
                cell?.detailTextLabel?.textColor = UIColor(red: 0.24, green: 0.46, blue: 0.24, alpha: 1.0)
            }
            
        }
        
        if tableView == self.skillsTableview {
            
            let cell = skillsTableview.dequeueReusableCell(withIdentifier: "skillCell") as! SkillsTableViewCell
            
            let title = (data?.skillsArray[indexPath.row].Name)! + " - " + (data?.skillsArray[indexPath.row].Level)!
            cell.datas = (title, (data?.skillsArray[indexPath.row].Progression)!)
            return cell
            
        }
        
        return cell!

    }

}
