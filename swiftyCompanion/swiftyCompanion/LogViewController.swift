//
//  ViewController.swift
//  swiftyCompanion
//
//  Created by Chloe MOULINET on 1/24/17.
//  Copyright © 2017 Chloe MOULINET. All rights reserved.
//

import UIKit
import SwiftyJSON

class LogViewController: UIViewController {
    
    @IBOutlet weak var loginField: UITextField!
    
    let UID = "0e86f80e5d296b505edd2cfdc54900ca9e5905bba115007224e62b3e0b66996f"
    let secret = "c14a3bd28ef9abe8b843611071d331f067784ac95631eb69db3affff83707add"
    var accessToken = ""
    var resetToken = false
    var data: userData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("viewDidLoad")
        loginField.isUserInteractionEnabled = false
        loginField.backgroundColor = UIColor.lightGray
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showUserPage"
        {
            if let destinationVC = segue.destination as? DashboardViewController {
                destinationVC.data = self.data!
            }
        }
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        if loginField.text! != "" {
            getLoginData(login: loginField.text!)
        }
        
    }
    
    func getToken() {
        let url = NSURL(string: "https://api.intra.42.fr/oauth/token")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-type")
        request.httpBody = "grant_type=client_credentials&client_id=\(UID)&client_secret=\(secret)".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if let err = error {
                print("error1")
                print(err)
            } else if let d = data {
                do {
                    if let dic : NSDictionary = try JSONSerialization.jsonObject(with: d, options: []) as? NSDictionary {
                        self.accessToken = String(describing: dic["access_token"]!)
                        self.loginField.isUserInteractionEnabled = true
                        DispatchQueue.main.async {
                            self.loginField.backgroundColor = UIColor.clear
                        }
                        if self.resetToken == true {
                            self.resetToken = false
                            if self.loginField.text! != "" {
                                self.getLoginData(login: self.loginField.text!)
                            }
                        }
                    }
                } catch (let err) {
                    print("error2")
                    print(err)
                }
            }
            
        }
        task.resume()
    }
    
    func getLoginData(login: String) {
        if let url = NSURL(string: "https://api.intra.42.fr/v2/users/\(login)") {
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "GET"
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                (data, response, error) in
                let httpResponse = response as! HTTPURLResponse
                let status = httpResponse.statusCode
                print("token: \(self.accessToken) - status : \(status)")
                if status == 200 {
                    if let err = error {
                        print(err)
                    } else if let d = data {
                        
                        let json = JSON(data: d)
                        
                        let levelDouble: Double = json["cursus_users"][0]["level"].double ?? 0.0
                        let progression: Float = Float(levelDouble.truncatingRemainder(dividingBy: 1.0))
                        let level: Int = Int(levelDouble)
                                                
                        var projectArray: [(Name: String, Mark: String, Color: String)] = []
                        var skillArray: [(Name: String, Level: String, Progression: Float)] = []
                        
                        for (_,project):(String, JSON) in json["projects_users"] {
                            if project["status"] == "finished" && String(describing: project["final_mark"]) != "null" {
                                var color = "black"
                                if project["validated?"] == true {
                                    color = "green"
                                } else {
                                    color = "red"
                                }
                                projectArray.append((project["project"]["name"].string ?? "no name", String(describing: project["final_mark"]), color))
                            }
                        }
                        
                        for (_,skill):(String, JSON) in json["cursus_users"][0]["skills"] {
                            
                            let levelDouble: Double = skill["level"].double ?? 0.0
                            let progression: Float = Float(levelDouble.truncatingRemainder(dividingBy: 1.0))
                            
                            skillArray.append((skill["name"].string ?? "no name", String(describing: skill["level"].double!) + "%", progression))
                        }

                        
                        self.data = userData(
                            login: json["login"].string ?? "-",
                            fullName: json["displayname"].string ?? "-",
                            email: json["email"].string ?? "-",
                            phone: json["phone"].string ?? "-",
                            level: String(describing: level),
                            progression: progression,
                            location: json["location"].string ?? "-",
                            wallet: String(describing: json["wallet"]),
                            correctionPoint: String(describing: json["correction_point"]),
                            imageUrl: json["image_url"].string ?? "-",
                            projectsArray: projectArray,
                            skillsArray: skillArray
                        )

                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showUserPage", sender: self)
                        }
                            
                    }
                    
                } else {
                    
                    var alert: UIAlertController
                    
                    switch status {
                    case 401:
                        self.loginField.isUserInteractionEnabled = false
                        self.loginField.backgroundColor = UIColor.lightGray
                        self.resetToken = true
                        self.getToken()
                        alert = UIAlertController(title: "Alert", message: "Oops, your token was expired, but we just provided you a new one. Submit your request again", preferredStyle: UIAlertControllerStyle.alert)
                    case 404:
                        alert = UIAlertController(title: "Alert", message: "Looks like the login you searched doesn't exist. Please try again with a valid login.", preferredStyle: UIAlertControllerStyle.alert)
                    default:
                        alert = UIAlertController(title: "Alert", message: "Something wrong happened... please try again", preferredStyle: UIAlertControllerStyle.alert)
                    }
                    
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
                
            }
            task.resume()
        } else {
            var alert: UIAlertController
            alert = UIAlertController(title: "Alert", message: "Login field only accepts alphanumeric characters, hyphens and underscore.", preferredStyle: UIAlertControllerStyle.alert)
            DispatchQueue.main.async {
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

