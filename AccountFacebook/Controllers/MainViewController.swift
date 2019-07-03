//
//  MainViewController.swift
//  AccountFacebook
//
//  Created by Thaliees on 7/3/19.
//  Copyright © 2019 Thaliees. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKCoreKit

class MainViewController: UIViewController {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if AccessToken.isCurrentAccessTokenActive{
            useLoginInformation()
        }
        else{
            dataUserDefault()
        }
    }
    
    private func useLoginInformation(){
        // We set parameters to the GraphRequest.
        let params = ["fields": "id, name, email, picture.width(200)"]
        // Creating the GraphRequest to fetch user details
        // 1st graphPath - me, to get the profile information of the person who has a session currently started
        // 2st parameters - the data that we want to obtain from the user
        // 3st httpMethod - the http method
        let requestGraph = GraphRequest(graphPath: "me", parameters: params, httpMethod: HTTPMethod(rawValue: "GET"))
        // Creating the GraphRequesConnection
        let connection = GraphRequestConnection()
        connection.add(requestGraph) { (connection, result, error) in
            if error != nil{
                return
            }
            
            // The result is structured as JSON. Uncomment the next line to print
            //print(result!)
            
            // We validate that the result can be converted into an object [String: Any] to access its properties
            if let object = result as? [String: Any],
                let name:String = object["name"] as? String, let email:String = object["email"] as? String,
                let photo:NSDictionary = object["picture"] as? NSDictionary, let data:NSDictionary = photo["data"] as? NSDictionary,
                let url:String = data["url"] as? String{
                self.name.text = name
                self.email.text = email
                // Set the profile photo
                // Option 1: Using AsyncTask
                let urlPhoto = URL(string: url)!
                self.downloadPhoto(from: urlPhoto);
                
                self.saveDataUserDefault(name: name, email: email, photo: urlPhoto)
            }
        }
        connection.start()
    }
    
    private func downloadPhoto(from url: URL){
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // The download has finished.
            // Convert that Data into an image and do what you wish with it.
            if let data = data {
                DispatchQueue.main.async {
                    self.photo.image = UIImage(data: data)
                    self.photo.layer.cornerRadius = self.photo.bounds.size.width / 2
                    self.photo.clipsToBounds = true
                }
            }
        }
        downloadPicTask.resume()
    }
    
    @IBAction func logout(_ sender: UIButton) {
        initPrincipalViewController()
    }
    
    private func initPrincipalViewController(){
        // Launch ViewController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let main = mainStoryboard.instantiateViewController(withIdentifier: "ViewStoryboard") as? ViewController {
            UserDefaults.standard.set(false, forKey: "isLogin")
            UserDefaults.standard.synchronize()
            self.present(main, animated: true, completion: nil)
        }
    }
    
    private func saveDataUserDefault(name:String, email:String, photo:URL){
        UserDefaults.standard.set(name, forKey: "nameUser")
        UserDefaults.standard.set(email, forKey: "emailUser")
        UserDefaults.standard.set(photo, forKey: "photoUser")
        UserDefaults.standard.synchronize()
    }
    
    private func dataUserDefault(){
        self.name.text = UserDefaults.standard.string(forKey: "nameUser")
        self.email.text = UserDefaults.standard.string(forKey: "emailUser")
        downloadPhoto(from: UserDefaults.standard.url(forKey: "photoUser")!)
    }
}
