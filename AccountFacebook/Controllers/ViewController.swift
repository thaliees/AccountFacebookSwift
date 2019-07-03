//
//  ViewController.swift
//  AccountFacebook
//
//  Created by Thaliees on 7/3/19.
//  Copyright © 2019 Thaliees. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email, .publicProfile], viewController: self) { (loginResult) in
            switch loginResult{
            case .success(_, _, _):
                self.initMainViewController()
            case .cancelled:
                print("User cancelled login")
            case .failed(let error):
                print(error)
            }
        }
    }
    
    private func initMainViewController(){
        // Launch ViewController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let main = mainStoryboard.instantiateViewController(withIdentifier: "MainStoryboard") as? MainViewController {
            UserDefaults.standard.set(true, forKey: "isLogin")
            UserDefaults.standard.synchronize()
            self.present(main, animated: true, completion: nil)
        }
    }
}

